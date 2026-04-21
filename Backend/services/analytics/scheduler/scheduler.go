package scheduler

import (
	"context"

	"github.com/alexandra-gritsaenko/gymbro-analytics/processor"
)

type Scheduler struct {
	processor *processor.Processor
}

func New(processor *processor.Processor) *Scheduler {
	return &Scheduler{
		processor: processor,
	}
}

func (s *Scheduler) Start(ctx context.Context) {
	go s.processor.Run(ctx)
}