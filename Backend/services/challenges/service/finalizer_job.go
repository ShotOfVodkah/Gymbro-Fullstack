package service

import (
	"context"
	"log"
	"time"
)

func StartChallengeFinalizerCron(
	ctx context.Context,
	service ChallengesService,
) {
	go func() {
		for {
			now := time.Now()
			next := time.Date(
				now.Year(),
				now.Month(),
				now.Day()+1,
				0, 0, 0, 0,
				now.Location(),
			)

			wait := time.Until(next)

			log.Printf("challenge finalizer: sleeping until %v (%v)", next, wait)

			select {
			case <-ctx.Done():
				log.Println("challenge finalizer stopped")
				return

			case <-time.After(wait):
				log.Println("challenge finalizer: running daily job")

				if err := service.FinalizeExpiredChallenges(); err != nil {
					log.Printf("challenge finalizer error: %v", err)
				}
			}
		}
	}()
}