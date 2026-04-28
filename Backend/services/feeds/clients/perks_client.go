package clients

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

type PerksClient struct {
	baseURL        string
	internalSecret string
	client         *http.Client
}

func NewPerksClient(baseURL string, internalSecret string) *PerksClient {
	return &PerksClient{
		baseURL:        baseURL,
		internalSecret: internalSecret,
		client: &http.Client{
			Timeout: 5 * time.Second,
		},
	}
}

func (c *PerksClient) SendEventForUser(
	userID int,
	eventType string,
	metadata map[string]string,
) error {
	if metadata == nil {
		metadata = map[string]string{}
	}

	body := struct {
		Type      string            `json:"type"`
		Metadata  map[string]string `json:"metadata"`
		CreatedAt time.Time         `json:"createdAt"`
	}{
		Type:      eventType,
		Metadata:  metadata,
		CreatedAt: time.Now(),
	}

	data, err := json.Marshal(body)
	if err != nil {
		return err
	}

	url := fmt.Sprintf("%s/internal/perks/users/%d/events", c.baseURL, userID)

	req, err := http.NewRequest(http.MethodPost, url, bytes.NewReader(data))
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-Internal-Secret", c.internalSecret)

	resp, err := c.client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return fmt.Errorf("perks service returned status %d", resp.StatusCode)
	}

	return nil
}