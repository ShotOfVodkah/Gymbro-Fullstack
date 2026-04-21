package types

func DefaultStoredStatisticsPayload() StoredStatisticsPayload {
	return StoredStatisticsPayload{
		Summary: StatisticsSummary{},
		WeeklyActivity: []WeeklyActivityPoint{
			{ID: "1", Label: "M", Value: 0},
			{ID: "2", Label: "T", Value: 0},
			{ID: "3", Label: "W", Value: 0},
			{ID: "4", Label: "T", Value: 0},
			{ID: "5", Label: "F", Value: 0},
			{ID: "6", Label: "S", Value: 0},
			{ID: "7", Label: "S", Value: 0},
		},
		MonthlyTrend: []TrendPoint{
			{ID: "1", Label: "W1", Value: 0},
			{ID: "2", Label: "W2", Value: 0},
			{ID: "3", Label: "W3", Value: 0},
			{ID: "4", Label: "W4", Value: 0},
		},
		WorkoutsByMonth: []WorkoutByMonthPoint{
			{ID: "jan", MonthLabel: "Jan", Value: 0},
			{ID: "feb", MonthLabel: "Feb", Value: 0},
			{ID: "mar", MonthLabel: "Mar", Value: 0},
			{ID: "apr", MonthLabel: "Apr", Value: 0},
			{ID: "may", MonthLabel: "May", Value: 0},
			{ID: "jun", MonthLabel: "Jun", Value: 0},
		},
		Categories: []CategoryPoint{
			{ID: "1", Title: "Chest", Value: 0},
			{ID: "2", Title: "Back", Value: 0},
			{ID: "3", Title: "Legs", Value: 0},
		},
	}
}
