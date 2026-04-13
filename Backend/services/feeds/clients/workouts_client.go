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

func (c *WorkoutsClient) FetchSessionPreviews(ctx context.Context, ids []string) (map[string]types.SessionPreviewItem, error) {
	if len(ids) == 0 {
		return map[string]types.SessionPreviewItem{}, nil
	}

	body, err := json.Marshal(types.SessionPreviewBatchRequest{
		IDs: ids,
	})
	if err != nil {
		return nil, fmt.Errorf("marshal session preview request: %w", err)
	}

	url := c.baseURL + "/sessions/preview/batch"
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("create sessions request: %w", err)
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

	var result types.SessionPreviewBatchResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("decode sessions response: %w", err)
	}

	out := make(map[string]types.SessionPreviewItem, len(result.Items))
	for _, item := range result.Items {
		out[item.ID] = item
	}

	return out, nil
}