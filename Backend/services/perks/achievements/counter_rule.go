package achievements

type CounterRule struct {
	code      string
	eventType string
}

func NewCounterRule(code string, eventType string) *CounterRule {
	return &CounterRule{
		code:      code,
		eventType: eventType,
	}
}

func (r *CounterRule) Code() string {
	return r.code
}

func (r *CounterRule) Applies(event PerkEvent) bool {
	return event.Type == r.eventType
}

func (r *CounterRule) Evaluate(
	event PerkEvent,
	currentProgress int,
	targetProgress int,
) AchievementProgressUpdate {
	if targetProgress <= 0 {
		targetProgress = 1
	}

	nextProgress := currentProgress + 1
	if nextProgress > targetProgress {
		nextProgress = targetProgress
	}

	return AchievementProgressUpdate{
		Code:            r.code,
		ProgressCurrent: nextProgress,
		Unlock:          nextProgress >= targetProgress,
	}
}