package streak

import (
	"context"
	"fmt"
	"time"

	"github.com/jmoiron/sqlx"

	"github.com/alexandra-gritsaenko/gymbro-perks/store"
	"github.com/alexandra-gritsaenko/gymbro-perks/types"
)

type Store struct {
	db         *sqlx.DB
	perksBase *store.PerksStore
	calculator *StreakCalculator
}

func NewStore(db *sqlx.DB, perksBase *store.PerksStore) *Store {
	return &Store{
		db:         db,
		perksBase: perksBase,
		calculator: NewStreakCalculator(),
	}
}

func (s *Store) GetStreak(ctx context.Context, userID int64) (types.StreakResponse, error) {
	if err := s.perksBase.EnsureUser(ctx, userID); err != nil {
		return types.StreakResponse{}, err
	}

	state, err := s.getState(ctx, userID)
	if err != nil {
		return types.StreakResponse{}, err
	}

	state = s.calculator.RecalculateCurrentWeek(state, time.Now())

	if err := s.saveState(ctx, userID, state); err != nil {
		return types.StreakResponse{}, err
	}

	freezeCount, err := s.getAvailableFreezeCount(ctx, userID)
	if err != nil {
		return types.StreakResponse{}, err
	}

	return stateToResponse(state, freezeCount), nil
}

func (s *Store) UpdateWeeklyGoal(ctx context.Context, userID int64, goal int) error {
	if goal < 1 || goal > 7 {
		return fmt.Errorf("weekly goal must be between 1 and 7")
	}

	if err := s.perksBase.EnsureUser(ctx, userID); err != nil {
		return err
	}

	state, err := s.getState(ctx, userID)
	if err != nil {
		return err
	}

	state = s.calculator.RecalculateCurrentWeek(state, time.Now())
	state = s.calculator.ScheduleWeeklyGoal(state, goal)

	return s.saveState(ctx, userID, state)
}

func (s *Store) UseFreeze(ctx context.Context, userID int64) error {
	if err := s.perksBase.EnsureUser(ctx, userID); err != nil {
		return err
	}

	tx, err := s.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	var freezeID int64
	err = tx.GetContext(ctx, &freezeID, `
		SELECT id
		FROM streak_freezes
		WHERE user_id = $1 AND status = 'available'
		ORDER BY created_at ASC
		LIMIT 1
		FOR UPDATE
	`, userID)
	if err != nil {
		return fmt.Errorf("no available streak freeze")
	}

	var state State
	err = tx.GetContext(ctx, &state, `
		SELECT
			current_streak_weeks AS "currentstreakweeks",
			best_streak_weeks AS "beststreakweeks",
			weekly_goal AS "weeklygoal",
			next_weekly_goal AS "nextweeklygoal",
			completed_this_week AS "completedthisweek",
			remaining_to_goal AS "remainingtogoal",
			week_start_date AS "weekstartdate",
			week_end_date AS "weekenddate",
			is_goal_completed AS "isgoalcompleted",
			was_freeze_used_this_week AS "wasfreezeusedthisweek"
		FROM user_streaks
		WHERE user_id = $1
		FOR UPDATE
	`, userID)
	if err != nil {
		return err
	}

	state = s.calculator.ApplyFreeze(state, time.Now())

	_, err = tx.ExecContext(ctx, `
		UPDATE streak_freezes
		SET status = 'used',
		    used_week_start_date = $2,
		    used_at = NOW()
		WHERE id = $1
	`, freezeID, state.WeekStartDate)
	if err != nil {
		return err
	}

	_, err = tx.ExecContext(ctx, `
		UPDATE user_streaks
		SET
			current_streak_weeks = $2,
			best_streak_weeks = $3,
			weekly_goal = $4,
			next_weekly_goal = $5,
			completed_this_week = $6,
			remaining_to_goal = $7,
			week_start_date = $8,
			week_end_date = $9,
			is_goal_completed = $10,
			was_freeze_used_this_week = $11,
			updated_at = NOW()
		WHERE user_id = $1
	`,
		userID,
		state.CurrentStreakWeeks,
		state.BestStreakWeeks,
		state.WeeklyGoal,
		state.NextWeeklyGoal,
		state.CompletedThisWeek,
		state.RemainingToGoal,
		state.WeekStartDate,
		state.WeekEndDate,
		state.IsGoalCompleted,
		state.WasFreezeUsedThisWeek,
	)
	if err != nil {
		return err
	}

	return tx.Commit()
}

func (s *Store) ApplyWorkoutCompleted(ctx context.Context, userID int64) error {
	if err := s.perksBase.EnsureUser(ctx, userID); err != nil {
		return err
	}

	state, err := s.getState(ctx, userID)
	if err != nil {
		return err
	}

	state = s.calculator.ApplyWorkoutCompleted(state, time.Now())

	return s.saveState(ctx, userID, state)
}

func (s *Store) saveState(ctx context.Context, userID int64, state State) error {
	_, err := s.db.ExecContext(ctx, `
		UPDATE user_streaks
		SET
			current_streak_weeks = $2,
			best_streak_weeks = $3,
			weekly_goal = $4,
			next_weekly_goal = $5,
			completed_this_week = $6,
			remaining_to_goal = $7,
			week_start_date = $8,
			week_end_date = $9,
			is_goal_completed = $10,
			was_freeze_used_this_week = $11,
			updated_at = NOW()
		WHERE user_id = $1
	`,
		userID,
		state.CurrentStreakWeeks,
		state.BestStreakWeeks,
		state.WeeklyGoal,
		state.NextWeeklyGoal,
		state.CompletedThisWeek,
		state.RemainingToGoal,
		state.WeekStartDate,
		state.WeekEndDate,
		state.IsGoalCompleted,
		state.WasFreezeUsedThisWeek,
	)

	return err
}

func (s *Store) getState(ctx context.Context, userID int64) (State, error) {
	var state State

	err := s.db.GetContext(ctx, &state, `
		SELECT
			current_streak_weeks AS "currentstreakweeks",
			best_streak_weeks AS "beststreakweeks",
			weekly_goal AS "weeklygoal",
			next_weekly_goal AS "nextweeklygoal",
			completed_this_week AS "completedthisweek",
			remaining_to_goal AS "remainingtogoal",
			week_start_date AS "weekstartdate",
			week_end_date AS "weekenddate",
			is_goal_completed AS "isgoalcompleted",
			was_freeze_used_this_week AS "wasfreezeusedthisweek"
		FROM user_streaks
		WHERE user_id = $1
	`, userID)

	return state, err
}

func (s *Store) getAvailableFreezeCount(ctx context.Context, userID int64) (int, error) {
	var freezeCount int

	err := s.db.GetContext(ctx, &freezeCount, `
		SELECT COUNT(*)
		FROM streak_freezes
		WHERE user_id = $1 AND status = 'available'
	`, userID)

	return freezeCount, err
}

func stateToResponse(state State, freezeCount int) types.StreakResponse {
	return types.StreakResponse{
		CurrentStreakWeeks:    state.CurrentStreakWeeks,
		BestStreakWeeks:       state.BestStreakWeeks,
		WeeklyGoal:            state.WeeklyGoal,
		NextWeeklyGoal:        state.NextWeeklyGoal,
		CompletedThisWeek:     state.CompletedThisWeek,
		RemainingToGoal:       state.RemainingToGoal,
		WeekStartDate:         state.WeekStartDate,
		WeekEndDate:           state.WeekEndDate,
		IsGoalCompleted:       state.IsGoalCompleted,
		StreakFreezeCount:     freezeCount,
		CanUseStreakFreeze:    freezeCount > 0 && !state.WasFreezeUsedThisWeek,
		WasFreezeUsedThisWeek: state.WasFreezeUsedThisWeek,
	}
}