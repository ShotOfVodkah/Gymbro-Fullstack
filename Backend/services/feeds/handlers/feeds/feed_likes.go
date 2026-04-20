package feeds

import (
	"encoding/json"
	"net/http"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
)

func (h *FeedHandler) LikePost(w http.ResponseWriter, r *http.Request) {
	h.togglePostLike(w, r, true)
}

func (h *FeedHandler) UnlikePost(w http.ResponseWriter, r *http.Request) {
	h.togglePostLike(w, r, false)
}

func (h *FeedHandler) togglePostLike(w http.ResponseWriter, r *http.Request, like bool) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	postID := extractPostID(r.URL.Path, "/like")
	if postID == "" {
		http.NotFound(w, r)
		return
	}

	exists, err := h.store.PostExists(postID)
	if err != nil {
		http.Error(w, "failed to check post", http.StatusInternalServerError)
		return
	}
	if !exists {
		http.NotFound(w, r)
		return
	}

	if like {
		err = h.store.LikePost(postID, claims.UserID)
	} else {
		err = h.store.UnlikePost(postID, claims.UserID)
	}
	if err != nil {
		if like {
			http.Error(w, "failed to like post", http.StatusInternalServerError)
		} else {
			http.Error(w, "failed to unlike post", http.StatusInternalServerError)
		}
		return
	}

	resp, err := h.store.GetPostLikeState(postID, claims.UserID)
	if err != nil {
		http.Error(w, "failed to fetch like state", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
}
