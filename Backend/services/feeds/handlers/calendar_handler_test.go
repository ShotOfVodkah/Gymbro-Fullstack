package handlers

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	authmw "github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexandra-gritsaenko/gymbro-feeds/clients"
	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type mockCalendarStore struct {
	listMembers func(communityID string) ([]int, error)
}

func (m mockCalendarStore) ListCommunityMemberIDs(communityID string) ([]int, error) {
	return m.listMembers(communityID)
}

type mockProfileClient struct {
	fetch func(ctx context.Context, ids []int) (map[int]clients.ProfilePreview, error)
}

func (m *mockProfileClient) FetchProfilesBatch(ctx context.Context, ids []int) (map[int]clients.ProfilePreview, error) {
	return m.fetch(ctx, ids)
}

func TestCalendarHandler_GetCalendarPeople_Unauthorized(t *testing.T) {
	h := NewCalendarHandler(mockCalendarStore{}, &mockProfileClient{}, nil)
	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/calendar/people?context=mine", nil)
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusUnauthorized, rr.Code)
}

func TestCalendarHandler_GetCalendarPeople_BadContext(t *testing.T) {
	h := NewCalendarHandler(mockCalendarStore{}, &mockProfileClient{}, nil)
	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/calendar/people?context=nope", nil)
	req = req.WithContext(authmw.ContextWithClaims(req.Context(), &authmw.Claims{UserID: 1}))
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestCalendarHandler_GetCalendarPeople_DirectChat_OK(t *testing.T) {
	h := NewCalendarHandler(
		mockCalendarStore{
			listMembers: func(communityID string) ([]int, error) {
				assert.Equal(t, "chat-1", communityID)
				return []int{2, 1}, nil
			},
		},
		&mockProfileClient{
			fetch: func(ctx context.Context, ids []int) (map[int]clients.ProfilePreview, error) {
				return map[int]clients.ProfilePreview{
					1: {UserID: 1, Name: "Me", AvatarSystemName: "me"},
					2: {UserID: 2, Name: "B", AvatarSystemName: "b"},
				}, nil
			},
		},
		nil,
	)

	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/calendar/people?context=direct_chat&chat_id=chat-1", nil)
	req = req.WithContext(authmw.ContextWithClaims(req.Context(), &authmw.Claims{UserID: 1}))
	h.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
	var resp []types.CalendarPersonResponse
	require.NoError(t, json.NewDecoder(rr.Body).Decode(&resp))
	require.Len(t, resp, 2)
	assert.Equal(t, "1", resp[0].ID, "current user should be first")
}

