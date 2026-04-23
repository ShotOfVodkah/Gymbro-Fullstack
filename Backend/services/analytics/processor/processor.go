package processor

import (
	"context"
	"log"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-analytics/aggregator"
	"github.com/alexandra-gritsaenko/gymbro-analytics/store"
)

type Processor struct {
	store      *store.AnalyticsStore
	aggregator *aggregator.Aggregator
	interval   time.Duration
	batchSize  int
}

func New(
	store *store.AnalyticsStore,
	aggregator *aggregator.Aggregator,
	interval time.Duration,
	batchSize int,
) *Processor {
	return &Processor{
		store:      store,
		aggregator: aggregator,
		interval:   interval,
		batchSize:  batchSize,
	}
}

func (p *Processor) Run(ctx context.Context) {
	ticker := time.NewTicker(p.interval)
	defer ticker.Stop()

	log.Printf("[analytics processor] started interval=%s batch_size=%d", p.interval, p.batchSize)

	for {
		select {
		case <-ctx.Done():
			log.Println("[analytics processor] stopped")
			return
		case <-ticker.C:
			if err := p.processOnce(ctx); err != nil {
				log.Printf("[analytics processor] processOnce error: %v", err)
			}
		}
	}
}

func (p *Processor) processOnce(ctx context.Context) error {
	events, err := p.store.ClaimPendingEvents(ctx, p.batchSize)
	if err != nil {
		return err
	}

	if len(events) == 0 {
		return nil
	}

	ids := make([]int64, 0, len(events))
	for _, event := range events {
		ids = append(ids, event.ID)
	}

	if err := p.aggregator.Aggregate(ctx, events); err != nil {
		_ = p.store.MarkEventsFailed(ctx, ids, err.Error())
		return err
	}

	if err := p.store.MarkEventsProcessed(ctx, ids); err != nil {
		return err
	}

	log.Printf("[analytics processor] processed events count=%d", len(events))
	return nil
}