package stats

import (
	"context"
	"encoding/json"
	"fmt"
	"sort"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-workouts/store"
)

func (b *Builder) buildPayloadFromRollup(userID string, now time.Time, ru *store.UserWorkoutStatsRollup) ([]byte, error) {
	now = now.UTC()

	tb, err := b.BuildTemporalBlock(userID, now)
	if err != nil {
		return nil, err
	}

	totalHours := int(ru.SumExerciseMinutes / 60)
	if totalHours < 0 {
		totalHours = 0
	}
	var avgDur float64
	if ru.TotalSessions > 0 {
		avgDur = float64(ru.SumExerciseMinutes) / float64(ru.TotalSessions)
	}
	mostActiveDay := pickMostActiveDayName(ru.DowCounts)

	cats, favMuscle := categoriesAndFavoriteFromMaps(ru.MuscleGroupCounts)
	favType := favoriteTypeFromMap(ru.WorkoutTypeCounts)

	pl := Payload{
		Summary: Summary{
			TotalWorkouts:                 ru.TotalSessions,
			TotalDurationHours:            totalHours,
			Consistency:                   tb.Consistency,
			WorkoutsThisWeek:              tb.ThisWeek,
			WorkoutsThisMonth:             tb.ThisMonth,
			AverageWorkoutDurationMinutes: int(avgDur + 0.5),
			CompletionRate:                CompletionRateV1(),
			FavoriteMuscleGroup:           favMuscle,
			MostActiveDay:                 mostActiveDay,
		},
		WeeklyActivity:      weeklyPointsFromCounts(ru.DowCounts),
		MonthlyTrend:        tb.MonthlyTrend,
		WorkoutsByMonth:     tb.WorkoutsByMonth,
		Categories:          cats,
		FavoriteWorkoutType: favType,
		MostActiveWeekday:   mostActiveDay,
	}
	return json.Marshal(pl)
}

func categoriesAndFavoriteFromMaps(m map[string]int) ([]CategoryPoint, string) {
	if len(m) == 0 {
		z := []CategoryPoint{
			{ID: "1", Title: "Chest", Value: 0},
			{ID: "2", Title: "Back", Value: 0},
			{ID: "3", Title: "Legs", Value: 0},
		}
		return z, ""
	}
	type kv struct {
		k string
		v int
	}
	var pairs []kv
	for k, v := range m {
		pairs = append(pairs, kv{k, v})
	}
	sort.Slice(pairs, func(i, j int) bool {
		if pairs[i].v == pairs[j].v {
			return pairs[i].k < pairs[j].k
		}
		return pairs[i].v > pairs[j].v
	})
	fav := pairs[0].k
	out := make([]CategoryPoint, 0, 3)
	for i := 0; i < 3 && i < len(pairs); i++ {
		out = append(out, CategoryPoint{ID: fmt.Sprintf("%d", i+1), Title: pairs[i].k, Value: pairs[i].v})
	}
	for len(out) < 3 {
		out = append(out, CategoryPoint{ID: fmt.Sprintf("%d", len(out)+1), Title: "-", Value: 0})
	}
	return out, fav
}

func favoriteTypeFromMap(m map[string]int) string {
	if len(m) == 0 {
		return ""
	}
	best, cnt := "", -1
	var keys []string
	for t := range m {
		keys = append(keys, t)
	}
	sort.Strings(keys)
	for _, t := range keys {
		if m[t] > cnt {
			cnt, best = m[t], t
		}
	}
	return best
}

func (b *Builder) buildPayloadFullScan(userID string, now time.Time) ([]byte, error) {
	now = now.UTC()
	weekStart := startOfUTCWeekMonday(now)

	var totalSessions int
	if err := b.db.Get(&totalSessions, `SELECT COUNT(*) FROM workout_sessions WHERE user_id = $1`, userID); err != nil {
		return nil, fmt.Errorf("total sessions: %w", err)
	}

	var totalExerciseMinutes int
	if err := b.db.Get(&totalExerciseMinutes, `
		SELECT COALESCE(SUM(wse.duration_minutes), 0)
		FROM workout_session_exercise_entries wse
		INNER JOIN workout_sessions ws ON ws.id = wse.session_id
		WHERE ws.user_id = $1 AND wse.duration_minutes IS NOT NULL
	`, userID); err != nil {
		return nil, fmt.Errorf("sum duration: %w", err)
	}

	var avgDur float64
	if err := b.db.Get(&avgDur, `
		WITH per AS (
			SELECT ws.id, COALESCE(SUM(wse.duration_minutes), 0)::float AS dur
			FROM workout_sessions ws
			LEFT JOIN workout_session_exercise_entries wse ON wse.session_id = ws.id
			WHERE ws.user_id = $1
			GROUP BY ws.id
		)
		SELECT COALESCE(AVG(dur), 0) FROM per
	`, userID); err != nil {
		return nil, fmt.Errorf("avg duration: %w", err)
	}

	var thisWeek int
	if err := b.db.Get(&thisWeek, `
		SELECT COUNT(*) FROM workout_sessions
		WHERE user_id = $1
		  AND completed_at >= $2
	`, userID, weekStart); err != nil {
		return nil, fmt.Errorf("this week: %w", err)
	}

	monthStart := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, time.UTC)
	var thisMonth int
	if err := b.db.Get(&thisMonth, `
		SELECT COUNT(*) FROM workout_sessions
		WHERE user_id = $1
		  AND completed_at >= $2
	`, userID, monthStart); err != nil {
		return nil, fmt.Errorf("this month: %w", err)
	}

	consistencyCutoff := weekStart.AddDate(0, 0, -7*(ConsistencyWeeksWindow-1))
	var weeksHit int
	if err := b.db.Get(&weeksHit, `
		SELECT COUNT(DISTINCT to_char(completed_at AT TIME ZONE 'UTC', 'IYYY-IW'))
		FROM workout_sessions
		WHERE user_id = $1
		  AND completed_at >= $2
	`, userID, consistencyCutoff); err != nil {
		return nil, fmt.Errorf("consistency weeks: %w", err)
	}
	consistency := ConsistencyFromWeekHits(weeksHit, ConsistencyWeeksWindow)

	weekly, err := b.weeklyISOCounts(userID)
	if err != nil {
		return nil, err
	}
	mostActiveDay := pickMostActiveDayName(weekly)

	trend, err := b.rollingFourWeekTrend(userID, now)
	if err != nil {
		return nil, err
	}

	byMonth, err := b.lastSixCalendarMonths(userID, now)
	if err != nil {
		return nil, err
	}

	cats, favMuscle, err := b.topMuscleCategories(userID)
	if err != nil {
		return nil, err
	}

	favType, err := b.topWorkoutType(userID)
	if err != nil {
		return nil, err
	}

	totalHours := totalExerciseMinutes / 60
	if totalHours < 0 {
		totalHours = 0
	}

	pl := Payload{
		Summary: Summary{
			TotalWorkouts:                 totalSessions,
			TotalDurationHours:            totalHours,
			Consistency:                   consistency,
			WorkoutsThisWeek:              thisWeek,
			WorkoutsThisMonth:             thisMonth,
			AverageWorkoutDurationMinutes: int(avgDur + 0.5),
			CompletionRate:                CompletionRateV1(),
			FavoriteMuscleGroup:           favMuscle,
			MostActiveDay:                 mostActiveDay,
		},
		WeeklyActivity:      weeklyPointsFromCounts(weekly),
		MonthlyTrend:        trend,
		WorkoutsByMonth:     byMonth,
		Categories:          cats,
		FavoriteWorkoutType: favType,
		MostActiveWeekday:   mostActiveDay,
	}
	return json.Marshal(pl)
}

func (b *Builder) BuildPayloadJSON(userID string, now time.Time) ([]byte, error) {
	if b == nil || b.db == nil {
		return nil, fmt.Errorf("stats builder: nil db")
	}
	ru, has, err := store.GetUserWorkoutStats(context.Background(), b.db, userID)
	if err != nil {
		return nil, err
	}
	if has && ru != nil {
		return b.buildPayloadFromRollup(userID, now, ru)
	}
	return b.buildPayloadFullScan(userID, now)
}
