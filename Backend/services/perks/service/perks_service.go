package service

import (
	"context"

	"github.com/alexandra-gritsaenko/gymbro-perks/achievements"
	"github.com/alexandra-gritsaenko/gymbro-perks/leaderboard"
	"github.com/alexandra-gritsaenko/gymbro-perks/store"
	"github.com/alexandra-gritsaenko/gymbro-perks/streak"
	"github.com/alexandra-gritsaenko/gymbro-perks/types"
)

type PerksService struct {
	baseStore        *store.PerksStore
	streakStore      *streak.Store
	achievementStore *achievements.Store
	leaderboardStore *leaderboard.Store
	eventProcessor 	 *EventProcessor
}

func NewPerksService(
	baseStore *store.PerksStore,
	streakStore *streak.Store,
	achievementStore *achievements.Store,
	leaderboardStore *leaderboard.Store,
) *PerksService {
	engine := achievements.NewAchievementEngine()

	eventProcessor := NewEventProcessor(
		streakStore,
		achievementStore,
		baseStore,
		engine,
	)

	return &PerksService{
		baseStore:        baseStore,
		streakStore:      streakStore,
		achievementStore: achievementStore,
		leaderboardStore: leaderboardStore,
		eventProcessor:   eventProcessor,
	}
}

func (s *PerksService) GetDashboard(ctx context.Context, userID int64) (types.PerksDashboardResponse, error) {
	if err := s.baseStore.EnsureUser(ctx, userID); err != nil {
		return types.PerksDashboardResponse{}, err
	}

	streakState, err := s.streakStore.GetStreak(ctx, userID)
	if err != nil {
		return types.PerksDashboardResponse{}, err
	}

	achievementsList, err := s.achievementStore.GetAchievements(ctx, userID)
	if err != nil {
		return types.PerksDashboardResponse{}, err
	}

	leaderboardList, err := s.leaderboardStore.GetLeaderboard(ctx, userID, "all", "streak")
	if err != nil {
		return types.PerksDashboardResponse{}, err
	}

	return types.PerksDashboardResponse{
		Streak:             streakState,
		RecentUnlocks:      recentUnlocks(achievementsList),
		Achievements:        achievementsList,
		LeaderboardPreview: leaderboardList,
		MyRank:             findMyRank(leaderboardList),
	}, nil
}

func (s *PerksService) GetStreak(ctx context.Context, userID int64) (types.StreakResponse, error) {
	return s.streakStore.GetStreak(ctx, userID)
}

func (s *PerksService) UpdateWeeklyGoal(ctx context.Context, userID int64, goal int) (types.PerksDashboardResponse, error) {
	if err := s.streakStore.UpdateWeeklyGoal(ctx, userID, goal); err != nil {
		return types.PerksDashboardResponse{}, err
	}

	return s.GetDashboard(ctx, userID)
}

func (s *PerksService) UseStreakFreeze(ctx context.Context, userID int64) (types.PerksDashboardResponse, error) {
	if err := s.streakStore.UseFreeze(ctx, userID); err != nil {
		return types.PerksDashboardResponse{}, err
	}

	return s.GetDashboard(ctx, userID)
}

func (s *PerksService) GetAchievements(ctx context.Context, userID int64) ([]types.AchievementResponse, error) {
	return s.achievementStore.GetAchievements(ctx, userID)
}

func (s *PerksService) GetLeaderboard(ctx context.Context, userID int64, filter string, sort string) ([]types.LeaderboardResponse, error) {
	return s.leaderboardStore.GetLeaderboard(ctx, userID, filter, sort)
}

func (s *PerksService) SaveEvent(ctx context.Context, userID int64, request types.PerksEventRequest) error {
	if err := s.baseStore.SaveEvent(ctx, userID, request); err != nil {
		return err
	}
	return s.eventProcessor.Process(ctx, userID, request)
}

func recentUnlocks(achievements []types.AchievementResponse) []types.AchievementResponse {
	result := make([]types.AchievementResponse, 0, 3)

	for _, achievement := range achievements {
		if achievement.Status == "unlocked" {
			result = append(result, achievement)
		}

		if len(result) == 3 {
			break
		}
	}

	return result
}

func findMyRank(entries []types.LeaderboardResponse) *types.MyRankResponse {
	for _, entry := range entries {
		if entry.IsCurrentUser {
			return &types.MyRankResponse{
				Rank:               entry.Rank,
				CurrentStreakWeeks: entry.CurrentStreakWeeks,
				CompletedWorkouts:  entry.CompletedWorkouts,
			}
		}
	}

	return nil
}