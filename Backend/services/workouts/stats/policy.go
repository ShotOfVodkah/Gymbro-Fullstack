package stats

const ConsistencyWeeksWindow = 12

func CompletionRateV1() int {
	return 0
}

func ConsistencyFromWeekHits(weeksWithSession int, totalWeeks int) int {
	if totalWeeks <= 0 {
		return 0
	}
	if weeksWithSession > totalWeeks {
		weeksWithSession = totalWeeks
	}
	return (100 * weeksWithSession) / totalWeeks
}
