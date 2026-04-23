package service

import (
	"strings"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
)

const (
	MaxStoredErrorMessageLength = 160
	RawEventsRetentionDays      = 30
	InvalidEventsRetentionDays  = 30
)

func SanitizeEventForStorage(event models.AnalyticsEventDTO) models.AnalyticsEventDTO {
	sanitized := event

	if sanitized.Properties == nil {
		sanitized.Properties = map[string]string{}
	}

	safeProps := make(map[string]string, len(sanitized.Properties))
	for k, v := range sanitized.Properties {
		key := strings.TrimSpace(k)
		value := strings.TrimSpace(v)

		switch key {
		case "message":
			safeProps[key] = sanitizeErrorMessage(value)
		default:
			safeProps[key] = value
		}
	}

	sanitized.Properties = safeProps
	sanitized.UserID = ""

	return sanitized
}

func sanitizeErrorMessage(message string) string {
	message = strings.TrimSpace(message)
	if message == "" {
		return ""
	}

	if len(message) > MaxStoredErrorMessageLength {
		message = message[:MaxStoredErrorMessageLength]
	}

	message = strings.ReplaceAll(message, "\n", " ")
	message = strings.ReplaceAll(message, "\r", " ")
	message = strings.Join(strings.Fields(message), " ")

	return message
}
