package feeds

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	authmw "github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexandra-gritsaenko/gymbro-feeds/clients"
	"github.com/alexandra-gritsaenko/gymbro-feeds/store"
	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type mockFeedStore struct {
	listFeedPosts func(userID int, limit int, cursor *string, scope types.FeedScope) ([]types.FeedPostRow, error)
	insertPost    func(authorID int, sessionID string, description string, location *string, communityID *string, kind string) (*types.FeedPostRow, error)
	postExists    func(postID string) (bool, error)
	likePost      func(postID string, userID int) error
	unlikePost    func(postID string, userID int) error
	getLikeState  func(postID string, userID int) (*types.FeedLikeResponse, error)
	listComments  func(postID string) ([]types.FeedCommentRow, error)
	insertComment func(postID string, authorID int, content string) (*types.FeedCommentRow, error)
	getAuthorID   func(postID string) (int, error)
	listUserPosts func(authorID string, currentUserID int) ([]types.FeedPostRow, error)
	listCommunities func(userID int) ([]types.FeedCommunityRow, error)
}

func (m *mockFeedStore) ListFeedPostsForUserPaginated(userID int, limit int, cursor *string, scope types.FeedScope) ([]types.FeedPostRow, error) {
	return m.listFeedPosts(userID, limit, cursor, scope)
}
func (m *mockFeedStore) ListPostsByAuthorID(authorID string, currentUserID int) ([]types.FeedPostRow, error) {
	return m.listUserPosts(authorID, currentUserID)
}
func (m *mockFeedStore) ListCommunitiesForUser(userID int) ([]types.FeedCommunityRow, error) {
	return m.listCommunities(userID)
}
func (m *mockFeedStore) InsertPost(authorID int, sessionID string, description string, location *string, communityID *string, kind string) (*types.FeedPostRow, error) {
	return m.insertPost(authorID, sessionID, description, location, communityID, kind)
}
func (m *mockFeedStore) PostExists(postID string) (bool, error) { return m.postExists(postID) }
func (m *mockFeedStore) ListCommentsByPostID(postID string) ([]types.FeedCommentRow, error) { return m.listComments(postID) }
func (m *mockFeedStore) InsertComment(postID string, authorID int, content string) (*types.FeedCommentRow, error) {
	return m.insertComment(postID, authorID, content)
}
func (m *mockFeedStore) LikePost(postID string, userID int) error   { return m.likePost(postID, userID) }
func (m *mockFeedStore) UnlikePost(postID string, userID int) error { return m.unlikePost(postID, userID) }
func (m *mockFeedStore) GetPostLikeState(postID string, userID int) (*types.FeedLikeResponse, error) {
	return m.getLikeState(postID, userID)
}
func (m *mockFeedStore) GetPostAuthorID(postID string) (int, error) { return m.getAuthorID(postID) }

type mockChatStore struct {
	meta func(ids []string, userID int) (map[string]store.ChatPreviewMeta, error)
}

func (m *mockChatStore) ListCommunityPreviewMeta(communityIDs []string, userID int) (map[string]store.ChatPreviewMeta, error) {
	return m.meta(communityIDs, userID)
}
func (m *mockChatStore) FindOrCreateDirectCommunity(userA, userB int) (*store.Community, bool, error) {
	return nil, false, errors.New("not implemented")
}
func (m *mockChatStore) IsCommunityMember(communityID string, userID int) (bool, error) {
	return false, errors.New("not implemented")
}
func (m *mockChatStore) InsertMessage(communityID string, senderID int, kind string, text, sessionID *string) (*store.CommunityMessage, error) {
	return nil, errors.New("not implemented")
}

type mockWorkoutsClient struct {
	fetch func(ctx context.Context, ids []string) (map[string]types.SessionPreviewItem, error)
}

func (m *mockWorkoutsClient) FetchSessionPreviews(ctx context.Context, ids []string) (map[string]types.SessionPreviewItem, error) {
	return m.fetch(ctx, ids)
}

type mockProfileClient struct {
	fetch func(ctx context.Context, ids []int) (map[int]clients.ProfilePreview, error)
}

func (m *mockProfileClient) FetchProfilesBatch(ctx context.Context, ids []int) (map[int]clients.ProfilePreview, error) {
	return m.fetch(ctx, ids)
}

func withClaims(req *http.Request, userID int) *http.Request {
	return req.WithContext(authmw.ContextWithClaims(req.Context(), &authmw.Claims{UserID: userID, Email: "u@e.com", Role: "athlete"}))
}

func TestGetFeed_Unauthorized(t *testing.T) {
	h := NewFeedHandler(&mockFeedStore{}, &mockChatStore{}, &mockWorkoutsClient{}, &mockProfileClient{}, nil)
	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/feed", nil)
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusUnauthorized, rr.Code)
}

func TestGetFeed_OK_HasMore(t *testing.T) {
	now := time.Now()
	sid := "s1"
	rows := []types.FeedPostRow{
		{ID: "p1", AuthorID: "1", SessionID: &sid, Kind: "personal", Description: "d", CreatedAt: now},
		{ID: "p2", AuthorID: "1", SessionID: &sid, Kind: "personal", Description: "d", CreatedAt: now.Add(-time.Minute)},
		{ID: "p3", AuthorID: "1", SessionID: &sid, Kind: "personal", Description: "d", CreatedAt: now.Add(-2 * time.Minute)},
	}

	h := NewFeedHandler(
		&mockFeedStore{
			listFeedPosts: func(userID int, limit int, cursor *string, scope types.FeedScope) ([]types.FeedPostRow, error) {
				require.Equal(t, 1, userID)
				require.Equal(t, 3, limit) // limit=2 -> +1
				return rows, nil
			},
		},
		&mockChatStore{},
		&mockWorkoutsClient{fetch: func(ctx context.Context, ids []string) (map[string]types.SessionPreviewItem, error) {
			return map[string]types.SessionPreviewItem{"s1": {ID: "s1", Title: "T"}}, nil
		}},
		&mockProfileClient{fetch: func(ctx context.Context, ids []int) (map[int]clients.ProfilePreview, error) {
			return map[int]clients.ProfilePreview{1: {UserID: 1, Name: "A", AvatarSystemName: "a"}}, nil
		}},
		nil,
	)

	rr := httptest.NewRecorder()
	req := withClaims(httptest.NewRequest(http.MethodGet, "/feed?limit=2", nil), 1)
	h.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
	var resp types.FeedPageResponse
	require.NoError(t, json.NewDecoder(rr.Body).Decode(&resp))
	assert.True(t, resp.HasMore)
	require.Len(t, resp.Items, 2)
	require.NotNil(t, resp.NextCursor)
}

func TestCreatePost_MissingSessionID(t *testing.T) {
	h := NewFeedHandler(&mockFeedStore{}, &mockChatStore{}, &mockWorkoutsClient{}, &mockProfileClient{}, nil)
	var buf bytes.Buffer
	_ = json.NewEncoder(&buf).Encode(types.CreateFeedPostRequest{SessionID: "  "})
	rr := httptest.NewRecorder()
	req := withClaims(httptest.NewRequest(http.MethodPost, "/posts", &buf), 1)
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestCreatePost_OK(t *testing.T) {
	sid := "s1"
	now := time.Now()
	h := NewFeedHandler(
		&mockFeedStore{
			insertPost: func(authorID int, sessionID string, description string, location *string, communityID *string, kind string) (*types.FeedPostRow, error) {
				assert.Equal(t, 1, authorID)
				assert.Equal(t, sid, sessionID)
				return &types.FeedPostRow{ID: "p1", AuthorID: "1", SessionID: &sid, Kind: "personal", Description: description, CreatedAt: now}, nil
			},
		},
		&mockChatStore{},
		&mockWorkoutsClient{fetch: func(ctx context.Context, ids []string) (map[string]types.SessionPreviewItem, error) {
			return map[string]types.SessionPreviewItem{"s1": {ID: "s1", Title: "T"}}, nil
		}},
		&mockProfileClient{fetch: func(ctx context.Context, ids []int) (map[int]clients.ProfilePreview, error) {
			return map[int]clients.ProfilePreview{1: {UserID: 1, Name: "A", AvatarSystemName: "a"}}, nil
		}},
		nil,
	)

	var buf bytes.Buffer
	require.NoError(t, json.NewEncoder(&buf).Encode(types.CreateFeedPostRequest{SessionID: sid, Description: " hi "}))
	rr := httptest.NewRecorder()
	req := withClaims(httptest.NewRequest(http.MethodPost, "/posts", &buf), 1)
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusCreated, rr.Code)
}

func TestLikePost_NotFoundWhenMissingPostID(t *testing.T) {
	h := NewFeedHandler(&mockFeedStore{}, &mockChatStore{}, &mockWorkoutsClient{}, &mockProfileClient{}, nil)
	rr := httptest.NewRecorder()
	req := withClaims(httptest.NewRequest(http.MethodPost, "/posts//like", nil), 1)
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusNotFound, rr.Code)
}

func TestLikePost_OK(t *testing.T) {
	h := NewFeedHandler(
		&mockFeedStore{
			postExists: func(postID string) (bool, error) { return true, nil },
			likePost:   func(postID string, userID int) error { return nil },
			getLikeState: func(postID string, userID int) (*types.FeedLikeResponse, error) {
				return &types.FeedLikeResponse{PostID: postID, LikesCount: 1, IsLiked: true}, nil
			},
			getAuthorID: func(postID string) (int, error) { return 2, nil },
		},
		&mockChatStore{},
		&mockWorkoutsClient{},
		&mockProfileClient{},
		nil, // avoid async perks event in unit test
	)

	rr := httptest.NewRecorder()
	req := withClaims(httptest.NewRequest(http.MethodPost, "/posts/p1/like", nil), 1)
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusOK, rr.Code)
	var resp types.FeedLikeResponse
	require.NoError(t, json.NewDecoder(rr.Body).Decode(&resp))
	assert.True(t, resp.IsLiked)
}

