package stats

import (
	"database/sql"
	"errors"
	"fmt"
	"time"

	"github.com/jmoiron/sqlx"
)

type Payload struct {
	Summary             Summary             `json:"summary"`
	WeeklyActivity      []WeeklyPoint       `json:"weekly_activity"`
	MonthlyTrend        []WeeklyPoint       `json:"monthly_trend"`
	WorkoutsByMonth     []MonthPoint        `json:"workouts_by_month"`
	Categories          []CategoryPoint     `json:"categories"`
	FavoriteWorkoutType string              `json:"favorite_workout_type"`
	MostActiveWeekday   string              `json:"most_active_weekday"`
}

type Summary struct {
	TotalWorkouts                 int    `json:"total_workouts"`
	TotalDurationHours            int    `json:"total_duration_hours"`
	Consistency                   int    `json:"consistency"`
	WorkoutsThisWeek              int    `json:"workouts_this_week"`
	WorkoutsThisMonth             int    `json:"workouts_this_month"`
	AverageWorkoutDurationMinutes int    `json:"average_workout_duration_minutes"`
	CompletionRate                int    `json:"completion_rate"`
	FavoriteMuscleGroup           string `json:"favorite_muscle_group"`
	MostActiveDay                 string `json:"most_active_day"`
}

type WeeklyPoint struct {
	ID    string `json:"id"`
	Label string `json:"label"`
	Value int    `json:"value"`
}

type MonthPoint struct {
	ID         string `json:"id"`
	MonthLabel string `json:"month_label"`
	Value      int    `json:"value"`
}

type CategoryPoint struct {
	ID    string `json:"id"`
	Title string `json:"title"`
	Value int    `json:"value"`
}

type Builder struct {
	db *sqlx.DB
}

func NewBuilder(db *sqlx.DB) *Builder {
	return &Builder{db: db}
}

func startOfUTCWeekMonday(t time.Time) time.Time {
	t = t.UTC()
	wd := int(t.Weekday()) // Sunday=0, Monday=1
	sinceMon := (wd + 6) % 7
	day := time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, time.UTC)
	return day.AddDate(0, 0, -sinceMon)
}

func (b *Builder) weeklyISOCounts(userID string) ([7]int, error) {
	var rows []struct {
		Dow int `db:"dow"`
		Cnt int `db:"cnt"`
	}
	err := b.db.Select(&rows, `
		SELECT EXTRACT(ISODOW FROM completed_at AT TIME ZONE 'UTC')::int AS dow, COUNT(*)::int AS cnt
		FROM workout_sessions
		WHERE user_id = $1
		GROUP BY 1
	`, userID)
	if err != nil {
		return [7]int{}, fmt.Errorf("weekly counts: %w", err)
	}
	var out [7]int
	for _, r := range rows {
		if r.Dow >= 1 && r.Dow <= 7 {
			out[r.Dow-1] = r.Cnt
		}
	}
	return out, nil
}

func weeklyPointsFromCounts(counts [7]int) []WeeklyPoint {
	labels := []string{"M", "T", "W", "T", "F", "S", "S"}
	out := make([]WeeklyPoint, 7)
	for i := 0; i < 7; i++ {
		out[i] = WeeklyPoint{
			ID:    fmt.Sprintf("%d", i+1),
			Label: labels[i],
			Value: counts[i],
		}
	}
	return out
}

var isoDayNames = []string{"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"}

func pickMostActiveDayName(counts [7]int) string {
	maxI, maxV := 0, -1
	for i, v := range counts {
		if v > maxV {
			maxV, maxI = v, i
		}
	}
	if maxV <= 0 {
		return ""
	}
	return isoDayNames[maxI]
}

func (b *Builder) rollingFourWeekTrend(userID string, now time.Time) ([]WeeklyPoint, error) {
	day := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.UTC)
	out := make([]WeeklyPoint, 4)
	for w := 0; w < 4; w++ {
		hi := day.AddDate(0, 0, -7*w)
		lo := hi.AddDate(0, 0, -6)
		var cnt int
		if err := b.db.Get(&cnt, `
			SELECT COUNT(*) FROM workout_sessions
			WHERE user_id = $1
			  AND (completed_at AT TIME ZONE 'UTC')::date >= $2::date
			  AND (completed_at AT TIME ZONE 'UTC')::date <= $3::date
		`, userID, lo.Format("2006-01-02"), hi.Format("2006-01-02")); err != nil {
			return nil, fmt.Errorf("trend w%d: %w", w+1, err)
		}
		out[w] = WeeklyPoint{ID: fmt.Sprintf("%d", w+1), Label: fmt.Sprintf("W%d", w+1), Value: cnt}
	}
	return out, nil
}

func (b *Builder) lastSixCalendarMonths(userID string, now time.Time) ([]MonthPoint, error) {
	now = now.UTC()
	out := make([]MonthPoint, 0, 6)
	for i := 0; i < 6; i++ {
		ref := now.AddDate(0, -(5-i), 0)
		start := time.Date(ref.Year(), ref.Month(), 1, 0, 0, 0, 0, time.UTC)
		end := start.AddDate(0, 1, 0).Add(-time.Nanosecond)
		var cnt int
		if err := b.db.Get(&cnt, `
			SELECT COUNT(*) FROM workout_sessions
			WHERE user_id = $1
			  AND completed_at >= $2
			  AND completed_at <= $3
		`, userID, start, end); err != nil {
			return nil, fmt.Errorf("month %s: %w", start.Format("2006-01"), err)
		}
		id := start.Format("Jan")
		out = append(out, MonthPoint{
			ID:         id,
			MonthLabel: start.Format("Jan"),
			Value:      cnt,
		})
	}
	return out, nil
}

func (b *Builder) topMuscleCategories(userID string) ([]CategoryPoint, string, error) {
	var rows []struct {
		Title string `db:"muscle_group"`
		Cnt   int    `db:"cnt"`
	}
	err := b.db.Select(&rows, `
		SELECT d.muscle_group, COUNT(*)::int AS cnt
		FROM workout_session_exercise_entries wse
		INNER JOIN workout_sessions ws ON ws.id = wse.session_id
		INNER JOIN session_exercises d ON d.id = wse.exercise_id
		WHERE ws.user_id = $1 AND d.muscle_group <> ''
		GROUP BY d.muscle_group
		ORDER BY cnt DESC
		LIMIT 10
	`, userID)
	if err != nil {
		return nil, "", fmt.Errorf("categories: %w", err)
	}
	if len(rows) == 0 {
		z := []CategoryPoint{
			{ID: "1", Title: "Chest", Value: 0},
			{ID: "2", Title: "Back", Value: 0},
			{ID: "3", Title: "Legs", Value: 0},
		}
		return z, "", nil
	}
	out := make([]CategoryPoint, 0, len(rows))
	for i, r := range rows {
		if i >= 3 {
			break
		}
		out = append(out, CategoryPoint{
			ID:    fmt.Sprintf("%d", i+1),
			Title: r.Title,
			Value: r.Cnt,
		})
	}
	for len(out) < 3 {
		out = append(out, CategoryPoint{ID: fmt.Sprintf("%d", len(out)+1), Title: "-", Value: 0})
	}
	fav := rows[0].Title
	return out, fav, nil
}

func (b *Builder) topWorkoutType(userID string) (string, error) {
	var wtype string
	err := b.db.Get(&wtype, `
		SELECT workout_type FROM workout_sessions
		WHERE user_id = $1
		GROUP BY workout_type
		ORDER BY COUNT(*) DESC
		LIMIT 1
	`, userID)
	if errors.Is(err, sql.ErrNoRows) {
		return "", nil
	}
	if err != nil {
		return "", fmt.Errorf("favorite type: %w", err)
	}
	return wtype, nil
}
