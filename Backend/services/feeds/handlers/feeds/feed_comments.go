package feeds

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

func (h *FeedHandler) GetPostComments(w http.ResponseWriter, r *http.Request) {
	postID := extractPostID(r.URL.Path, "/comments")
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

	rows, err := h.store.ListCommentsByPostID(postID)
	if err != nil {
		http.Error(w, "failed to load comments", http.StatusInternalServerError)
		return
	}

	resp, err := h.buildCommentResponses(r, rows)
	if err != nil {
		http.Error(w, "failed to build comments", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
}

func (h *FeedHandler) CreatePostComment(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	postID := extractPostID(r.URL.Path, "/comments")
	if postID == "" {
		http.NotFound(w, r)
		return
	}

	var req types.CreateFeedCommentRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "bad request", http.StatusBadRequest)
		return
	}

	if req.Text == "" {
		http.Error(w, "text is required", http.StatusBadRequest)
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

	row, err := h.store.InsertComment(postID, claims.UserID, req.Text)
	if err != nil {
		http.Error(w, "failed to create comment", http.StatusInternalServerError)
		return
	}
	h.sendPostCommentReceivedEvent(postID, claims.UserID)

	resp, err := h.buildCommentResponses(r, []types.FeedCommentRow{*row})
	if err != nil || len(resp) == 0 {
		http.Error(w, "failed to build comment response", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	_ = json.NewEncoder(w).Encode(resp[0])
}

func (h *FeedHandler) buildCommentResponses(r *http.Request, rows []types.FeedCommentRow) ([]types.FeedCommentResponse, error) {
	if len(rows) == 0 {
		return []types.FeedCommentResponse{}, nil
	}

	seen := make(map[int]struct{})
	authorIDs := make([]int, 0)

	for _, row := range rows {
		if _, ok := seen[row.AuthorID]; ok {
			continue
		}
		seen[row.AuthorID] = struct{}{}
		authorIDs = append(authorIDs, row.AuthorID)
	}

	profilesMap, err := h.profileClient.FetchProfilesBatch(r.Context(), authorIDs)
	if err != nil {
		return nil, err
	}

	resp := make([]types.FeedCommentResponse, 0, len(rows))
	for _, row := range rows {
		authorName := "Unknown user"
		authorAvatar := "person.circle"

		if profile, ok := profilesMap[row.AuthorID]; ok {
			authorName = profile.Name
			authorAvatar = profile.AvatarSystemName
		}

		resp = append(resp, types.FeedCommentResponse{
			ID: row.ID,
			Author: types.FeedAuthorPreview{
				ID:        strconv.Itoa(row.AuthorID),
				Name:      authorName,
				AvatarURL: authorAvatar,
			},
			Text:      row.Content,
			CreatedAt: row.CreatedAt,
		})
	}

	return resp, nil
}

func (h *FeedHandler) sendPostCommentReceivedEvent(postID string, commenterID int) {
	if h.perksClient == nil {
		return
	}

	postAuthorID, err := h.store.GetPostAuthorID(postID)
	if err != nil {
		return
	}

	if postAuthorID == commenterID {
		return
	}

	go func() {
		_ = h.perksClient.SendEventForUser(
			postAuthorID,
			"post_comment_received",
			map[string]string{
				"post_id":      postID,
				"commenter_id": strconv.Itoa(commenterID),
			},
		)
	}()
}