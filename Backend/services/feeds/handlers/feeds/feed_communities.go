package feeds

import (
	"encoding/json"
	"net/http"
	"sort"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexandra-gritsaenko/gymbro-feeds/clients"
	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

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

	communityIDs := make([]string, 0, len(rows))
	otherUserIDs := make([]int, 0)
	seenUsers := make(map[int]struct{})

	for _, row := range rows {
		communityIDs = append(communityIDs, row.ID)

		if row.OtherUserID == nil {
			continue
		}

		if _, ok := seenUsers[*row.OtherUserID]; ok {
			continue
		}

		seenUsers[*row.OtherUserID] = struct{}{}
		otherUserIDs = append(otherUserIDs, *row.OtherUserID)
	}

	metaByCommunityID, err := h.chatStore.ListCommunityPreviewMeta(communityIDs, claims.UserID)
	if err != nil {
		http.Error(w, "failed to load community previews", http.StatusInternalServerError)
		return
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

		meta := metaByCommunityID[row.ID]

		resp = append(resp, types.FeedCommunityItemResponse{
			ID:                 row.ID,
			Title:              row.Title,
			DisplayTitle:       displayTitle,
			Kind:               row.Kind,
			Icon:               mapCommunityIcon(row.Kind),
			IsSystemImage:      true,
			MembersCount:       row.MembersCount,
			UnreadCount:        meta.UnreadCount,
			LastMessagePreview: meta.LastMessagePreview,
			LastMessageAt:      meta.LastMessageAt,
		})
	}

	sort.Slice(resp, func(i, j int) bool {
		left := resp[i].LastMessageAt
		right := resp[j].LastMessageAt

		if left == nil && right == nil {
			return resp[i].DisplayTitle < resp[j].DisplayTitle
		}

		if left == nil {
			return false
		}

		if right == nil {
			return true
		}

		return left.After(*right)
	})

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
}