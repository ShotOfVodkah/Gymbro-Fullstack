package feeds

import (
	"strconv"
	"net/http"

	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

const (
	defaultFeedPageLimit = 20
	maxFeedPageLimit     = 50
)

func parseFeedPageLimit(r *http.Request) int {
	raw := r.URL.Query().Get("limit")
	if raw == "" {
		return defaultFeedPageLimit
	}

	limit, err := strconv.Atoi(raw)
	if err != nil || limit <= 0 {
		return defaultFeedPageLimit
	}

	if limit > maxFeedPageLimit {
		return maxFeedPageLimit
	}

	return limit
}

func parseFeedCursor(r *http.Request) *string {
	raw := r.URL.Query().Get("cursor")
	if raw == "" {
		return nil
	}

	return &raw
}

func parseFeedScope(r *http.Request) types.FeedScope {
	raw := r.URL.Query().Get("scope")
	if raw == "" {
		return types.FeedScopeAll
	}

	switch types.FeedScope(raw) {
	case types.FeedScopeAll,
		types.FeedScopeFriends,
		types.FeedScopeDirect,
		types.FeedScopeGroups,
		types.FeedScopeMine:
		return types.FeedScope(raw)
	default:
		return types.FeedScopeAll
	}
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
