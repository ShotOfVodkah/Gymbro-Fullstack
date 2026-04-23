package models

type DemoDashboardResponse struct {
	GeneratedAt     string                        `json:"generated_at"`
	Overview        *DemoOverviewSection          `json:"overview"`
	Engagement      *DemoEngagementSection        `json:"engagement"`
	Retention       *DemoRetentionSection         `json:"retention"`
	Funnels         *DemoFunnelsSection           `json:"funnels"`
	FeatureAdoption *DemoFeatureAdoptionSection   `json:"feature_adoption"`
	Reliability     *DemoReliabilitySection       `json:"reliability"`
	Research        *DemoResearchSection          `json:"research"`
	Admin           *DemoAdminSection             `json:"admin"`
}

type DemoOverviewSection struct {
	Summary         *DashboardOverviewMVItem `json:"summary"`
	TopScreens      []ScreenMetricItem      `json:"top_screens"`
	TopEvents       []TopEventItem           `json:"top_events"`
	AppVersions     []AppVersionDailyItem    `json:"app_versions"`
}

type DemoEngagementSection struct {
	AverageActiveDaysLast7   float64 `db:"average_active_days_last_7" json:"average_active_days_last_7"`
	AverageActiveDaysLast30  float64 `db:"average_active_days_last_30" json:"average_active_days_last_30"`
	AverageSessionsPerUser   float64 `db:"average_sessions_per_user" json:"average_sessions_per_user"`
	UsersWithWorkoutActivity int     `db:"users_with_workout_activity" json:"users_with_workout_activity"`
	UsersWithSocialActivity  int     `db:"users_with_social_activity" json:"users_with_social_activity"`
}

type DemoRetentionSection struct {
	Cohorts []RetentionCohortItem `json:"cohorts"`
}

type DemoFunnelsSection struct {
	WorkoutShare                   []FunnelDailyItem `json:"workout_share"`
	RegistrationToFirstWorkout     []FunnelDailyItem `json:"registration_to_first_workout"`
	FeedsOpenToInteraction         []FunnelDailyItem `json:"feeds_open_to_interaction"`
	ProfileOpenToRelationshipAction []FunnelDailyItem `json:"profile_open_to_relationship_action"`
}

type DemoFeatureAdoptionSection struct {
	FeatureUsage []FeatureUsageDailyItem `json:"feature_usage"`
}

type DemoReliabilitySection struct {
	ErrorMetrics       []ErrorMetricItem       `json:"error_metrics"`
	DataQualitySummary *DataQualityOverviewItem `json:"data_quality_summary"`
	DataQualityByApp   []DataQualityDailyItem   `json:"data_quality_by_app_version"`
}

type DemoResearchSection struct {
	SocialVsNonSocial           *ResearchComparisonResponse `json:"social_vs_non_social"`
	SharingVsNonSharing         *ResearchComparisonResponse `json:"sharing_vs_non_sharing"`
	WorkoutCompletionEngagement *ResearchComparisonResponse `json:"workout_completion_engagement"`
	ErrorsVsDropoff             *ResearchComparisonResponse `json:"errors_vs_dropoff"`
	FeatureRetention            *ResearchFeatureRetentionResponse `json:"feature_retention"`
}

type DemoAdminSection struct {
	PipelineOverview *PipelineOverviewItem `json:"pipeline_overview"`
	RecentInvalid    []InvalidEventItem    `json:"recent_invalid_events"`
}