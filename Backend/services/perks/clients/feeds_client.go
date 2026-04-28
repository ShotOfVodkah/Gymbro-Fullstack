package clients

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

type FeedsClient struct {
	baseURL        string
	internalSecret string
	client         *http.Client
}

func NewFeedsClient(baseURL string, internalSecret string) *FeedsClient {
	return &FeedsClient{
		baseURL:        baseURL,
		internalSecret: internalSecret,
		client: &http.Client{
			Timeout: 5 * time.Second,
		},
	}
}

func (c *FeedsClient) FetchFollowingIDs(userID int64) ([]int64, error) {
	return c.fetchIDs(fmt.Sprintf("/internal/people/%d/following/ids", userID))
}

func (c *FeedsClient) FetchFriendIDs(userID int64) ([]int64, error) {
	return c.fetchIDs(fmt.Sprintf("/internal/people/%d/friends/ids", userID))
}

func (c *FeedsClient) fetchIDs(path string) ([]int64, error) {
	req, err := http.NewRequest(http.MethodGet, c.baseURL+path, nil)
	if err != nil {
		return nil, err
	}

	req.Header.Set("X-Internal-Secret", c.internalSecret)

	resp, err := c.client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, fmt.Errorf("feeds service returned status %d", resp.StatusCode)
	}

	var result struct {
		UserIDs []int64 `json:"user_ids"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, err
	}

	return result.UserIDs, nil
}