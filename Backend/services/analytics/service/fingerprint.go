package service

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"sort"
	"strings"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
)

func BuildEventFingerprint(userID int64, event models.AnalyticsEventDTO) string {
	normalizedProperties := normalizeProperties(event.Properties)

	payload := map[string]any{
		"event_name": strings.TrimSpace(event.EventName),
		"timestamp":  event.Timestamp.UTC().Format(time.RFC3339Nano),
		"session_id": strings.TrimSpace(event.SessionID),
		"user_id":    userID,
		"properties": normalizedProperties,
	}

	raw, _ := json.Marshal(payload)
	hash := sha256.Sum256(raw)
	return hex.EncodeToString(hash[:])
}

func BuildBatchFingerprint(userID int64, events []models.AnalyticsEventDTO) string {
	normalizedEvents := make([]map[string]any, 0, len(events))

	for _, event := range events {
		normalizedEvents = append(normalizedEvents, map[string]any{
			"event_name": strings.TrimSpace(event.EventName),
			"timestamp":  event.Timestamp.UTC().Format(time.RFC3339Nano),
			"session_id": strings.TrimSpace(event.SessionID),
			"user_id":    userID,
			"properties": normalizeProperties(event.Properties),
		})
	}

	raw, _ := json.Marshal(normalizedEvents)
	hash := sha256.Sum256(raw)
	return hex.EncodeToString(hash[:])
}

func normalizeProperties(properties map[string]string) map[string]string {
	if properties == nil {
		return map[string]string{}
	}

	keys := make([]string, 0, len(properties))
	for k := range properties {
		keys = append(keys, k)
	}
	sort.Strings(keys)

	normalized := make(map[string]string, len(properties))
	for _, k := range keys {
		normalized[strings.TrimSpace(k)] = strings.TrimSpace(properties[k])
	}

	return normalized
}