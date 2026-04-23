package store

import (
	"context"
	"database/sql"
	"encoding/json"
	"strings"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
	"github.com/jmoiron/sqlx"
	"github.com/lib/pq"
)

type AnalyticsStore struct {
	db *sqlx.DB
}

type SaveBatchResult struct {
	InsertedEvents     int
	DeduplicatedEvents int
}

func NewAnalyticsStore(db *sqlx.DB) *AnalyticsStore {
	return &AnalyticsStore{
		db: db,
	}
}

func (s *AnalyticsStore) FindBatchByFingerprint(ctx context.Context, batchFingerprint string) (string, bool, error) {
	var batchID string
	err := s.db.GetContext(ctx, &batchID, `
		SELECT batch_id
		FROM analytics_event_batches
		WHERE batch_fingerprint = $1
		LIMIT 1
	`, batchFingerprint)
	if err != nil {
		if err == sql.ErrNoRows {
			return "", false, nil
		}
		return "", false, err
	}

	return batchID, true, nil
}

func (s *AnalyticsStore) SaveBatch(
	ctx context.Context,
	requestID string,
	batchID string,
	batchFingerprint string,
	userID int64,
	events []models.IngestedEvent,
) (*SaveBatchResult, error) {
	tx, err := s.db.BeginTxx(ctx, nil)
	if err != nil {
		return nil, err
	}
	defer func() {
		_ = tx.Rollback()
	}()

	var platform string
	var appVersion string
	if len(events) > 0 {
		platform = events[0].Event.Platform
		appVersion = events[0].Event.AppVersion
	}

	_, err = tx.ExecContext(ctx, `
		INSERT INTO analytics_event_batches (
			batch_id,
			batch_fingerprint,
			user_id,
			events_count,
			status,
			source,
			app_version,
			platform
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
	`,
		batchID,
		batchFingerprint,
		userID,
		len(events),
		"received",
		strings.ToLower(platform),
		appVersion,
		platform,
	)
	if err != nil {
		if isUniqueViolation(err) {
			_, found, findErr := s.FindBatchByFingerprint(ctx, batchFingerprint)
			if findErr != nil {
				return nil, findErr
			}
			if found {
				return &SaveBatchResult{
					InsertedEvents:     0,
					DeduplicatedEvents: len(events),
				}, nil
			}
		}
		return nil, err
	}

	result := &SaveBatchResult{
		InsertedEvents:     0,
		DeduplicatedEvents: 0,
	}

	for idx, item := range events {
		rawPayload, err := json.Marshal(item.Event)
		if err != nil {
			return nil, err
		}

		var rawEventID int64
		err = tx.QueryRowContext(ctx, `
			INSERT INTO analytics_events_raw (
				batch_id,
				user_id,
				event_index,
				payload
			)
			VALUES ($1, $2, $3, $4)
			RETURNING id
		`,
			batchID,
			userID,
			idx,
			rawPayload,
		).Scan(&rawEventID)
		if err != nil {
			return nil, err
		}

		if !item.IsValid {
			_, err = tx.ExecContext(ctx, `
				INSERT INTO analytics_invalid_events (
					batch_id,
					user_id,
					request_id,
					event_index,
					event_name,
					reason,
					payload
				)
				VALUES ($1, $2, $3, $4, $5, $6, $7)
			`,
				batchID,
				userID,
				requestID,
				idx,
				item.Event.EventName,
				item.RejectReason,
				rawPayload,
			)
			if err != nil {
				return nil, err
			}
			continue
		}

		propertiesJSON, err := json.Marshal(item.Event.Properties)
		if err != nil {
			return nil, err
		}

		var insertedEventID int64
		err = tx.QueryRowContext(ctx, `
			INSERT INTO analytics_events (
				batch_id,
				raw_event_id,
				event_fingerprint,
				user_id,
				session_id,
				event_name,
				event_date,
				event_time,
				server_received_at,
				request_id,
				screen,
				platform,
				app_version,
				event_category,
				is_error_event,
				entity_type,
				entity_id,
				workout_id,
				post_id,
				person_id,
				target_user_id,
				community_id,
				properties,
				processing_status
			)
			VALUES (
				$1, $2, $3, $4, $5, $6, $7, $8, NOW(), $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23
			)
			ON CONFLICT DO NOTHING
			RETURNING id
		`,
			batchID,
			rawEventID,
			item.EventFingerprint,
			userID,
			item.Event.SessionID,
			item.NormalizedName,
			item.EventDate,
			item.NormalizedTime,
			requestID,
			item.Screen,
			item.NormalizedPlatform,
			item.Event.AppVersion,
			item.EventCategory,
			item.IsErrorEvent,
			item.EntityType,
			item.EntityID,
			item.WorkoutID,
			item.PostID,
			item.PersonID,
			item.TargetUserID,
			item.CommunityID,
			propertiesJSON,
			"pending",
		).Scan(&insertedEventID)

		if err != nil {
			if err == sql.ErrNoRows {
				result.DeduplicatedEvents++
				continue
			}
			return nil, err
		}
		result.InsertedEvents++
	}

	if err := tx.Commit(); err != nil {
		return nil, err
	}

	return result, nil
}

func isUniqueViolation(err error) bool {
	pqErr, ok := err.(*pq.Error)
	return ok && pqErr.Code == "23505"
}