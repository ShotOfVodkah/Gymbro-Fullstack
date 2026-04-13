package handlers

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexandra-gritsaenko/gymbro-feeds/clients"
	"github.com/alexandra-gritsaenko/gymbro-feeds/store"
	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

type PeopleHandler struct {
	store         store.PeopleStore
	profileClient *clients.ProfileClient
}

func NewPeopleHandler(
	store store.PeopleStore,
	profileClient *clients.ProfileClient,
) *PeopleHandler {
	return &PeopleHandler{
		store:         store,
		profileClient: profileClient,
	}
}

func (h *PeopleHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch {
	case r.Method == http.MethodGet && r.URL.Path == "/people/friends":
		h.GetFriends(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/people/following":
		h.GetFollowing(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/people/discover":
		h.GetDiscover(w, r)
		return
	case r.Method == http.MethodGet && strings.HasPrefix(r.URL.Path, "/people/") && !strings.HasSuffix(r.URL.Path, "/follow"):
		h.GetPerson(w, r)
		return
	case r.Method == http.MethodPost && strings.HasSuffix(r.URL.Path, "/follow"):
		h.FollowPerson(w, r)
		return
	case r.Method == http.MethodDelete && strings.HasSuffix(r.URL.Path, "/follow"):
		h.UnfollowPerson(w, r)
		return
	default:
		http.NotFound(w, r)
	}
}

func (h *PeopleHandler) GetFriends(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	ids, err := h.store.ListFriendIDsForUser(claims.UserID)
	if err != nil {
		http.Error(w, "failed to load friends", http.StatusInternalServerError)
		return
	}

	resp, err := h.buildPeopleResponse(r, claims.UserID, ids)
	if err != nil {
		http.Error(w, "failed to build friends response", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
}

func (h *PeopleHandler) GetFollowing(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	ids, err := h.store.ListFollowingIDsForUser(claims.UserID)
	if err != nil {
		http.Error(w, "failed to load following", http.StatusInternalServerError)
		return
	}

	resp, err := h.buildPeopleResponse(r, claims.UserID, ids)
	if err != nil {
		http.Error(w, "failed to build following response", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
}

func (h *PeopleHandler) GetDiscover(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	allProfiles, err := h.profileClient.FetchAllProfiles(r.Context())
	if err != nil {
		http.Error(w, "failed to load profiles", http.StatusInternalServerError)
		return
	}

	followedIDs, err := h.store.ListAllFollowedIDsForUser(claims.UserID)
	if err != nil {
		http.Error(w, "failed to load following", http.StatusInternalServerError)
		return
	}

	followedSet := make(map[int]struct{}, len(followedIDs))
	for _, id := range followedIDs {
		followedSet[id] = struct{}{}
	}

	ids := make([]int, 0)
	for id := range allProfiles {
		if id == claims.UserID {
			continue
		}
		if _, ok := followedSet[id]; ok {
			continue
		}
		ids = append(ids, id)
	}

	resp, err := h.buildPeopleResponse(r, claims.UserID, ids)
	if err != nil {
		http.Error(w, "failed to build discover response", http.StatusInternalServerError)
		return
	}

	query := strings.TrimSpace(strings.ToLower(r.URL.Query().Get("q")))
	if query != "" {
		filtered := make([]types.PersonItemResponse, 0, len(resp))
		for _, person := range resp {
			if strings.Contains(strings.ToLower(person.Name), query) ||
				strings.Contains(strings.ToLower(person.Username), query) ||
				strings.Contains(strings.ToLower(person.Subtitle), query) ||
				strings.Contains(strings.ToLower(person.Status), query) {
				filtered = append(filtered, person)
			}
		}
		resp = filtered
	}

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
}

func (h *PeopleHandler) GetPerson(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	idStr := strings.TrimPrefix(r.URL.Path, "/people/")
	personID, err := strconv.Atoi(idStr)
	if err != nil {
		http.NotFound(w, r)
		return
	}

	resp, err := h.buildPeopleResponse(r, claims.UserID, []int{personID})
	if err != nil {
		http.Error(w, "failed to load person", http.StatusInternalServerError)
		return
	}
	if len(resp) == 0 {
		http.NotFound(w, r)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp[0])
}

func (h *PeopleHandler) FollowPerson(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	personID, ok := personIDFromFollowPath(r.URL.Path)
	if !ok {
		http.NotFound(w, r)
		return
	}

	if personID == claims.UserID {
		http.Error(w, "cannot follow yourself", http.StatusBadRequest)
		return
	}

	if err := h.store.Follow(claims.UserID, personID); err != nil {
		http.Error(w, "failed to follow person", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func (h *PeopleHandler) UnfollowPerson(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	personID, ok := personIDFromFollowPath(r.URL.Path)
	if !ok {
		http.NotFound(w, r)
		return
	}

	if err := h.store.Unfollow(claims.UserID, personID); err != nil {
		http.Error(w, "failed to unfollow person", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func (h *PeopleHandler) buildPeopleResponse(
	r *http.Request,
	currentUserID int,
	ids []int,
) ([]types.PersonItemResponse, error) {
	if len(ids) == 0 {
		return []types.PersonItemResponse{}, nil
	}

	profilesMap, err := h.profileClient.FetchProfilesBatch(r.Context(), ids)
	if err != nil {
		return nil, err
	}

	resp := make([]types.PersonItemResponse, 0, len(ids))
	for _, id := range ids {
		profile, ok := profilesMap[id]
		if !ok {
			continue
		}

		isFollowing, err := h.store.IsFollowing(currentUserID, id)
		if err != nil {
			return nil, err
		}

		isFriend, err := h.store.IsFriend(currentUserID, id)
		if err != nil {
			return nil, err
		}

		resp = append(resp, types.PersonItemResponse{
			ID:                strconv.Itoa(profile.UserID),
			Name:              profile.Name,
			Username:          profile.Username,
			Status:            profile.Status,
			Subtitle:          profile.Subtitle,
			AvatarSystemName:  profile.AvatarSystemName,
			IsFollowing:       isFollowing,
			IsCurrentFriend:   isFriend,
			Badge:             profile.Badge,
			WorkoutsThisMonth: profile.WorkoutsThisMonth,
		})
	}

	return resp, nil
}

func personIDFromFollowPath(path string) (int, bool) {
	path = strings.TrimSuffix(path, "/follow")
	path = strings.TrimPrefix(path, "/people/")
	id, err := strconv.Atoi(path)
	if err != nil {
		return 0, false
	}
	return id, true
}