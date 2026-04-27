package clients

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-profile/types"
)

type WorkoutsTemporalClient struct {
	base   string
	secret string
	client *http.Client
}

func NewWorkoutsTemporalClient(baseURL, internalSecret string) *WorkoutsTemporalClient {
	if baseURL == "" || internalSecret == "" {
		return nil
	}
	return &WorkoutsTemporalClient{base: baseURL, secret: internalSecret, client: http.DefaultClient}
}

type workoutsTemporalResponse struct {
	Summary struct {
		WorkoutsThisWeek  int `json:"workouts_this_week"`
		WorkoutsThisMonth int `json:"workouts_this_month"`
		Consistency       int `json:"consistency"`
	} `json:"summary"`
	MonthlyTrend    []trendPointJSON     `json:"monthly_trend"`
	WorkoutsByMonth []workoutByMonthJSON `json:"workouts_by_month"`
}

type trendPointJSON struct {
	ID    string `json:"id"`
	Label string `json:"label"`
	Value int    `json:"value"`
}
type workoutByMonthJSON struct {
	ID         string `json:"id"`
	MonthLabel string `json:"month_label"`
	Value      int    `json:"value"`
}

func (c *WorkoutsTemporalClient) MergeTemporalInto(ctx context.Context, userID int, doc types.StoredStatisticsPayload) (types.StoredStatisticsPayload, error) {
	if c == nil {
		return doc, nil
	}
	reqURL := strings.TrimRight(c.base, "/") + "/internal/statistics/temporal?user_id=" + url.QueryEscape(strconv.Itoa(userID))
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, reqURL, nil)
	if err != nil {
		return doc, err
	}
	req.Header.Set("X-Internal-Secret", c.secret)
	req.Header.Set("X-Reference-Time", time.Now().UTC().Format(time.RFC3339))

	res, err := c.client.Do(req)
	if err != nil {
		return doc, err
	}
	defer res.Body.Close()
	body, err := io.ReadAll(res.Body)
	if err != nil {
		return doc, err
	}
	if res.StatusCode != http.StatusOK {
		return doc, fmt.Errorf("workouts temporal: %s: %s", res.Status, string(body))
	}

	var tr workoutsTemporalResponse
	if err := json.Unmarshal(body, &tr); err != nil {
		return doc, err
	}

	doc.Summary.WorkoutsThisWeek = tr.Summary.WorkoutsThisWeek
	doc.Summary.WorkoutsThisMonth = tr.Summary.WorkoutsThisMonth
	doc.Summary.Consistency = tr.Summary.Consistency

	if len(tr.MonthlyTrend) > 0 {
		doc.MonthlyTrend = make([]types.TrendPoint, 0, len(tr.MonthlyTrend))
		for _, p := range tr.MonthlyTrend {
			doc.MonthlyTrend = append(doc.MonthlyTrend, types.TrendPoint{ID: p.ID, Label: p.Label, Value: p.Value})
		}
	}
	if len(tr.WorkoutsByMonth) > 0 {
		doc.WorkoutsByMonth = make([]types.WorkoutByMonthPoint, 0, len(tr.WorkoutsByMonth))
		for _, p := range tr.WorkoutsByMonth {
			doc.WorkoutsByMonth = append(doc.WorkoutsByMonth, types.WorkoutByMonthPoint{ID: p.ID, MonthLabel: p.MonthLabel, Value: p.Value})
		}
	}
	return doc, nil
}
