package validator

import (
	"encoding/json"
	"fmt"
	"strings"
	"unicode/utf8"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
)

const (
	MaxBatchSize          = 100
	MaxEventNameLength    = 120
	MaxSessionIDLength    = 128
	MaxPlatformLength     = 32
	MaxAppVersionLength   = 32
	MaxPropertyKeyLength  = 100
	MaxPropertyValueLength = 2000
	MaxRawPayloadBytes    = 16 * 1024
	MaxPropertiesBytes    = 8 * 1024
)

type EventValidator struct{}

func New() *EventValidator {
	return &EventValidator{}
}

func (v *EventValidator) ValidateBatch(events []models.AnalyticsEventDTO) error {
	if len(events) == 0 {
		return fmt.Errorf("events array is empty")
	}
	if len(events) > MaxBatchSize {
		return fmt.Errorf("batch size exceeds limit: %d", MaxBatchSize)
	}
	return nil
}

func (v *EventValidator) ValidateEvent(event models.AnalyticsEventDTO) (bool, string, int, int) {
	rawBytes, _ := json.Marshal(event)
	propertiesBytes, _ := json.Marshal(event.Properties)

	if len(rawBytes) > MaxRawPayloadBytes {
		return false, "raw payload exceeds size limit", len(rawBytes), len(propertiesBytes)
	}
	if len(propertiesBytes) > MaxPropertiesBytes {
		return false, "properties payload exceeds size limit", len(rawBytes), len(propertiesBytes)
	}

	eventName := strings.TrimSpace(event.EventName)
	if eventName == "" {
		return false, "event_name is required", len(rawBytes), len(propertiesBytes)
	}
	if utf8.RuneCountInString(eventName) > MaxEventNameLength {
		return false, "event_name exceeds length limit", len(rawBytes), len(propertiesBytes)
	}
	if !models.IsAllowedEventName(eventName) {
		return false, "event_name is not allowed", len(rawBytes), len(propertiesBytes)
	}

	if event.Timestamp.IsZero() {
		return false, "timestamp is required", len(rawBytes), len(propertiesBytes)
	}

	sessionID := strings.TrimSpace(event.SessionID)
	if sessionID == "" {
		return false, "session_id is required", len(rawBytes), len(propertiesBytes)
	}
	if utf8.RuneCountInString(sessionID) > MaxSessionIDLength {
		return false, "session_id exceeds length limit", len(rawBytes), len(propertiesBytes)
	}

	platform := strings.TrimSpace(event.Platform)
	if platform == "" {
		return false, "platform is required", len(rawBytes), len(propertiesBytes)
	}
	if utf8.RuneCountInString(platform) > MaxPlatformLength {
		return false, "platform exceeds length limit", len(rawBytes), len(propertiesBytes)
	}

	appVersion := strings.TrimSpace(event.AppVersion)
	if appVersion == "" {
		return false, "app_version is required", len(rawBytes), len(propertiesBytes)
	}
	if utf8.RuneCountInString(appVersion) > MaxAppVersionLength {
		return false, "app_version exceeds length limit", len(rawBytes), len(propertiesBytes)
	}

	for key, value := range event.Properties {
		if strings.TrimSpace(key) == "" {
			return false, "property key is empty", len(rawBytes), len(propertiesBytes)
		}
		if utf8.RuneCountInString(key) > MaxPropertyKeyLength {
			return false, "property key exceeds length limit", len(rawBytes), len(propertiesBytes)
		}
		if utf8.RuneCountInString(value) > MaxPropertyValueLength {
			return false, fmt.Sprintf("property value exceeds length limit for key: %s", key), len(rawBytes), len(propertiesBytes)
		}
	}

	def, ok := models.ResolveEventDefinition(eventName)
	if !ok {
		return false, "event definition not found", len(rawBytes), len(propertiesBytes)
	}

	for _, requiredKey := range def.RequiredProperties {
		value, exists := event.Properties[requiredKey]
		if !exists || strings.TrimSpace(value) == "" {
			return false, fmt.Sprintf("required property missing: %s", requiredKey), len(rawBytes), len(propertiesBytes)
		}
	}

	return true, "", len(rawBytes), len(propertiesBytes)
}