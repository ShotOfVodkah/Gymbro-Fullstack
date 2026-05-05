package feeds

import (
	"net/http"

	"github.com/alexandra-gritsaenko/gymbro-feeds/clients"
	"github.com/alexandra-gritsaenko/gymbro-feeds/store"
)

type FeedHandler struct {
	store          store.FeedStore
	chatStore      store.ChatStore
	workoutsClient *clients.WorkoutsClient
	profileClient  *clients.ProfileClient
	shareService   *ShareService
	perksClient    *clients.PerksClient
}

func NewFeedHandler(
	store store.FeedStore, 
	chatStore store.ChatStore,
	workoutsClient *clients.WorkoutsClient, 
	profileClient *clients.ProfileClient, 
	perksClient *clients.PerksClient,
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
