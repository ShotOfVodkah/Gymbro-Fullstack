package clients

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

type AnalyticsEventRequest struct {
	EventName string            `json:"event_name"`
	Properties map[string]string `json:"properties"`
	Timestamp string            `json:"timestamp"`
	Platform  string            `json:"platform"`
}

type AnalyticsClient struct {
	baseURL        string
	internalSecret string
	client         *http.Client
}

func NewAnalyticsClient(baseURL string, internalSecret string) *AnalyticsClient {
	return &AnalyticsClient{
		baseURL:        baseURL,
		internalSecret: internalSecret,
		client:         http.DefaultClient,
	}
}

func (c *AnalyticsClient) Track(eventName string, properties map[string]string) error {
	request := AnalyticsEventRequest{
		EventName:  eventName,
		Properties: properties,
		Timestamp:  time.Now().Format(time.RFC3339),
		Platform:   "backend_challenges",
	}

	body, err := json.Marshal(request)
	if err != nil {
		return err
	}

	req, err := http.NewRequest(
		http.MethodPost,
		c.baseURL+"/internal/analytics/events",
		bytes.NewReader(body),
	)
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
		return fmt.Errorf("analytics service returned status %d", resp.StatusCode)
	}

	return nil
}