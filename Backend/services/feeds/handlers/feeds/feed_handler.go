package feeds

import (
	"context"
	"net/http"

	"github.com/alexandra-gritsaenko/gymbro-feeds/clients"
	"github.com/alexandra-gritsaenko/gymbro-feeds/store"
	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

type FeedHandler struct {
	store          FeedStore
	chatStore      ChatStore
	workoutsClient WorkoutsClient
	profileClient  ProfileClient
	shareService   *ShareService
	perksClient    PerksClient
}

type FeedStore interface {
	ListFeedPostsForUserPaginated(userID int, limit int, cursor *string, scope types.FeedScope) ([]types.FeedPostRow, error)
	ListPostsByAuthorID(authorID string, currentUserID int) ([]types.FeedPostRow, error)
	ListCommunitiesForUser(userID int) ([]types.FeedCommunityRow, error)
	InsertPost(authorID int, sessionID string, description string, location *string, communityID *string, kind string) (*types.FeedPostRow, error)
	PostExists(postID string) (bool, error)
	ListCommentsByPostID(postID string) ([]types.FeedCommentRow, error)
	InsertComment(postID string, authorID int, content string) (*types.FeedCommentRow, error)
	LikePost(postID string, userID int) error
	UnlikePost(postID string, userID int) error
	GetPostLikeState(postID string, userID int) (*types.FeedLikeResponse, error)
	GetPostAuthorID(postID string) (int, error)
}

type ChatStore interface {
	ListCommunityPreviewMeta(communityIDs []string, userID int) (map[string]store.ChatPreviewMeta, error)
	FindOrCreateDirectCommunity(userA, userB int) (*store.Community, bool, error)
	IsCommunityMember(communityID string, userID int) (bool, error)
	InsertMessage(communityID string, senderID int, kind string, text, sessionID *string) (*store.CommunityMessage, error)
}

type WorkoutsClient interface {
	FetchSessionPreviews(ctx context.Context, ids []string) (map[string]types.SessionPreviewItem, error)
}

type ProfileClient interface {
	FetchProfilesBatch(ctx context.Context, ids []int) (map[int]clients.ProfilePreview, error)
}

type PerksClient interface {
	SendEventForUser(userID int, eventType string, metadata map[string]string) error
}

func NewFeedHandler(
	store FeedStore,
	chatStore ChatStore,
	workoutsClient WorkoutsClient,
	profileClient ProfileClient,
	perksClient PerksClient,
	) *FeedHandler {
	return &FeedHandler{
		store:          store,
		chatStore:      chatStore,
		workoutsClient: workoutsClient,
		profileClient:  profileClient,
		shareService:   NewShareService(store, chatStore),
		perksClient:    perksClient,
	}
}

func (h *FeedHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch {
	case r.Method == http.MethodGet && r.URL.Path == "/feed":
		h.GetFeed(w, r)
		return

	case r.Method == http.MethodGet && len(r.URL.Path) > len("/feed/users/") && hasSuffix(r.URL.Path, "/posts"):
		h.GetUserPosts(w, r)
		return

	case r.Method == http.MethodGet && r.URL.Path == "/communities":
		h.GetCommunities(w, r)
		return

	case r.Method == http.MethodPost && r.URL.Path == "/shares/workout":
		h.ShareWorkout(w, r)
		return

	case r.Method == http.MethodPost && r.URL.Path == "/posts":
		h.CreatePost(w, r)
		return

	case r.Method == http.MethodGet && len(r.URL.Path) > len("/posts/") && hasSuffix(r.URL.Path, "/comments"):
		h.GetPostComments(w, r)
		return

	case r.Method == http.MethodPost && len(r.URL.Path) > len("/posts/") && hasSuffix(r.URL.Path, "/comments"):
		h.CreatePostComment(w, r)
		return

	case r.Method == http.MethodPost && len(r.URL.Path) > len("/posts/") && hasSuffix(r.URL.Path, "/like"):
		h.LikePost(w, r)
		return

	case r.Method == http.MethodDelete && len(r.URL.Path) > len("/posts/") && hasSuffix(r.URL.Path, "/like"):
		h.UnlikePost(w, r)
		return

	default:
		http.NotFound(w, r)
	}
}
