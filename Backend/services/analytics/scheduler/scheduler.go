package scheduler

import (
	"context"
	"log"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-analytics/service"
	"github.com/alexandra-gritsaenko/gymbro-analytics/store"
	"github.com/alexandra-gritsaenko/gymbro-analytics/processor"
)

type Scheduler struct {
	processor *processor.Processor
	store     *store.AnalyticsStore
}

func New(processor *processor.Processor, store *store.AnalyticsStore) *Scheduler {
	return &Scheduler{
		processor: processor,
		store:     store,
	}
}

func (s *Scheduler) Start(ctx context.Context) {
	go s.processor.Run(ctx)
	go s.runPrivacyCleanup(ctx)
	go s.runMaterializedViewRefresh(ctx)
}

func (s *Scheduler) runPrivacyCleanup(ctx context.Context) {
	ticker := time.NewTicker(12 * time.Hour)
	defer ticker.Stop()

	log.Println("[analytics scheduler] privacy cleanup started")

	for {
		select {
		case <-ctx.Done():
			log.Println("[analytics scheduler] privacy cleanup stopped")
			return
		case <-ticker.C:
			if err := s.store.CleanupRawEvents(ctx, service.RawEventsRetentionDays); err != nil {
				log.Printf("[analytics scheduler] cleanup raw events error: %v", err)
			}
			if err := s.store.CleanupInvalidEvents(ctx, service.InvalidEventsRetentionDays); err != nil {
				log.Printf("[analytics scheduler] cleanup invalid events error: %v", err)
			}
		}
	}
}

func (s *Scheduler) runMaterializedViewRefresh(ctx context.Context) {
	ticker := time.NewTicker(5 * time.Minute)
	defer ticker.Stop()
	log.Println("[analytics scheduler] materialized view refresh started")
	for {
		select {
		case <-ctx.Done():
			log.Println("[analytics scheduler] materialized view refresh stopped")
			return
		case <-ticker.C:
			if err := s.store.RefreshMaterializedViews(ctx); err != nil {
				log.Printf("[analytics scheduler] refresh materialized views error: %v", err)
			}
		}
	}
}