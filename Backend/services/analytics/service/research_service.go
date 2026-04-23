package service

import (
	"context"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
	"github.com/alexandra-gritsaenko/gymbro-analytics/store"
)

type ResearchService struct {
	store *store.AnalyticsStore
}

func NewResearchService(store *store.AnalyticsStore) *ResearchService {
	return &ResearchService{
		store: store,
	}
}

func (s *ResearchService) GetSocialVsNonSocial(ctx context.Context) (*models.ResearchComparisonResponse, error) {
	return s.store.GetResearchSocialVsNonSocial(ctx)
}

func (s *ResearchService) GetSharingVsNonSharing(ctx context.Context) (*models.ResearchComparisonResponse, error) {
	return s.store.GetResearchSharingVsNonSharing(ctx)
}

func (s *ResearchService) GetWorkoutCompletionEngagement(ctx context.Context) (*models.ResearchComparisonResponse, error) {
	return s.store.GetResearchWorkoutCompletionEngagement(ctx)
}

func (s *ResearchService) GetErrorsVsDropoff(ctx context.Context) (*models.ResearchComparisonResponse, error) {
	return s.store.GetResearchErrorsVsDropoff(ctx)
}

func (s *ResearchService) GetFeatureRetention(ctx context.Context) (*models.ResearchFeatureRetentionResponse, error) {
	return s.store.GetResearchFeatureRetention(ctx)
}