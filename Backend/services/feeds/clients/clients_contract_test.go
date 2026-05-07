package clients

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestWorkoutsClient_FetchSessionPreviews_Contract(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, http.MethodPost, r.Method)
		assert.Equal(t, "/sessions/preview/batch", r.URL.Path)
		assert.Equal(t, "application/json", r.Header.Get("Content-Type"))

		body, _ := io.ReadAll(r.Body)
		assert.Contains(t, string(body), `"ids"`)

		_ = json.NewEncoder(w).Encode(types.SessionPreviewBatchResponse{
			Items: []types.SessionPreviewItem{
				{ID: "s1"},
				{ID: "s2"},
			},
		})
	}))
	defer srv.Close()

	c := NewWorkoutsClient(srv.URL)
	got, err := c.FetchSessionPreviews(context.Background(), []string{"s1", "s2"})
	require.NoError(t, err)
	assert.Contains(t, got, "s1")
	assert.Contains(t, got, "s2")
}

func TestProfileClient_FetchProfilesBatch_Contract(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, http.MethodPost, r.Method)
		assert.Equal(t, "/profiles/batch", r.URL.Path)
		assert.Equal(t, "application/json", r.Header.Get("Content-Type"))

		_ = json.NewEncoder(w).Encode([]ProfilePreview{
			{UserID: 1, Name: "A"},
			{UserID: 2, Name: "B"},
		})
	}))
	defer srv.Close()

	c := NewProfileClient(srv.URL)
	got, err := c.FetchProfilesBatch(context.Background(), []int{1, 2})
	require.NoError(t, err)
	assert.Equal(t, "A", got[1].Name)
	assert.Equal(t, "B", got[2].Name)
}

func TestPerksClient_SendEventForUser_Contract(t *testing.T) {
	internalSecret := "secret123"

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, http.MethodPost, r.Method)
		assert.Equal(t, "/internal/perks/users/7/events", r.URL.Path)
		assert.Equal(t, internalSecret, r.Header.Get("X-Internal-Secret"))
		assert.Equal(t, "application/json", r.Header.Get("Content-Type"))

		body, _ := io.ReadAll(r.Body)
		assert.Contains(t, string(body), `"type":"workout_completed"`)
		w.WriteHeader(http.StatusNoContent)
	}))
	defer srv.Close()

	c := NewPerksClient(srv.URL, internalSecret)
	err := c.SendEventForUser(7, "workout_completed", map[string]string{"weekday": "monday"})
	require.NoError(t, err)
}

func TestProfileClient_FetchAllProfiles_Contract(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, http.MethodGet, r.Method)
		assert.Equal(t, "/profiles", r.URL.Path)
		_ = json.NewEncoder(w).Encode([]ProfilePreview{
			{UserID: 10, Name: "X"},
		})
	}))
	defer srv.Close()

	c := NewProfileClient(strings.TrimRight(srv.URL, "/"))
	got, err := c.FetchAllProfiles(context.Background())
	require.NoError(t, err)
	assert.Equal(t, "X", got[10].Name)
}

