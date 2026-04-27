package stats

import (
	"fmt"
	"time"

	"github.com/jmoiron/sqlx"
)

type TemporalBlock struct {
	ThisWeek      int
	ThisMonth     int
	Consistency   int
	MonthlyTrend  []WeeklyPoint
	WorkoutsByMonth []MonthPoint
}

func (b *Builder) BuildTemporalBlock(userID string, now time.Time) (TemporalBlock, error) {
	if b == nil || b.db == nil {
		return TemporalBlock{}, fmt.Errorf("stats builder: nil db")
	}
	now = now.UTC()
	weekStart := startOfUTCWeekMonday(now)

	var thisWeek int
	if err := b.db.Get(&thisWeek, `
		SELECT COUNT(*) FROM workout_sessions
		WHERE user_id = $1
		  AND completed_at >= $2
	`, userID, weekStart); err != nil {
		return TemporalBlock{}, fmt.Errorf("this week: %w", err)
	}

	monthStart := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, time.UTC)
	var thisMonth int
	if err := b.db.Get(&thisMonth, `
		SELECT COUNT(*) FROM workout_sessions
		WHERE user_id = $1
		  AND completed_at >= $2
	`, userID, monthStart); err != nil {
		return TemporalBlock{}, fmt.Errorf("this month: %w", err)
	}

	consistencyCutoff := weekStart.AddDate(0, 0, -7*(ConsistencyWeeksWindow-1))
	var weeksHit int
	if err := b.db.Get(&weeksHit, `
		SELECT COUNT(DISTINCT to_char(completed_at AT TIME ZONE 'UTC', 'IYYY-IW'))
		FROM workout_sessions
		WHERE user_id = $1
		  AND completed_at >= $2
	`, userID, consistencyCutoff); err != nil {
		return TemporalBlock{}, fmt.Errorf("consistency weeks: %w", err)
	}
	consistency := ConsistencyFromWeekHits(weeksHit, ConsistencyWeeksWindow)

	trend, err := b.rollingFourWeekTrend(userID, now)
	if err != nil {
		return TemporalBlock{}, err
	}

	byMonth, err := b.lastSixCalendarMonths(userID, now)
	if err != nil {
		return TemporalBlock{}, err
	}

	return TemporalBlock{
		ThisWeek:        thisWeek,
		ThisMonth:       thisMonth,
		Consistency:     consistency,
		MonthlyTrend:    trend,
		WorkoutsByMonth: byMonth,
	}, nil
}

func BuildTemporalBlockFromDB(db *sqlx.DB, userID string, now time.Time) (TemporalBlock, error) {
	return NewBuilder(db).BuildTemporalBlock(userID, now)
}
