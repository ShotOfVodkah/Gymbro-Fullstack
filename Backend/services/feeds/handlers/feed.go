package handlers

import (
	"encoding/json"
	"net/http"
	"strconv"

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
	case r.Method == http.MethodGet && r.URL.Path == "/communities":
		h.GetCommunities(w, r)
		return
	default:
		http.NotFound(w, r)
	}
}

func (h *FeedHandler) GetFeed(w http.ResponseWriter, r *http.Request) {
	claims, ok := GetClaims(r.Context())
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
			Description:           row.Description,
			Location:              row.Location,
			CreatedAt:             row.CreatedAt,
			LikesCount:            row.LikesCount,
			CommentsCount:         row.CommentsCount,
			IsLiked:               row.IsLiked,
			Kind:                  row.Kind,
			IsFromJoinedCommunity: row.IsFromJoinedCommunity,
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
	claims, ok := GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	rows, err := h.store.ListCommunitiesForUser(claims.UserID)
	if err != nil {
		http.Error(w, "failed to load communities", http.StatusInternalServerError)
		return
	}

	resp := make([]types.FeedCommunityItemResponse, 0, len(rows))
	for _, row := range rows {
		resp = append(resp, types.FeedCommunityItemResponse{
			ID:            row.ID,
			Title:         row.Title,
			Kind:          row.Kind,
			Icon:          mapCommunityIcon(row.Kind),
			IsSystemImage: true,
			MembersCount:  row.MembersCount,
		})
	}

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
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