package clients

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

type FeedsPeopleClient struct {
	baseURL    string
	httpClient *http.Client
}

func NewFeedsPeopleClient(baseURL string) *FeedsPeopleClient {
	if baseURL == "" {
		return nil
	}
	return &FeedsPeopleClient{
		baseURL: baseURL,
		httpClient: &http.Client{
			Timeout: 5 * time.Second,
		},
	}
}

type personFollowPayload struct {
	IsFollowing bool `json:"is_following"`
}

func (c *FeedsPeopleClient) FetchIsFollowing(ctx context.Context, authorization string, followeeID int) (bool, error) {
	if c == nil {
		return false, nil
	}
	url := fmt.Sprintf("%s/people/%d", c.baseURL, followeeID)
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return false, fmt.Errorf("feeds people request: %w", err)
	}
	if authorization != "" {
		req.Header.Set("Authorization", authorization)
	}

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return false, fmt.Errorf("feeds people call: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return false, fmt.Errorf("feeds people status %d", resp.StatusCode)
	}

	var body personFollowPayload
	if err := json.NewDecoder(resp.Body).Decode(&body); err != nil {
		return false, fmt.Errorf("feeds people decode: %w", err)
	}
	return body.IsFollowing, nil
}
