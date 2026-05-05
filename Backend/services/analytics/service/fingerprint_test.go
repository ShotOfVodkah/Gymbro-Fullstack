package service

import (
	"testing"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
	"github.com/stretchr/testify/assert"
)

func TestBuildEventFingerprint_StableAcrossPropertyOrderAndWhitespace(t *testing.T) {
	ts := time.Date(2026, 5, 5, 12, 0, 0, 123, time.UTC)

	e1 := models.AnalyticsEventDTO{
		EventName:  "  workout_completed  ",
		Timestamp:  ts,
		SessionID:  "  s1 ",
		Platform:   "iOS",
		AppVersion: "1",
		Properties: map[string]string{" b ": " 2 ", "a": "1"},
	}
	e2 := models.AnalyticsEventDTO{
		EventName:  "workout_completed",
		Timestamp:  ts,
		SessionID:  "s1",
		Platform:   "iOS",
		AppVersion: "1",
		Properties: map[string]string{"a": "1", "b": "2"},
	}

	fp1 := BuildEventFingerprint(7, e1)
	fp2 := BuildEventFingerprint(7, e2)
	assert.Equal(t, fp1, fp2)
}

func TestBuildBatchFingerprint_OrderMatters(t *testing.T) {
	ts := time.Date(2026, 5, 5, 12, 0, 0, 0, time.UTC)

	a := models.AnalyticsEventDTO{EventName: "a", Timestamp: ts, SessionID: "s", Platform: "iOS", AppVersion: "1", Properties: map[string]string{"x": "1"}}
	b := models.AnalyticsEventDTO{EventName: "b", Timestamp: ts, SessionID: "s", Platform: "iOS", AppVersion: "1", Properties: map[string]string{"x": "2"}}

	fpAB := BuildBatchFingerprint(1, []models.AnalyticsEventDTO{a, b})
	fpBA := BuildBatchFingerprint(1, []models.AnalyticsEventDTO{b, a})
	assert.NotEqual(t, fpAB, fpBA)
}

