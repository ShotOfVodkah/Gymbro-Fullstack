package streak

import "time"

type State struct {
	CurrentStreakWeeks    int
	BestStreakWeeks       int
	WeeklyGoal            int
	NextWeeklyGoal        *int
	CompletedThisWeek     int
	RemainingToGoal       int
	WeekStartDate         time.Time
	WeekEndDate           time.Time
	IsGoalCompleted       bool
	WasFreezeUsedThisWeek bool
}

type WeekRange struct {
	Start time.Time
	End   time.Time
}

type StreakCalculator struct{}

func NewStreakCalculator() *StreakCalculator {
	return &StreakCalculator{}
}

func (c *StreakCalculator) CurrentWeek(now time.Time) WeekRange {
	weekday := int(now.Weekday())
	if weekday == 0 {
		weekday = 7
	}

	start := time.Date(
		now.Year(),
		now.Month(),
		now.Day(),
		0,
		0,
		0,
		0,
		now.Location(),
	).AddDate(0, 0, -(weekday - 1))

	return WeekRange{
		Start: start,
		End:   start.AddDate(0, 0, 6),
	}
}

func (c *StreakCalculator) RecalculateCurrentWeek(state State, now time.Time) State {
	week := c.CurrentWeek(now)

	if sameDay(state.WeekStartDate, week.Start) {
		return c.recalculateProgress(state)
	}

	return c.rolloverToNewWeek(state, week)
}

func (c *StreakCalculator) ApplyWorkoutCompleted(state State, now time.Time) State {
	state = c.RecalculateCurrentWeek(state, now)

	state.CompletedThisWeek += 1
	return c.recalculateProgress(state)
}

func (c *StreakCalculator) ApplyFreeze(state State, now time.Time) State {
	state = c.RecalculateCurrentWeek(state, now)

	if state.WasFreezeUsedThisWeek {
		return state
	}

	state.WasFreezeUsedThisWeek = true
	return state
}

func (c *StreakCalculator) ScheduleWeeklyGoal(state State, nextGoal int) State {
	if nextGoal < 1 {
		nextGoal = 1
	}

	if nextGoal > 7 {
		nextGoal = 7
	}

	state.NextWeeklyGoal = &nextGoal
	return state
}

func (c *StreakCalculator) rolloverToNewWeek(state State, week WeekRange) State {
	previousWeekCompleted := state.IsGoalCompleted || state.CompletedThisWeek >= state.WeeklyGoal

	if previousWeekCompleted {
		state.CurrentStreakWeeks += 1
		if state.CurrentStreakWeeks > state.BestStreakWeeks {
			state.BestStreakWeeks = state.CurrentStreakWeeks
		}
	} else if state.WasFreezeUsedThisWeek {
		// Freeze protects the streak once, but does not increase it.
	} else {
		state.CurrentStreakWeeks = 0
	}

	if state.NextWeeklyGoal != nil {
		state.WeeklyGoal = *state.NextWeeklyGoal
		state.NextWeeklyGoal = nil
	}

	state.CompletedThisWeek = 0
	state.RemainingToGoal = state.WeeklyGoal
	state.IsGoalCompleted = false
	state.WasFreezeUsedThisWeek = false
	state.WeekStartDate = week.Start
	state.WeekEndDate = week.End

	return state
}

func (c *StreakCalculator) recalculateProgress(state State) State {
	if state.WeeklyGoal < 1 {
		state.WeeklyGoal = 1
	}

	if state.WeeklyGoal > 7 {
		state.WeeklyGoal = 7
	}

	if state.CompletedThisWeek < 0 {
		state.CompletedThisWeek = 0
	}

	if state.CompletedThisWeek >= state.WeeklyGoal {
		state.IsGoalCompleted = true
		state.RemainingToGoal = 0
		return state
	}

	state.IsGoalCompleted = false
	state.RemainingToGoal = state.WeeklyGoal - state.CompletedThisWeek
	return state
}

func sameDay(lhs time.Time, rhs time.Time) bool {
	lhsYear, lhsMonth, lhsDay := lhs.Date()
	rhsYear, rhsMonth, rhsDay := rhs.Date()

	return lhsYear == rhsYear &&
		lhsMonth == rhsMonth &&
		lhsDay == rhsDay
}