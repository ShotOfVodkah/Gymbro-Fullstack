package service

import (
	"context"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
	"github.com/alexandra-gritsaenko/gymbro-analytics/store"
)

type QueryService struct {
	store *store.AnalyticsStore
}

func NewQueryService(store *store.AnalyticsStore) *QueryService {
	return &QueryService{
		store: store,
	}
}

func (s *QueryService) GetOverview(ctx context.Context) (*models.OverviewResponse, error) {
	return s.store.GetOverviewMetrics(ctx)
}

func (s *QueryService) GetErrors(ctx context.Context) (*models.ErrorsResponse, error) {
	items, err := s.store.GetErrorMetrics(ctx)
	if err != nil {
		return nil, err
	}
	return &models.ErrorsResponse{Items: items}, nil
}

func (s *QueryService) GetScreens(ctx context.Context) (*models.ScreensResponse, error) {
	items, err := s.store.GetScreenMetrics(ctx)
	if err != nil {
		return nil, err
	}
	return &models.ScreensResponse{Items: items}, nil
}

func (s *QueryService) GetTopEvents(ctx context.Context) (*models.TopEventsResponse, error) {
	items, err := s.store.GetTopEvents(ctx)
	if err != nil {
		return nil, err
	}
	return &models.TopEventsResponse{Items: items}, nil
}

func (s *QueryService) GetFeatureUsage(ctx context.Context) (*models.FeatureUsageResponse, error) {
	items, err := s.store.GetFeatureUsageDailyLatest(ctx)
	if err != nil {
		return nil, err
	}
	return &models.FeatureUsageResponse{Items: items}, nil
}

func (s *QueryService) getFunnel(ctx context.Context, funnelName string) (*models.FunnelResponse, error) {
	items, err := s.store.GetLatestFunnel(ctx, funnelName)
	if err != nil {
		return nil, err
	}

	response := &models.FunnelResponse{
		FunnelName: funnelName,
		Items:      items,
	}

	if len(items) > 0 {
		response.EventDate = items[0].EventDate
	}

	return response, nil
}

func (s *QueryService) GetWorkoutShareFunnel(ctx context.Context) (*models.FunnelResponse, error) {
	return s.getFunnel(ctx, "workout_share")
}

func (s *QueryService) GetRegistrationToFirstWorkoutFunnel(ctx context.Context) (*models.FunnelResponse, error) {
	return s.getFunnel(ctx, "registration_to_first_workout")
}

func (s *QueryService) GetFeedsOpenToInteractionFunnel(ctx context.Context) (*models.FunnelResponse, error) {
	return s.getFunnel(ctx, "feeds_open_to_interaction")
}

func (s *QueryService) GetProfileOpenToRelationshipActionFunnel(ctx context.Context) (*models.FunnelResponse, error) {
	return s.getFunnel(ctx, "profile_open_to_relationship_action")
}

func (s *QueryService) GetRetentionCohorts(ctx context.Context) (*models.RetentionCohortsResponse, error) {
	items, err := s.store.GetRetentionCohorts(ctx)
	if err != nil {
		return nil, err
	}
	return &models.RetentionCohortsResponse{Items: items}, nil
}

func (s *QueryService) GetAppVersions(ctx context.Context) (*models.AppVersionsResponse, error) {
	items, err := s.store.GetLatestAppVersions(ctx)
	if err != nil {
		return nil, err
	}
	return &models.AppVersionsResponse{Items: items}, nil
}

func (s *QueryService) GetUserSummary(ctx context.Context, userID int64) (*models.UserSummaryResponse, error) {
	item, err := s.store.GetUserSummary(ctx, userID)
	if err != nil {
		return nil, err
	}
	return &models.UserSummaryResponse{Item: item}, nil
}