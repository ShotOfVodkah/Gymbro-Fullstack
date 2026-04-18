package handlers

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexandra-gritsaenko/gymbro-feeds/clients"
	"github.com/alexandra-gritsaenko/gymbro-feeds/store"
	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

type FeedHandler struct {
	store          store.FeedStore
	workoutsClient *clients.WorkoutsClient
	profileClient  *clients.ProfileClient
}

func NewFeedHandler(store store.FeedStore, workoutsClient *clients.WorkoutsClient, profileClient *clients.ProfileClient) *FeedHandler {
	return &FeedHandler{
		store:          store,
		workoutsClient: workoutsClient,
		profileClient:  profileClient,
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

func (h *FeedHandler) GetFeed(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	rows, err := h.store.ListFeedPostsForUser(claims.UserID)
	if err != nil {
		http.Error(w, "failed to load posts", http.StatusInternalServerError)
		return
	}

	sessionIDs := uniqueSessionIDs(rows)
	sessionMap, err := h.workoutsClient.FetchSessionPreviews(r.Context(), sessionIDs)
	if err != nil {
		http.Error(w, "failed to fetch session previews", http.StatusInternalServerError)
		return
	}

	authorIDs := uniqueAuthorIDs(rows)
	profilesMap, err := h.profileClient.FetchProfilesBatch(r.Context(), authorIDs)
	if err != nil {
		http.Error(w, "failed to fetch author profiles", http.StatusInternalServerError)
		return
	}

	resp := make([]types.FeedPostItemResponse, 0, len(rows))
	for _, row := range rows {
		authorName := "Unknown user"
		authorAvatar := "person.circle"

		authorIDInt, err := strconv.Atoi(row.AuthorID)
		if err == nil {
			if profile, ok := profilesMap[authorIDInt]; ok {
				authorName = profile.Name
				authorAvatar = profile.AvatarSystemName
			}
		}
		item := types.FeedPostItemResponse{
			ID: row.ID,
			Author: types.FeedAuthorPreview{
				ID:        row.AuthorID,
				Name:      authorName,
				AvatarURL: authorAvatar,
			},
			Description:          row.Description,
			Location:             row.Location,
			CreatedAt:            row.CreatedAt,
			LikesCount:           row.LikesCount,
			CommentsCount:        row.CommentsCount,
			IsLiked:              row.IsLiked,
			Kind:                 row.Kind,
			IsFromFollowing:      row.IsFromFollowing,
			IsFromDirectChat:     row.IsFromDirectChat,
			IsFromGroupCommunity: row.IsFromGroupCommunity,
		}

		if row.CommunityID != nil {
			title := "Community"
			if row.CommunityTitle != nil && *row.CommunityTitle != "" {
				title = *row.CommunityTitle
			}

			item.Community = &types.FeedCommunityPreview{
				ID:    *row.CommunityID,
				Title: title,
			}
		}

		if row.SessionID != nil {
			if preview, ok := sessionMap[*row.SessionID]; ok {
				item.Workout = &types.FeedWorkoutPreview{
					ID:               preview.ID,
					Title:            preview.Title,
					Category:         preview.Category,
					DurationMinutes:  preview.DurationMinutes,
					ExerciseCount:    preview.ExerciseCount,
					ExercisesPreview: mapSessionExercises(preview.ExercisesPreview),
				}
			}
		}

		resp = append(resp, item)
	}

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
}

func (h *FeedHandler) GetUserPosts(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	userIDStr := extractUserIDFromFeedPostsPath(r.URL.Path)
	if userIDStr == "" {
		http.NotFound(w, r)
		return
	}

	rows, err := h.store.ListPostsByAuthorID(userIDStr, claims.UserID)
	if err != nil {
		http.Error(w, "failed to load user posts", http.StatusInternalServerError)
		return
	}

	sessionIDs := uniqueSessionIDs(rows)
	sessionMap, err := h.workoutsClient.FetchSessionPreviews(r.Context(), sessionIDs)
	if err != nil {
		http.Error(w, "failed to fetch session previews", http.StatusInternalServerError)
		return
	}

	authorIDs := uniqueAuthorIDs(rows)
	profilesMap, err := h.profileClient.FetchProfilesBatch(r.Context(), authorIDs)
	if err != nil {
		http.Error(w, "failed to fetch author profiles", http.StatusInternalServerError)
		return
	}

	resp := make([]types.FeedPostItemResponse, 0, len(rows))
	for _, row := range rows {
		authorName := "Unknown user"
		authorAvatar := "person.circle"

		authorIDInt, err := strconv.Atoi(row.AuthorID)
		if err == nil {
			if profile, ok := profilesMap[authorIDInt]; ok {
				authorName = profile.Name
				authorAvatar = profile.AvatarSystemName
			}
		}

		item := types.FeedPostItemResponse{
			ID: row.ID,
			Author: types.FeedAuthorPreview{
				ID:        row.AuthorID,
				Name:      authorName,
				AvatarURL: authorAvatar,
			},
			Description:          row.Description,
			Location:             row.Location,
			CreatedAt:            row.CreatedAt,
			LikesCount:           row.LikesCount,
			CommentsCount:        row.CommentsCount,
			IsLiked:              row.IsLiked,
			Kind:                 row.Kind,
			IsFromFollowing:      row.IsFromFollowing,
			IsFromDirectChat:     row.IsFromDirectChat,
			IsFromGroupCommunity: row.IsFromGroupCommunity,
		}

		if row.CommunityID != nil {
			title := "Community"
			if row.CommunityTitle != nil && *row.CommunityTitle != "" {
				title = *row.CommunityTitle
			}

			item.Community = &types.FeedCommunityPreview{
				ID:    *row.CommunityID,
				Title: title,
			}
		}

		if row.SessionID != nil {
			if preview, ok := sessionMap[*row.SessionID]; ok {
				item.Workout = &types.FeedWorkoutPreview{
					ID:               preview.ID,
					Title:            preview.Title,
					Category:         preview.Category,
					DurationMinutes:  preview.DurationMinutes,
					ExerciseCount:    preview.ExerciseCount,
					ExercisesPreview: mapSessionExercises(preview.ExercisesPreview),
				}
			}
		}

		resp = append(resp, item)
	}

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
}

func (h *FeedHandler) GetCommunities(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	rows, err := h.store.ListCommunitiesForUser(claims.UserID)
	if err != nil {
		http.Error(w, "failed to load communities", http.StatusInternalServerError)
		return
	}

	otherUserIDs := make([]int, 0)
	seen := make(map[int]struct{})
	for _, row := range rows {
		if row.OtherUserID == nil {
			continue
		}
		if _, ok := seen[*row.OtherUserID]; ok {
			continue
		}
		seen[*row.OtherUserID] = struct{}{}
		otherUserIDs = append(otherUserIDs, *row.OtherUserID)
	}

	profilesMap := map[int]clients.ProfilePreview{}
	if len(otherUserIDs) > 0 {
		profilesMap, err = h.profileClient.FetchProfilesBatch(r.Context(), otherUserIDs)
		if err != nil {
			http.Error(w, "failed to fetch community profiles", http.StatusInternalServerError)
			return
		}
	}

	resp := make([]types.FeedCommunityItemResponse, 0, len(rows))
	for _, row := range rows {
		displayTitle := row.Title

		if row.Kind == "direct" && row.OtherUserID != nil {
			if profile, ok := profilesMap[*row.OtherUserID]; ok && profile.Name != "" {
				displayTitle = profile.Name
			}
		}

		resp = append(resp, types.FeedCommunityItemResponse{
			ID:            row.ID,
			Title:         row.Title,
			DisplayTitle:  displayTitle,
			Kind:          row.Kind,
			Icon:          mapCommunityIcon(row.Kind),
			IsSystemImage: true,
			MembersCount:  row.MembersCount,
		})
	}

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
}

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

	resp, err := h.buildCommentResponses(r, []types.FeedCommentRow{*row})
	if err != nil || len(resp) == 0 {
		http.Error(w, "failed to build comment response", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	_ = json.NewEncoder(w).Encode(resp[0])
}

func (h *FeedHandler) LikePost(w http.ResponseWriter, r *http.Request) {
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

	if err := h.store.LikePost(postID, claims.UserID); err != nil {
		http.Error(w, "failed to like post", http.StatusInternalServerError)
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

func (h *FeedHandler) UnlikePost(w http.ResponseWriter, r *http.Request) {
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

	if err := h.store.UnlikePost(postID, claims.UserID); err != nil {
		http.Error(w, "failed to unlike post", http.StatusInternalServerError)
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

func uniqueSessionIDs(rows []types.FeedPostRow) []string {
	seen := make(map[string]struct{})
	out := make([]string, 0)

	for _, row := range rows {
		if row.SessionID == nil || *row.SessionID == "" {
			continue
		}
		if _, ok := seen[*row.SessionID]; ok {
			continue
		}
		seen[*row.SessionID] = struct{}{}
		out = append(out, *row.SessionID)
	}

	return out
}

func uniqueAuthorIDs(rows []types.FeedPostRow) []int {
	seen := make(map[int]struct{})
	out := make([]int, 0)

	for _, row := range rows {
		authorID, err := strconv.Atoi(row.AuthorID)
		if err != nil {
			continue
		}

		if _, ok := seen[authorID]; ok {
			continue
		}

		seen[authorID] = struct{}{}
		out = append(out, authorID)
	}

	return out
}

func mapSessionExercises(items []types.SessionPreviewExercise) []types.FeedWorkoutExercisePreview {
	result := make([]types.FeedWorkoutExercisePreview, 0, len(items))
	for _, item := range items {
		result = append(result, types.FeedWorkoutExercisePreview{
			ID:              item.ID,
			Name:            item.Name,
			Type:            item.Type,
			MuscleGroup:     item.MuscleGroup,
			Sets:            item.Sets,
			Reps:            item.Reps,
			WeightKg:        item.WeightKg,
			DurationMinutes: item.DurationMinutes,
			Pace:            item.Pace,
			HoldSeconds:     item.HoldSeconds,
			BreathCount:     item.BreathCount,
		})
	}
	return result
}

func mapCommunityIcon(kind string) string {
	switch kind {
	case "direct":
		return "person.fill"
	case "joined_group":
		return "person.3.fill"
	default:
		return "person.3.fill"
	}
}

func hasSuffix(path string, suffix string) bool {
	return len(path) >= len(suffix) && path[len(path)-len(suffix):] == suffix
}

func extractPostID(path string, suffix string) string {
	prefix := "/posts/"
	if len(path) <= len(prefix)+len(suffix) {
		return ""
	}

	value := path[len(prefix):]
	value = value[:len(value)-len(suffix)]
	if value == "" {
		return ""
	}
	return value
}

func extractUserIDFromFeedPostsPath(path string) string {

	prefix := "/feed/users/"
	suffix := "/posts"
	if len(path) <= len(prefix)+len(suffix) {
		return ""
	}
	value := path[len(prefix):]
	value = value[:len(value)-len(suffix)]
	if value == "" {
		return ""
	}
	return value

}