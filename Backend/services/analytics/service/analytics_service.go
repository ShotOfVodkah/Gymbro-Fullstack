package service

import (
	"context"
	"time"

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
		safeEvent := SanitizeEventForStorage(event)
		valid, reason, rawSize, propsSize := s.validator.ValidateEvent(safeEvent)

		normalized := normalizeEvent(userID, safeEvent)
		normalized.IsValid = valid
		normalized.RejectReason = reason
		normalized.RawPayloadSize = rawSize
		normalized.PropertiesSize = propsSize
		normalized.NormalizedName = models.NormalizeEventName(safeEvent.EventName)
		normalized.NormalizedPlatform = safeEvent.Platform

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

	qualityDates := []string{time.Now().UTC().Format("2006-01-02")}
	if err := s.store.RebuildDataQualityDailyForDates(ctx, qualityDates); err != nil {
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

	entities := ExtractEntities(event.Properties)

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

		EntityType:         entities.EntityType,
		EntityID:           entities.EntityID,

		WorkoutID:          entities.WorkoutID,
		PostID:             entities.PostID,
		PersonID:           entities.PersonID,
		TargetUserID:       entities.TargetUserID,
		CommunityID:        entities.CommunityID,

		NormalizedTime:     normalizedTime,
		NormalizedName:     models.NormalizeEventName(event.EventName),
		NormalizedPlatform: event.Platform,
		EventFingerprint:   BuildEventFingerprint(userID, event),
	}
}
