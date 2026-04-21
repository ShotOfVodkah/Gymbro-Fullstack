package clients

import (
	"context"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestProfileStatsClient_UpsertStatistics(t *testing.T) {
	var gotSecret string
	var gotBody []byte
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		require.Equal(t, http.MethodPost, r.Method)
		require.Equal(t, "/profiles/internal/statistics", r.URL.Path)
		gotSecret = r.Header.Get("X-Internal-Secret")
		var err error
		gotBody, err = io.ReadAll(r.Body)
		require.NoError(t, err)
		w.WriteHeader(http.StatusNoContent)
	}))
	defer srv.Close()

	c := NewProfileStatsClient(srv.URL, "my-secret")
	require.NotNil(t, c)

	payload := []byte(`{"summary":{"total_workouts":1}}`)
	err := c.UpsertStatistics(context.Background(), 7, payload)
	require.NoError(t, err)
	require.Equal(t, "my-secret", gotSecret)
	require.Contains(t, string(gotBody), `"user_id":7`)
	require.Contains(t, string(gotBody), `"summary"`)
}

func TestNewProfileStatsClient_DisabledWithoutConfig(t *testing.T) {
	require.Nil(t, NewProfileStatsClient("", "s"))
	require.Nil(t, NewProfileStatsClient("http://x", ""))
}
