package types

import (
	"bytes"
	"encoding/json"
)

func ParseStoredStatisticsPayload(raw []byte) StoredStatisticsPayload {
	def := DefaultStoredStatisticsPayload()
	if len(bytes.TrimSpace(raw)) == 0 || bytes.Equal(bytes.TrimSpace(raw), []byte("{}")) {
		return def
	}
	var p StoredStatisticsPayload
	if err := json.Unmarshal(raw, &p); err != nil {
		return def
	}
	if len(p.WeeklyActivity) == 0 {
		p.WeeklyActivity = def.WeeklyActivity
	}
	if len(p.MonthlyTrend) == 0 {
		p.MonthlyTrend = def.MonthlyTrend
	}
	if len(p.WorkoutsByMonth) == 0 {
		p.WorkoutsByMonth = def.WorkoutsByMonth
	}
	if len(p.Categories) == 0 {
		p.Categories = def.Categories
	}
	return p
}

func (p StoredStatisticsPayload) ToStatisticsResponse(userID int) StatisticsResponse {
	return StatisticsResponse{
		UserID:          userID,
		Summary:         p.Summary,
		WeeklyActivity:  p.WeeklyActivity,
		MonthlyTrend:    p.MonthlyTrend,
		WorkoutsByMonth: p.WorkoutsByMonth,
		Categories:      p.Categories,
	}
}
