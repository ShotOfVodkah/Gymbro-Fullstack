package service

import (
	"context"

	"github.com/alexandra-gritsaenko/gymbro-perks/achievements"
	"github.com/alexandra-gritsaenko/gymbro-perks/types"
)

type EventProcessor struct {
	streakStore      StreakUpdater
	achievementStore AchievementUpdater
	userStatsUpdater UserStatsUpdater
	engine           *achievements.AchievementEngine
}

type StreakUpdater interface {
	ApplyWorkoutCompleted(ctx context.Context, userID int64) error
}

type AchievementUpdater interface {
	GetProgressMaps(ctx context.Context, userID int64) (map[string]int, map[string]int, error)
	ApplyProgressUpdates(ctx context.Context, userID int64, updates []achievements.AchievementProgressUpdate) error
}

type UserStatsUpdater interface {
	IncrementCompletedWorkouts(ctx context.Context, userID int64) error
}

func NewEventProcessor(
	streakStore StreakUpdater,
	achievementStore AchievementUpdater,
	userStatsUpdater UserStatsUpdater,
	engine *achievements.AchievementEngine,
) *EventProcessor {
	return &EventProcessor{
		streakStore:       streakStore,
		achievementStore: achievementStore,
		userStatsUpdater:  userStatsUpdater,
		engine:            engine,
	}
}

func (p *EventProcessor) Process(
	ctx context.Context,
	userID int64,
	request types.PerksEventRequest,
) error {
	event := achievements.PerkEvent{
		Type:     request.Type,
		Metadata: request.Metadata,
	}

	if event.Metadata == nil {
		event.Metadata = map[string]string{}
	}

	if event.Type == "workout_completed" {
		if err := p.streakStore.ApplyWorkoutCompleted(ctx, userID); err != nil {
			return err
		}

		if err := p.userStatsUpdater.IncrementCompletedWorkouts(ctx, userID); err != nil {
			return err
		}
	}

	currentProgress, targetProgress, err := p.achievementStore.GetProgressMaps(ctx, userID)
	if err != nil {
		return err
	}

	updates := p.engine.Evaluate(
		event,
		currentProgress,
		targetProgress,
	)

	return p.achievementStore.ApplyProgressUpdates(ctx, userID, updates)
}