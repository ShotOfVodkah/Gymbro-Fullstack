package clients

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	// "github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

type ProfilePreview struct {
	UserID            int     `json:"user_id"`
	Name              string  `json:"name"`
	Username          string  `json:"username"`
	Status            string  `json:"status"`
	Subtitle          string  `json:"subtitle"`
	AvatarSystemName  string  `json:"avatar_system_name"`
	Badge             *string `json:"badge,omitempty"`
	WorkoutsThisMonth int     `json:"workouts_this_month"`
}

type BatchProfilesRequest struct {
	IDs []int `json:"ids"`
}

type ProfileClient struct {
	baseURL    string
	httpClient *http.Client
}

func NewProfileClient(baseURL string) *ProfileClient {
	return &ProfileClient{
		baseURL: baseURL,
		httpClient: &http.Client{
			Timeout: 5 * time.Second,
		},
	}
}

func (c *ProfileClient) FetchProfilesBatch(ctx context.Context, ids []int) (map[int]ProfilePreview, error) {
	if len(ids) == 0 {
		return map[int]ProfilePreview{}, nil
	}

	body, err := json.Marshal(BatchProfilesRequest{IDs: ids})
	if err != nil {
		return nil, fmt.Errorf("marshal profiles batch request: %w", err)
	}

	req, err := http.NewRequestWithContext(
		ctx,
		http.MethodPost,
		c.baseURL+"/profiles/batch",
		bytes.NewReader(body),
	)
	if err != nil {
		return nil, fmt.Errorf("create profiles batch request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("call profile service: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("profile service returned status %d", resp.StatusCode)
	}

	var items []ProfilePreview
	if err := json.NewDecoder(resp.Body).Decode(&items); err != nil {
		return nil, fmt.Errorf("decode profiles batch response: %w", err)
	}

	result := make(map[int]ProfilePreview, len(items))
	for _, item := range items {
		result[item.UserID] = item
	}

	return result, nil
}

func (c *ProfileClient) FetchAllProfiles(ctx context.Context) (map[int]ProfilePreview, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, c.baseURL+"/profiles", nil)
	if err != nil {
		return nil, fmt.Errorf("create profiles request: %w", err)
	}

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("call profile service: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("profile service returned status %d", resp.StatusCode)
	}

	var items []ProfilePreview
	if err := json.NewDecoder(resp.Body).Decode(&items); err != nil {
		return nil, fmt.Errorf("decode profiles response: %w", err)
	}

	result := make(map[int]ProfilePreview, len(items))
	for _, item := range items {
		result[item.UserID] = item
	}

	return result, nil
}