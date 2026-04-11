package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/alexandra-gritsaenko/gymbro-feeds/clients"
	"github.com/alexandra-gritsaenko/gymbro-feeds/store"
	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

type FeedHandler struct {
	store          store.FeedStore
	workoutsClient *clients.WorkoutsClient
}

func NewFeedHandler(store store.FeedStore, workoutsClient *clients.WorkoutsClient) *FeedHandler {
	return &FeedHandler{
		store:          store,
		workoutsClient: workoutsClient,
	}
}

func (h *FeedHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch {
	case r.Method == http.MethodGet && r.URL.Path == "/feed":
		h.GetFeed(w, r)
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

	workoutIDs := uniqueWorkoutIDs(rows)

	workoutMap, err := h.workoutsClient.FetchWorkoutPreviews(r.Context(), workoutIDs)
	if err != nil {
		http.Error(w, "failed to fetch workout previews", http.StatusInternalServerError)
		return
	}

	resp := make([]types.FeedPostItemResponse, 0, len(rows))
	for _, row := range rows {
		item := types.FeedPostItemResponse{
			ID: row.ID,
			Author: types.FeedAuthorPreview{
				ID:        row.AuthorID,
				Name:      "Unknown user",
				AvatarURL: "person.circle",
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

		if row.WorkoutID != nil {
			if preview, ok := workoutMap[*row.WorkoutID]; ok {
				item.Workout = &types.FeedWorkoutPreview{
					ID:               preview.ID,
					Title:            preview.Title,
					Category:         preview.Category,
					DurationMinutes:  preview.DurationMinutes,
					ExerciseCount:    preview.ExerciseCount,
					ExercisesPreview: mapWorkoutExercises(preview.ExercisesPreview),
				}
			}
		}

		resp = append(resp, item)
	}

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
}

func uniqueWorkoutIDs(rows []types.FeedPostRow) []string {
	seen := make(map[string]struct{})
	out := make([]string, 0)

	for _, row := range rows {
		if row.WorkoutID == nil || *row.WorkoutID == "" {
			continue
		}
		if _, ok := seen[*row.WorkoutID]; ok {
			continue
		}
		seen[*row.WorkoutID] = struct{}{}
		out = append(out, *row.WorkoutID)
	}

	return out
}

func mapWorkoutExercises(items []types.WorkoutPreviewExercise) []types.FeedWorkoutExercisePreview {
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