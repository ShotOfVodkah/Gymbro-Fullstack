package aggregator

import (
	"context"
	"encoding/json"
	"sort"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
	"github.com/alexandra-gritsaenko/gymbro-analytics/store"
)

type Aggregator struct {
	store *store.AnalyticsStore
}

func New(store *store.AnalyticsStore) *Aggregator {
	return &Aggregator{
		store: store,
	}
}

func (a *Aggregator) Aggregate(ctx context.Context, events []models.ProcessableEvent) error {
	if len(events) == 0 {
		return nil
	}

	sessionSummaries := buildSessionSummaries(events)
	if err := a.store.UpsertSessions(ctx, sessionSummaries); err != nil {
		return err
	}

	affectedDates := extractAffectedDates(events)

	if err := a.store.RebuildDailyAggregatesForDates(ctx, affectedDates); err != nil {
		return err
	}

	if err := a.store.RebuildFunnelsForDates(ctx, affectedDates); err != nil {
		return err
	}

	if err := a.store.RebuildRetentionCohorts(ctx); err != nil {
		return err
	}

	if err := a.store.RebuildAppVersionDailyForDates(ctx, affectedDates); err != nil {
		return err
	}

	affectedUserIDs := extractAffectedUserIDs(events)
	if err := a.store.RebuildUserSummaries(ctx, affectedUserIDs); err != nil {
		return err
	}

	if err := a.store.RebuildPipelineDaily(ctx); err != nil {
		return err
	}

	for _, event := range events {
		var properties map[string]string
		if len(event.Properties) > 0 {
			_ = json.Unmarshal(event.Properties, &properties)
		}
	}

	return nil
}

func buildSessionSummaries(events []models.ProcessableEvent) []models.SessionSummary {
	type sessionKey struct {
		UserID    int64
		SessionID string
	}

	grouped := make(map[sessionKey][]models.ProcessableEvent)

	for _, event := range events {
		key := sessionKey{
			UserID:    event.UserID,
			SessionID: event.SessionID,
		}
		grouped[key] = append(grouped[key], event)
	}

	summaries := make([]models.SessionSummary, 0, len(grouped))

	for key, sessionEvents := range grouped {
		sort.Slice(sessionEvents, func(i, j int) bool {
			return sessionEvents[i].EventTime.Before(sessionEvents[j].EventTime)
		})

		startedAt := sessionEvents[0].EventTime
		endedAt := sessionEvents[0].EventTime

		screens := map[string]struct{}{}

		var hasError bool
		var hasNavigation bool
		var hasWorkout bool
		var hasSocial bool
		var hasChat bool
		var hasCalendar bool
		var hasProfile bool
		var hasSettings bool
		var hasSharing bool

		platform := sessionEvents[0].Platform
		appVersion := sessionEvents[0].AppVersion

		for _, event := range sessionEvents {
			if event.EventTime.Before(startedAt) {
				startedAt = event.EventTime
			}
			if event.EventTime.After(endedAt) {
				endedAt = event.EventTime
			}

			if event.Screen != nil && *event.Screen != "" {
				screens[*event.Screen] = struct{}{}
			}

			if event.IsErrorEvent {
				hasError = true
			}

			category := ""
			if event.EventCategory != nil {
				category = *event.EventCategory
			}

			switch category {
			case "navigation":
				hasNavigation = true
			case "workout":
				hasWorkout = true
			case "social":
				hasSocial = true
			case "chat":
				hasChat = true
			case "calendar":
				hasCalendar = true
			case "profile":
				hasProfile = true
			case "settings":
				hasSettings = true
			case "sharing":
				hasSharing = true
			}
		}

		durationSeconds := int64(endedAt.Sub(startedAt).Seconds())
		if durationSeconds < 0 {
			durationSeconds = 0
		}

		summaries = append(summaries, models.SessionSummary{
			UserID:                key.UserID,
			SessionID:             key.SessionID,
			StartedAt:             startedAt,
			EndedAt:               endedAt,
			DurationSeconds:       durationSeconds,
			EventsCount:           len(sessionEvents),
			UniqueScreensCount:    len(screens),
			HasError:              hasError,
			HasNavigationActivity: hasNavigation,
			HasWorkoutActivity:    hasWorkout,
			HasSocialActivity:     hasSocial,
			HasChatActivity:       hasChat,
			HasCalendarActivity:   hasCalendar,
			HasProfileActivity:    hasProfile,
			HasSettingsActivity:   hasSettings,
			HasSharingActivity:    hasSharing,
			ActivityType:          resolveSessionActivityType(hasNavigation, hasWorkout, hasSocial, hasChat, hasCalendar, hasProfile, hasSettings, hasSharing),
			Platform:              platform,
			AppVersion:            appVersion,
		})
	}

	return summaries
}

func resolveSessionActivityType(
	hasNavigation bool,
	hasWorkout bool,
	hasSocial bool,
	hasChat bool,
	hasCalendar bool,
	hasProfile bool,
	hasSettings bool,
	hasSharing bool,
) string {
	activeCount := 0
	lastType := "unknown"

	if hasWorkout {
		activeCount++
		lastType = "workout"
	}
	if hasSocial {
		activeCount++
		lastType = "social"
	}
	if hasChat {
		activeCount++
		lastType = "chat"
	}
	if hasCalendar {
		activeCount++
		lastType = "calendar"
	}
	if hasProfile {
		activeCount++
		lastType = "profile"
	}
	if hasSettings {
		activeCount++
		lastType = "settings"
	}
	if hasSharing {
		activeCount++
		lastType = "sharing"
	}
	if activeCount == 0 && hasNavigation {
		return "navigation_only"
	}
	if activeCount > 1 {
		return "mixed"
	}
	if activeCount == 1 {
		return lastType
	}
	return "unknown"
}

func extractAffectedDates(events []models.ProcessableEvent) []string {
	seen := map[string]struct{}{}
	result := make([]string, 0)

	for _, event := range events {
		if _, ok := seen[event.EventDate]; ok {
			continue
		}
		seen[event.EventDate] = struct{}{}
		result = append(result, event.EventDate)
	}

	sort.Strings(result)
	return result
}

func extractAffectedUserIDs(events []models.ProcessableEvent) []int64 {
	seen := map[int64]struct{}{}
	result := make([]int64, 0)

	for _, event := range events {
		if _, ok := seen[event.UserID]; ok {
			continue
		}
		seen[event.UserID] = struct{}{}
		result = append(result, event.UserID)
	}

	sort.Slice(result, func(i, j int) bool {
		return result[i] < result[j]
	})

	return result
}