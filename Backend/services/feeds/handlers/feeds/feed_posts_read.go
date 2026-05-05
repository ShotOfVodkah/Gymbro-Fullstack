package feeds

import (
	"encoding/json"
	"errors"
	"fmt"
	"time"
	"net/http"
	"strconv"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexandra-gritsaenko/gymbro-feeds/clients"
	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

var (
	errFeedSessionPreviews = errors.New("feed: session previews")
	errFeedAuthorProfiles  = errors.New("feed: author profiles")
)

func (h *FeedHandler) GetFeed(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	limit := parseFeedPageLimit(r)
	cursor := parseFeedCursor(r)
	scope := parseFeedScope(r)

	rows, err := h.store.ListFeedPostsForUserPaginated(claims.UserID, limit+1, cursor, scope,)
	
	if err != nil {
		http.Error(w, "failed to load posts", http.StatusInternalServerError)
		return
	}

	hasMore := len(rows) > limit
	if hasMore {
		rows = rows[:limit]
	}

	respItems, err := h.buildFeedPostListResponse(r, rows)
	if err != nil {
		writeFeedPostListFetchError(w, err)
		return
	}

	var nextCursor *time.Time
	if hasMore && len(rows) > 0 {
		lastCreatedAt := rows[len(rows)-1].CreatedAt
		nextCursor = &lastCreatedAt
	}

	resp := types.FeedPageResponse{
		Items:      respItems,
		NextCursor: nextCursor,
		HasMore:    hasMore,
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

	resp, err := h.buildFeedPostListResponse(r, rows)
	if err != nil {
		writeFeedPostListFetchError(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
}

func writeFeedPostListFetchError(w http.ResponseWriter, err error) {
	switch {
	case errors.Is(err, errFeedSessionPreviews):
		http.Error(w, "failed to fetch session previews", http.StatusInternalServerError)
	case errors.Is(err, errFeedAuthorProfiles):
		http.Error(w, "failed to fetch author profiles", http.StatusInternalServerError)
	default:
		http.Error(w, "failed to build feed response", http.StatusInternalServerError)
	}
}

func (h *FeedHandler) buildFeedPostListResponse(r *http.Request, rows []types.FeedPostRow) ([]types.FeedPostItemResponse, error) {
	sessionIDs := uniqueSessionIDs(rows)
	sessionMap, err := h.workoutsClient.FetchSessionPreviews(r.Context(), sessionIDs)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", errFeedSessionPreviews, err)
	}

	authorIDs := uniqueAuthorIDs(rows)
	profilesMap, err := h.profileClient.FetchProfilesBatch(r.Context(), authorIDs)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", errFeedAuthorProfiles, err)
	}

	resp := make([]types.FeedPostItemResponse, 0, len(rows))
	for _, row := range rows {
		resp = append(resp, h.buildFeedPostResponse(r, row, sessionMap, profilesMap))
	}
	return resp, nil
}

func (h *FeedHandler) buildFeedPostResponse(
	r *http.Request,
	row types.FeedPostRow,
	sessionMap map[string]types.SessionPreviewItem,
	profilesMap map[int]clients.ProfilePreview,
) types.FeedPostItemResponse {
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

	return item
}
