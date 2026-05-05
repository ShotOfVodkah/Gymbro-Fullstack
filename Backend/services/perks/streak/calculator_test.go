package streak

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

func TestScheduleWeeklyGoal_ClampsToRange(t *testing.T) {
	c := NewStreakCalculator()
	state := State{WeeklyGoal: 3}

	state = c.ScheduleWeeklyGoal(state, 0)
	if assert.NotNil(t, state.NextWeeklyGoal) {
		assert.Equal(t, 1, *state.NextWeeklyGoal)
	}

	state = c.ScheduleWeeklyGoal(state, 10)
	if assert.NotNil(t, state.NextWeeklyGoal) {
		assert.Equal(t, 7, *state.NextWeeklyGoal)
	}
}

func TestCurrentWeek_StartsOnMonday(t *testing.T) {
	c := NewStreakCalculator()
	now := time.Date(2026, 5, 6, 12, 0, 0, 0, time.UTC)
	week := c.CurrentWeek(now)
	assert.Equal(t, time.Monday, week.Start.Weekday())
	assert.Equal(t, 0, week.Start.Hour())
	assert.Equal(t, 0, week.Start.Minute())
	assert.Equal(t, 6, int(week.End.Sub(week.Start).Hours()/24))
}

