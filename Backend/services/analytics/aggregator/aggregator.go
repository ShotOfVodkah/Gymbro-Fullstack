package aggregator

import (
	"context"
	"encoding/json"
	"log"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
)

type Aggregator struct{}

func New() *Aggregator {
	return &Aggregator{}
}

func (a *Aggregator) Aggregate(ctx context.Context, events []models.ProcessableEvent) error {

	for _, event := range events {
		var properties map[string]string
		if len(event.Properties) > 0 {
			_ = json.Unmarshal(event.Properties, &properties)
		}

		log.Printf(
			"[analytics processor] processing event id=%d name=%s user_id=%d session_id=%s category=%v screen=%v properties=%v",
			event.ID,
			event.EventName,
			event.UserID,
			event.SessionID,
			event.EventCategory,
			event.Screen,
			properties,
		)
	}

	return nil
}