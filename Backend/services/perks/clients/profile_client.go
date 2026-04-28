package clients

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

type ProfilePreview struct {
	UserID           int    `json:"user_id"`
	Name             string `json:"name"`
	Username         string `json:"username"`
	AvatarSystemName string `json:"avatar_system_name"`
}

type ProfileClient struct {
	baseURL string
	client  *http.Client
}

func NewProfileClient(baseURL string) *ProfileClient {
	return &ProfileClient{
		baseURL: baseURL,
		client: &http.Client{
			Timeout: 5 * time.Second,
		},
	}
}

func (c *ProfileClient) FetchProfilesBatch(userIDs []int64) (map[int64]ProfilePreview, error) {
	if len(userIDs) == 0 {
		return map[int64]ProfilePreview{}, nil
	}

	ids := make([]int, 0, len(userIDs))
	for _, id := range userIDs {
		ids = append(ids, int(id))
	}

	body := struct {
		IDs []int `json:"ids"`
	}{
		IDs: ids,
	}

	data, err := json.Marshal(body)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequest(
		http.MethodPost,
		c.baseURL+"/profiles/batch",
		bytes.NewReader(data),
	)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Content-Type", "application/json")

	resp, err := c.client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, fmt.Errorf("profile service returned status %d", resp.StatusCode)
	}

	var profiles []ProfilePreview
	if err := json.NewDecoder(resp.Body).Decode(&profiles); err != nil {
		return nil, err
	}

	result := make(map[int64]ProfilePreview, len(profiles))
	for _, profile := range profiles {
		result[int64(profile.UserID)] = profile
	}

	return result, nil
}