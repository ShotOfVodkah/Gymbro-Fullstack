package service

import (
	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
	"github.com/alexandra-gritsaenko/gymbro-analytics/store"
)

type HealthService struct {
	store *store.HealthStore
}

func NewHealthService(store *store.HealthStore) *HealthService {
	return &HealthService{
		store: store,
	}
}

func (s *HealthService) Health() models.HealthResponse {
	return models.HealthResponse{
		Status:  "ok",
		Service: "analytics_service",
	}
}

func (s *HealthService) Ready() error {
	return s.store.Ping()
}