package clients

import (
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestHTTPChatsClient_GetUserGroupChats_Contract(t *testing.T) {
	internalSecret := "sec"

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, http.MethodGet, r.Method)
		assert.Equal(t, "/internal/chats/users/42/groups", r.URL.Path)
		assert.Equal(t, internalSecret, r.Header.Get("X-Internal-Secret"))
		_ = json.NewEncoder(w).Encode([]GroupChat{
			{ID: "c1", Name: "Chat", IsGroup: true, MembersCount: 2},
		})
	}))
	defer srv.Close()

	c := NewHTTPChatsClient(srv.URL, internalSecret)
	chats, err := c.GetUserGroupChats(42)
	require.NoError(t, err)
	require.Len(t, chats, 1)
	assert.Equal(t, "c1", chats[0].ID)
}

func TestHTTPChatsClient_SendChallengeSystemMessage_Contract(t *testing.T) {
	internalSecret := "sec"

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, http.MethodPost, r.Method)
		assert.Equal(t, "/internal/chats/chat-1/system-message", r.URL.Path)
		assert.Equal(t, internalSecret, r.Header.Get("X-Internal-Secret"))
		assert.Equal(t, "application/json", r.Header.Get("Content-Type"))

		body, _ := io.ReadAll(r.Body)
		assert.Contains(t, string(body), `"kind":"challenge_joined"`)
		w.WriteHeader(http.StatusNoContent)
	}))
	defer srv.Close()

	c := NewHTTPChatsClient(srv.URL, internalSecret)
	err := c.SendChallengeSystemMessage("chat-1", ChallengeSystemMessageRequest{
		Kind: "challenge_joined",
		Text: "ok",
	})
	require.NoError(t, err)
}

func TestAnalyticsClient_Track_Contract(t *testing.T) {
	internalSecret := "sec"

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, http.MethodPost, r.Method)
		assert.Equal(t, "/internal/analytics/events", r.URL.Path)
		assert.Equal(t, internalSecret, r.Header.Get("X-Internal-Secret"))
		assert.Equal(t, "application/json", r.Header.Get("Content-Type"))

		body, _ := io.ReadAll(r.Body)
		assert.Contains(t, string(body), `"event_name":"challenge_joined"`)
		w.WriteHeader(http.StatusNoContent)
	}))
	defer srv.Close()

	c := NewAnalyticsClient(srv.URL, internalSecret)
	err := c.Track("challenge_joined", map[string]string{"challenge_id": "c1"})
	require.NoError(t, err)
}

