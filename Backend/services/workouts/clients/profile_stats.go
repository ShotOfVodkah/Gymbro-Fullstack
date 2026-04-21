package clients

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

type ProfileStatsClient struct {
	baseURL    string
	secret     string
	httpClient *http.Client
}

func NewProfileStatsClient(baseURL, internalSecret string) *ProfileStatsClient {
	if baseURL == "" || internalSecret == "" {
		return nil
	}
	return &ProfileStatsClient{
		baseURL: baseURL,
		secret:  internalSecret,
		httpClient: &http.Client{
			Timeout: 5 * time.Second,
		},
	}
}

type internalStatsBody struct {
	UserID  int             `json:"user_id"`
	Payload json.RawMessage `json:"payload"`
}

func (c *ProfileStatsClient) UpsertStatistics(ctx context.Context, userID int, payloadJSON []byte) error {
	if c == nil {
		return nil
	}
	body, err := json.Marshal(internalStatsBody{UserID: userID, Payload: payloadJSON})
	if err != nil {
		return fmt.Errorf("marshal internal stats: %w", err)
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.baseURL+"/profiles/internal/statistics", bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("new request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-Internal-Secret", c.secret)

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("profile stats http: %w", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusNoContent && resp.StatusCode != http.StatusOK {
		return fmt.Errorf("profile stats status %d", resp.StatusCode)
	}
	return nil
}
