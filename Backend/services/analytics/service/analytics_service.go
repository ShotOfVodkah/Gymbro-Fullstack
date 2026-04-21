package service

import (
	"context"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
	"github.com/alexandra-gritsaenko/gymbro-analytics/store"
	"github.com/alexandra-gritsaenko/gymbro-analytics/validator"
	"github.com/google/uuid"
)

type AnalyticsService struct {
	store     *store.AnalyticsStore
	validator *validator.EventValidator
}

func NewAnalyticsService(store *store.AnalyticsStore) *AnalyticsService {
	return &AnalyticsService{
		store:     store,
		validator: validator.New(),
	}
}

func (s *AnalyticsService) IngestBatch(
	ctx context.Context,
	requestID string,
	userID int64,
	events []models.AnalyticsEventDTO,
) (*models.IngestBatchResponse, error) {
	if err := s.validator.ValidateBatch(events); err != nil {
		return nil, err
	}

	batchFingerprint := BuildBatchFingerprint(userID, events)

	existingBatchID, found, err := s.store.FindBatchByFingerprint(ctx, batchFingerprint)
	if err != nil {
		return nil, err
	}
	if found {
		return &models.IngestBatchResponse{
			BatchID:      existingBatchID,
			Accepted:     0,
			Rejected:     0,
			Deduplicated: len(events),
		}, nil
	}

	batchID := uuid.NewString()

	prepared := make([]models.IngestedEvent, 0, len(events))
	accepted := 0
	rejected := 0

	for _, event := range events {
		valid, reason, rawSize, propsSize := s.validator.ValidateEvent(event)

		normalized := normalizeEvent(userID, event)
		normalized.IsValid = valid
		normalized.RejectReason = reason
		normalized.RawPayloadSize = rawSize
		normalized.PropertiesSize = propsSize
		normalized.NormalizedName = models.NormalizeEventName(event.EventName)
		normalized.NormalizedPlatform = event.Platform

		if valid {
			accepted++
		} else {
			rejected++
		}

		prepared = append(prepared, normalized)
	}

	result, err := s.store.SaveBatch(ctx, requestID, batchID, batchFingerprint, userID, prepared)
	if err != nil {
		return nil, err
	}

	return &models.IngestBatchResponse{
		BatchID:      batchID,
		Accepted:     result.InsertedEvents,
		Rejected:     rejected,
		Deduplicated: result.DeduplicatedEvents,
	}, nil
}

func normalizeEvent(userID int64, event models.AnalyticsEventDTO) models.IngestedEvent {
	if event.Properties == nil {
		event.Properties = map[string]string{}
	}

	normalizedTime := event.Timestamp.UTC()
	eventDate := normalizedTime.Format("2006-01-02")

	var screen *string
	if v, ok := event.Properties["screen"]; ok && v != "" {
		screen = &v
	}

	entityType, entityID := extractEntity(event.Properties)

	def, ok := models.ResolveEventDefinition(event.EventName)
	if !ok {
		def = models.EventDefinition{
			Name:         event.EventName,
			Category:     "other",
			IsErrorEvent: false,
		}
	}

	return models.IngestedEvent{
		Event:              event,
		EventDate:          eventDate,
		Screen:             screen,
		EventCategory:      def.Category,
		IsErrorEvent:       def.IsErrorEvent,
		EntityType:         entityType,
		EntityID:           entityID,
		NormalizedTime:     normalizedTime,
		NormalizedName:     models.NormalizeEventName(event.EventName),
		NormalizedPlatform: event.Platform,
		EventFingerprint:   BuildEventFingerprint(userID, event),
	}
}

func extractEntity(properties map[string]string) (*string, *string) {
	if v, ok := properties["post_id"]; ok && v != "" {
		t := "post"
		return &t, &v
	}
	if v, ok := properties["workout_id"]; ok && v != "" {
		t := "workout"
		return &t, &v
	}
	if v, ok := properties["person_id"]; ok && v != "" {
		t := "person"
		return &t, &v
	}
	if v, ok := properties["community_id"]; ok && v != "" {
		t := "community"
		return &t, &v
	}
	if v, ok := properties["target_user_id"]; ok && v != "" {
		t := "user"
		return &t, &v
	}
	return nil, nil
}