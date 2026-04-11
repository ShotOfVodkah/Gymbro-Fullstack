package clients

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

type WorkoutsCalendarClient struct {
	baseURL    string
	httpClient *http.Client
}

func NewWorkoutsCalendarClient(baseURL string) *WorkoutsCalendarClient {
	return &WorkoutsCalendarClient{
		baseURL: baseURL,
		httpClient: &http.Client{
			Timeout: 5 * time.Second,
		},
	}
}

func (c *WorkoutsCalendarClient) FetchUserCalendarMonth(
	ctx context.Context,
	userID string,
	month string,
) ([]types.CalendarWorkoutDayResponse, error) {
	u, err := url.Parse(c.baseURL + "/sessions/calendar")
	if err != nil {
		return nil, fmt.Errorf("parse sessions calendar url: %w", err)
	}

	q := u.Query()
	q.Set("user_id", userID)
	q.Set("month", month)
	u.RawQuery = q.Encode()

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, u.String(), nil)
	if err != nil {
		return nil, fmt.Errorf("create sessions calendar request: %w", err)
	}

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("call workouts service: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("workouts service returned status %d", resp.StatusCode)
	}

	var result []types.CalendarWorkoutDayResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("decode sessions calendar response: %w", err)
	}

	return result, nil
}