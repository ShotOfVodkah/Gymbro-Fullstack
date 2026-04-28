package achievements

type PerkEvent struct {
	Type     string
	Metadata map[string]string
}

type AchievementProgressUpdate struct {
	Code            string
	ProgressCurrent int
	Unlock          bool
}

type AchievementRule interface {
	Code() string
	Applies(event PerkEvent) bool
	Evaluate(event PerkEvent, currentProgress int, targetProgress int) AchievementProgressUpdate
}

func unlockOnce(code string) AchievementProgressUpdate {
	return AchievementProgressUpdate{
		Code:            code,
		ProgressCurrent: 1,
		Unlock:          true,
	}
}