package achievements

import (
	"strconv"
	"strings"
)

type DayOfWeekRule struct {
	code      string
	eventType string
	day       string
}

func NewDayOfWeekRule(code string, eventType string, day string) *DayOfWeekRule {
	return &DayOfWeekRule{
		code:      code,
		eventType: eventType,
		day:       strings.ToLower(day),
	}
}

func (r *DayOfWeekRule) Code() string {
	return r.code
}

func (r *DayOfWeekRule) Applies(event PerkEvent) bool {
	return event.Type == r.eventType &&
		strings.ToLower(event.Metadata["weekday"]) == r.day
}

func (r *DayOfWeekRule) Evaluate(event PerkEvent, currentProgress int, targetProgress int) AchievementProgressUpdate {
	return unlockOnce(r.code)
}

type WeekendRule struct {
	code      string
	eventType string
}

func NewWeekendRule(code string, eventType string) *WeekendRule {
	return &WeekendRule{
		code:      code,
		eventType: eventType,
	}
}

func (r *WeekendRule) Code() string {
	return r.code
}

func (r *WeekendRule) Applies(event PerkEvent) bool {
	weekday := strings.ToLower(event.Metadata["weekday"])

	return event.Type == r.eventType &&
		(weekday == "saturday" || weekday == "sunday")
}

func (r *WeekendRule) Evaluate(event PerkEvent, currentProgress int, targetProgress int) AchievementProgressUpdate {
	return unlockOnce(r.code)
}

type TimeBeforeRule struct {
	code       string
	eventType  string
	beforeHour int
}

func NewTimeBeforeRule(code string, eventType string, beforeHour int) *TimeBeforeRule {
	return &TimeBeforeRule{
		code:       code,
		eventType:  eventType,
		beforeHour: beforeHour,
	}
}

func (r *TimeBeforeRule) Code() string {
	return r.code
}

func (r *TimeBeforeRule) Applies(event PerkEvent) bool {
	if event.Type != r.eventType {
		return false
	}

	hour, ok := eventHour(event)
	return ok && hour < r.beforeHour
}

func (r *TimeBeforeRule) Evaluate(event PerkEvent, currentProgress int, targetProgress int) AchievementProgressUpdate {
	return unlockOnce(r.code)
}

type TimeAfterRule struct {
	code      string
	eventType string
	afterHour int
}

func NewTimeAfterRule(code string, eventType string, afterHour int) *TimeAfterRule {
	return &TimeAfterRule{
		code:      code,
		eventType: eventType,
		afterHour: afterHour,
	}
}

func (r *TimeAfterRule) Code() string {
	return r.code
}

func (r *TimeAfterRule) Applies(event PerkEvent) bool {
	if event.Type != r.eventType {
		return false
	}

	hour, ok := eventHour(event)
	return ok && hour >= r.afterHour
}

func (r *TimeAfterRule) Evaluate(event PerkEvent, currentProgress int, targetProgress int) AchievementProgressUpdate {
	return unlockOnce(r.code)
}

type ExactTimeRule struct {
	code      string
	eventType string
	timeValue string
}

func NewExactTimeRule(code string, eventType string, timeValue string) *ExactTimeRule {
	return &ExactTimeRule{
		code:      code,
		eventType: eventType,
		timeValue: timeValue,
	}
}

func (r *ExactTimeRule) Code() string {
	return r.code
}

func (r *ExactTimeRule) Applies(event PerkEvent) bool {
	return event.Type == r.eventType &&
		event.Metadata["time"] == r.timeValue
}

func (r *ExactTimeRule) Evaluate(event PerkEvent, currentProgress int, targetProgress int) AchievementProgressUpdate {
	return unlockOnce(r.code)
}

func eventHour(event PerkEvent) (int, bool) {
	rawHour := event.Metadata["hour"]
	if rawHour == "" {
		return 0, false
	}

	hour, err := strconv.Atoi(rawHour)
	if err != nil {
		return 0, false
	}

	return hour, true
}