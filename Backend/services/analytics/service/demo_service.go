package service

import (
	"context"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
	"github.com/alexandra-gritsaenko/gymbro-analytics/store"
)

type DemoService struct {
	store *store.AnalyticsStore
}

func NewDemoService(store *store.AnalyticsStore) *DemoService {
	return &DemoService{
		store: store,
	}
}

func (s *DemoService) GetDashboard(ctx context.Context) (*models.DemoDashboardResponse, error) {
	overview, err := s.buildOverviewSection(ctx)
	if err != nil {
		return nil, err
	}

	engagement, err := s.buildEngagementSection(ctx)
	if err != nil {
		return nil, err
	}

	retention, err := s.buildRetentionSection(ctx)
	if err != nil {
		return nil, err
	}

	funnels, err := s.buildFunnelsSection(ctx)
	if err != nil {
		return nil, err
	}

	featureAdoption, err := s.buildFeatureAdoptionSection(ctx)
	if err != nil {
		return nil, err
	}

	reliability, err := s.buildReliabilitySection(ctx)
	if err != nil {
		return nil, err
	}

	research, err := s.buildResearchSection(ctx)
	if err != nil {
		return nil, err
	}

	admin, err := s.buildAdminSection(ctx)
	if err != nil {
		return nil, err
	}

	return &models.DemoDashboardResponse{
		GeneratedAt:     time.Now().UTC().Format(time.RFC3339),
		Overview:        overview,
		Engagement:      engagement,
		Retention:       retention,
		Funnels:         funnels,
		FeatureAdoption: featureAdoption,
		Reliability:     reliability,
		Research:        research,
		Admin:           admin,
	}, nil
}

func (s *DemoService) buildOverviewSection(ctx context.Context) (*models.DemoOverviewSection, error) {
	summary, err := s.store.GetDashboardOverviewFast(ctx)
	if err != nil {
		return nil, err
	}

	topScreens, err := s.store.GetScreenMetrics(ctx)
	if err != nil {
		return nil, err
	}

	topEvents, err := s.store.GetTopEvents(ctx)
	if err != nil {
		return nil, err
	}

	appVersions, err := s.store.GetLatestAppVersions(ctx)
	if err != nil {
		return nil, err
	}

	return &models.DemoOverviewSection{
		Summary:     summary,
		TopScreens:  topScreens,
		TopEvents:   topEvents,
		AppVersions: appVersions,
	}, nil
}

func (s *DemoService) buildEngagementSection(ctx context.Context) (*models.DemoEngagementSection, error) {
	return s.store.GetDemoEngagementSection(ctx)
}

func (s *DemoService) buildRetentionSection(ctx context.Context) (*models.DemoRetentionSection, error) {
	cohorts, err := s.store.GetRetentionCohorts(ctx)
	if err != nil {
		return nil, err
	}

	return &models.DemoRetentionSection{
		Cohorts: cohorts,
	}, nil
}

func (s *DemoService) buildFunnelsSection(ctx context.Context) (*models.DemoFunnelsSection, error) {
	workoutShare, err := s.store.GetLatestFunnel(ctx, "workout_share")
	if err != nil {
		return nil, err
	}

	registration, err := s.store.GetLatestFunnel(ctx, "registration_to_first_workout")
	if err != nil {
		return nil, err
	}

	feeds, err := s.store.GetLatestFunnel(ctx, "feeds_open_to_interaction")
	if err != nil {
		return nil, err
	}

	profile, err := s.store.GetLatestFunnel(ctx, "profile_open_to_relationship_action")
	if err != nil {
		return nil, err
	}

	return &models.DemoFunnelsSection{
		WorkoutShare:                    workoutShare,
		RegistrationToFirstWorkout:      registration,
		FeedsOpenToInteraction:          feeds,
		ProfileOpenToRelationshipAction: profile,
	}, nil
}

func (s *DemoService) buildFeatureAdoptionSection(ctx context.Context) (*models.DemoFeatureAdoptionSection, error) {
	items, err := s.store.GetFeatureUsageDailyLatest(ctx)
	if err != nil {
		return nil, err
	}

	return &models.DemoFeatureAdoptionSection{
		FeatureUsage: items,
	}, nil
}

func (s *DemoService) buildReliabilitySection(ctx context.Context) (*models.DemoReliabilitySection, error) {
	errorMetrics, err := s.store.GetErrorMetrics(ctx)
	if err != nil {
		return nil, err
	}

	dataQualitySummary, err := s.store.GetDataQualityOverview(ctx)
	if err != nil {
		return nil, err
	}

	dataQualityByApp, err := s.store.GetDataQualityByAppVersion(ctx)
	if err != nil {
		return nil, err
	}

	return &models.DemoReliabilitySection{
		ErrorMetrics:       errorMetrics,
		DataQualitySummary: dataQualitySummary,
		DataQualityByApp:   dataQualityByApp,
	}, nil
}

func (s *DemoService) buildResearchSection(ctx context.Context) (*models.DemoResearchSection, error) {
	socialVsNonSocial, err := s.store.GetResearchSocialVsNonSocial(ctx)
	if err != nil {
		return nil, err
	}

	sharingVsNonSharing, err := s.store.GetResearchSharingVsNonSharing(ctx)
	if err != nil {
		return nil, err
	}

	workoutCompletionEngagement, err := s.store.GetResearchWorkoutCompletionEngagement(ctx)
	if err != nil {
		return nil, err
	}

	errorsVsDropoff, err := s.store.GetResearchErrorsVsDropoff(ctx)
	if err != nil {
		return nil, err
	}

	featureRetention, err := s.store.GetResearchFeatureRetention(ctx)
	if err != nil {
		return nil, err
	}

	return &models.DemoResearchSection{
		SocialVsNonSocial:           socialVsNonSocial,
		SharingVsNonSharing:         sharingVsNonSharing,
		WorkoutCompletionEngagement: workoutCompletionEngagement,
		ErrorsVsDropoff:             errorsVsDropoff,
		FeatureRetention:            featureRetention,
	}, nil
}

func (s *DemoService) buildAdminSection(ctx context.Context) (*models.DemoAdminSection, error) {
	pipelineOverview, err := s.store.GetPipelineOverview(ctx)
	if err != nil {
		return nil, err
	}

	recentInvalid, err := s.store.GetInvalidEvents(ctx, 10)
	if err != nil {
		return nil, err
	}

	return &models.DemoAdminSection{
		PipelineOverview: pipelineOverview,
		RecentInvalid:    recentInvalid,
	}, nil
}