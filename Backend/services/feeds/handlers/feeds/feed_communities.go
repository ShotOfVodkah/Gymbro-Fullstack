package feeds

import (
	"encoding/json"
	"net/http"

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
