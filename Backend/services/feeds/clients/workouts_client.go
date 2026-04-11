package clients

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

type WorkoutsClient struct {
	baseURL    string
	httpClient *http.Client
}

func NewWorkoutsClient(baseURL string) *WorkoutsClient {
	return &WorkoutsClient{
		baseURL: baseURL,
		httpClient: &http.Client{
			Timeout: 5 * time.Second,
		},
	}
}

func (c *WorkoutsClient) FetchWorkoutPreviews(ctx context.Context, ids []string) (map[string]types.WorkoutPreviewItem, error) {
	if len(ids) == 0 {
		return map[string]types.WorkoutPreviewItem{}, nil
	}

	body, err := json.Marshal(types.WorkoutPreviewBatchRequest{
		IDs: ids,
	})
	if err != nil {
		return nil, fmt.Errorf("marshal workout preview request: %w", err)
	}

	url := c.baseURL + "/internal/workouts/preview/batch"
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("create workouts request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("call workouts service: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("workouts service returned status %d", resp.StatusCode)
	}

	var result types.WorkoutPreviewBatchResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("decode workouts response: %w", err)
	}

	out := make(map[string]types.WorkoutPreviewItem, len(result.Items))
	for _, item := range result.Items {
		out[item.ID] = item
	}

	return out, nil
}