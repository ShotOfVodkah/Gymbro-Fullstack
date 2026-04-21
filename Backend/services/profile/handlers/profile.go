package handlers

import (
	"bytes"
	"encoding/json"
	"errors"
	"net/http"
	"regexp"
	"strconv"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexandra-gritsaenko/gymbro-profile/clients"
	"github.com/alexandra-gritsaenko/gymbro-profile/store"
	"github.com/alexandra-gritsaenko/gymbro-profile/types"
)

var (
	reProfileByID         = regexp.MustCompile(`^/profiles/([0-9]+)$`)
	reProfileStatistics   = regexp.MustCompile(`^/profiles/([0-9]+)/statistics$`)
	reProfileMainByUserID = regexp.MustCompile(`^/profiles/([0-9]+)/main$`)
)

type ProfileHandler struct {
	store          store.ProfileStorer
	jwtSecret      []byte
	feeds          *clients.FeedsPeopleClient
	internalSecret string
}

func NewProfileHandler(s store.ProfileStorer, jwtSecret []byte, feeds *clients.FeedsPeopleClient, internalSecret string) *ProfileHandler {
	return &ProfileHandler{store: s, jwtSecret: jwtSecret, feeds: feeds, internalSecret: internalSecret}
}

func (h *ProfileHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")

	if r.URL.Path == "/profiles/internal/statistics" {
		if r.Method == http.MethodPost {
			h.postInternalStatistics(w, r)
			return
		}
		notFound(w, r)
		return
	}

	if r.URL.Path == "/profiles/batch" {
		if r.Method == http.MethodPost {
			h.GetProfilesBatch(w, r)
			return
		}
		notFound(w, r)
		return
	}

	if r.URL.Path == "/profiles" {
		if r.Method == http.MethodGet {
			h.ListProfiles(w, r)
			return
		}
		notFound(w, r)
		return
	}

	switch r.URL.Path {
	case "/profiles/me/statistics":
		if r.Method == http.MethodGet {
			h.getMeStatistics(w, r)
			return
		}
		notFound(w, r)
		return
	case "/profiles/me/settings":
		switch r.Method {
		case http.MethodGet:
			h.getMeSettings(w, r)
			return
		case http.MethodPatch:
			h.patchMeSettings(w, r)
			return
		default:
			notFound(w, r)
			return
		}
	case "/profiles/me/main":
		if r.Method == http.MethodGet {
			h.getMeMain(w, r)
			return
		}
		notFound(w, r)
		return
	case "/profiles/me":
		switch r.Method {
		case http.MethodGet:
			h.getMe(w, r)
			return
		case http.MethodPatch:
			h.patchMe(w, r)
			return
		default:
			notFound(w, r)
			return
		}
	}

	if m := reProfileStatistics.FindStringSubmatch(r.URL.Path); m != nil {
		if r.Method == http.MethodGet {
			h.getUserStatistics(w, r, m[1])
			return
		}
		notFound(w, r)
		return
	}

	if m := reProfileMainByUserID.FindStringSubmatch(r.URL.Path); m != nil {
		if r.Method == http.MethodGet {
			h.getUserMain(w, r, m[1])
			return
		}
		notFound(w, r)
		return
	}

	if m := reProfileByID.FindStringSubmatch(r.URL.Path); m != nil {
		if r.Method == http.MethodGet {
			h.GetProfileByID(w, r, m[1])
			return
		}
		notFound(w, r)
		return
	}

	notFound(w, r)
}

func (h *ProfileHandler) requireClaims(w http.ResponseWriter, r *http.Request) (*authmw.Claims, bool) {
	c, err := parseClaimsFromRequest(r, h.jwtSecret)
	if err != nil {
		unauthorized(w, r)
		return nil, false
	}
	return c, true
}

func (h *ProfileHandler) getMe(w http.ResponseWriter, r *http.Request) {
	claims, ok := h.requireClaims(w, r)
	if !ok {
		return
	}
	profile, err := h.store.GetByUserID(claims.UserID)
	if errors.Is(err, store.ErrNotFound) {
		notFound(w, r)
		return
	}
	if err != nil {
		internalServerError(w, r)
		return
	}
	resp := types.MeProfileResponse{
		UserID:           profile.UserID,
		Name:             profile.Name,
		Username:         profile.Username,
		Status:           profile.Status,
		Subtitle:         profile.Subtitle,
		Bio:              profile.Bio,
		AvatarSystemName: profile.AvatarSystemName,
	}
	_ = json.NewEncoder(w).Encode(resp)
}

func (h *ProfileHandler) patchMe(w http.ResponseWriter, r *http.Request) {
	claims, ok := h.requireClaims(w, r)
	if !ok {
		return
	}
	var body types.PatchMeRequest
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		badRequest(w, r)
		return
	}
	if err := h.store.PatchProfile(claims.UserID, body); errors.Is(err, store.ErrNotFound) {
		notFound(w, r)
		return
	} else if errors.Is(err, store.ErrUsernameTaken) {
		conflict(w, r, "username taken")
		return
	} else if err != nil {
		internalServerError(w, r)
		return
	}
	h.getMe(w, r)
}

func (h *ProfileHandler) getMeSettings(w http.ResponseWriter, r *http.Request) {
	claims, ok := h.requireClaims(w, r)
	if !ok {
		return
	}
	s, err := h.store.GetSettings(claims.UserID)
	if err != nil {
		internalServerError(w, r)
		return
	}
	_ = json.NewEncoder(w).Encode(settingsResponseFrom(s))
}

type settingsWire struct {
	PushNotificationsEnabled bool `json:"push_notifications_enabled"`
	WorkoutReminders         bool `json:"workout_reminders"`
	PrivateAccount           bool `json:"private_account"`
	ShowActivity             bool `json:"show_activity"`
	DiscoverVisibility       bool `json:"discover_visibility"`
}

func settingsResponseFrom(s *types.ProfileSettings) settingsWire {
	return settingsWire{
		PushNotificationsEnabled: s.PushNotificationsEnabled,
		WorkoutReminders:         s.WorkoutReminders,
		PrivateAccount:           s.PrivateAccount,
		ShowActivity:             s.ShowActivity,
		DiscoverVisibility:       s.DiscoverVisibility,
	}
}

func (h *ProfileHandler) patchMeSettings(w http.ResponseWriter, r *http.Request) {
	claims, ok := h.requireClaims(w, r)
	if !ok {
		return
	}
	var body types.PatchSettingsRequest
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		badRequest(w, r)
		return
	}
	if err := h.store.PatchSettings(claims.UserID, body); err != nil {
		internalServerError(w, r)
		return
	}
	h.getMeSettings(w, r)
}

func (h *ProfileHandler) getMeStatistics(w http.ResponseWriter, r *http.Request) {
	claims, ok := h.requireClaims(w, r)
	if !ok {
		return
	}
	h.writeStatisticsForUser(w, r, claims.UserID)
}

func (h *ProfileHandler) getUserStatistics(w http.ResponseWriter, r *http.Request, userIDStr string) {
	claims, ok := h.requireClaims(w, r)
	if !ok {
		return
	}
	targetID, err := strconv.Atoi(userIDStr)
	if err != nil {
		badRequest(w, r)
		return
	}
	allowed, aerr := h.allowViewPrivateStats(claims.UserID, targetID)
	if aerr != nil {
		internalServerError(w, r)
		return
	}
	if !allowed {
		forbidden(w, r)
		return
	}
	h.writeStatisticsForUser(w, r, targetID)
}

func (h *ProfileHandler) allowViewPrivateStats(viewerID, targetID int) (allowed bool, err error) {
	if viewerID == targetID {
		return true, nil
	}
	st, err := h.store.GetSettings(targetID)
	if err != nil {
		return false, err
	}
	if st.PrivateAccount {
		return false, nil
	}
	return true, nil
}

func (h *ProfileHandler) writeStatisticsForUser(w http.ResponseWriter, r *http.Request, targetUserID int) {
	raw, _, err := h.store.GetStatisticsRaw(targetUserID)
	if err != nil {
		internalServerError(w, r)
		return
	}
	doc := types.ParseStoredStatisticsPayload(raw)
	out := doc.ToStatisticsResponse(targetUserID)
	_ = json.NewEncoder(w).Encode(out)
}

func (h *ProfileHandler) getMeMain(w http.ResponseWriter, r *http.Request) {
	claims, ok := h.requireClaims(w, r)
	if !ok {
		return
	}
	h.writeMainForUser(w, r, claims.UserID, true)
}

func (h *ProfileHandler) getUserMain(w http.ResponseWriter, r *http.Request, userIDStr string) {
	claims, ok := h.requireClaims(w, r)
	if !ok {
		return
	}
	targetID, err := strconv.Atoi(userIDStr)
	if err != nil {
		badRequest(w, r)
		return
	}
	allowed, aerr := h.allowViewPrivateStats(claims.UserID, targetID)
	if aerr != nil {
		internalServerError(w, r)
		return
	}
	if !allowed {
		forbidden(w, r)
		return
	}
	h.writeMainForUser(w, r, targetID, false)
}

func (h *ProfileHandler) writeMainForUser(w http.ResponseWriter, r *http.Request, targetUserID int, isSelf bool) {
	profile, err := h.store.GetByUserID(targetUserID)
	if errors.Is(err, store.ErrNotFound) {
		notFound(w, r)
		return
	}
	if err != nil {
		internalServerError(w, r)
		return
	}
	raw, _, err := h.store.GetStatisticsRaw(targetUserID)
	if err != nil {
		internalServerError(w, r)
		return
	}
	doc := types.ParseStoredStatisticsPayload(raw)

	var isFollowing *bool
	if isSelf {
		f := false
		isFollowing = &f
	} else {
		authz := r.Header.Get("Authorization")
		if h.feeds != nil && authz != "" {
			ok, err := h.feeds.FetchIsFollowing(r.Context(), authz, targetUserID)
			if err == nil {
				isFollowing = &ok
			} else {
				f := false
				isFollowing = &f
			}
		} else {
			f := false
			isFollowing = &f
		}
	}

	resp := buildMainResponse(profile, doc, isFollowing)
	_ = json.NewEncoder(w).Encode(resp)
}

func buildMainResponse(profile *types.Profile, doc types.StoredStatisticsPayload, isFollowing *bool) types.ProfileMainResponse {
	weekdayTitles := []string{"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"}
	src := doc.WeeklyActivity
	def := types.DefaultStoredStatisticsPayload().WeeklyActivity
	if len(src) == 0 {
		src = def
	} else if len(src) < 7 {
		padded := make([]types.WeeklyActivityPoint, 7)
		copy(padded, src)
		for i := len(src); i < 7 && i < len(def); i++ {
			padded[i] = def[i]
		}
		src = padded
	}
	n := len(src)
	if n > 7 {
		n = 7
	}
	src = src[:n]
	maxV := 0
	for _, p := range src {
		if p.Value > maxV {
			maxV = p.Value
		}
	}
	if maxV == 0 {
		maxV = 1
	}
	weekly := make([]types.MainWeeklyActivity, 0, len(src))
	for i := range src {
		title := ""
		if i < len(weekdayTitles) {
			title = weekdayTitles[i]
		}
		weekly = append(weekly, types.MainWeeklyActivity{
			ID:       src[i].ID,
			DayTitle: title,
			Value:    src[i].Value,
			MaxValue: maxV,
		})
	}

	mostActive := doc.MostActiveWeekday
	if mostActive == "" {
		mostActive = doc.Summary.MostActiveDay
	}
	favType := doc.FavoriteWorkoutType

	return types.ProfileMainResponse{
		UserID:              profile.UserID,
		Name:                profile.Name,
		Username:            profile.Username,
		Status:              profile.Status,
		Subtitle:            profile.Subtitle,
		Bio:                 profile.Bio,
		AvatarSystemName:    profile.AvatarSystemName,
		Badge:               profile.Badge,
		IsFollowing:         isFollowing,
		WorkoutsThisMonth:   profile.WorkoutsThisMonth,
		TotalWorkouts:       doc.Summary.TotalWorkouts,
		TotalHours:          doc.Summary.TotalDurationHours,
		FavoriteWorkoutType: favType,
		MostActiveWeekday:   mostActive,
		ConsistencyPercent:  doc.Summary.Consistency,
		WeeklyActivity:      weekly,
	}
}

func (h *ProfileHandler) postInternalStatistics(w http.ResponseWriter, r *http.Request) {
	if h.internalSecret == "" {
		unauthorized(w, r)
		return
	}
	if r.Header.Get("X-Internal-Secret") != h.internalSecret {
		unauthorized(w, r)
		return
	}

	var req types.InternalUpsertStatisticsRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		badRequest(w, r)
		return
	}
	if req.UserID <= 0 || len(bytes.TrimSpace(req.Payload)) == 0 {
		badRequest(w, r)
		return
	}
	var check map[string]any
	if err := json.Unmarshal(req.Payload, &check); err != nil {
		badRequest(w, r)
		return
	}

	if err := h.store.UpsertStatisticsPayload(req.UserID, req.Payload); err != nil {
		internalServerError(w, r)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *ProfileHandler) GetProfileByID(w http.ResponseWriter, r *http.Request, userIDStr string) {
	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		badRequest(w, r)
		return
	}

	profile, err := h.store.GetByUserID(userID)
	if errors.Is(err, store.ErrNotFound) {
		notFound(w, r)
		return
	}
	if err != nil {
		internalServerError(w, r)
		return
	}

	_ = json.NewEncoder(w).Encode(profile)
}

func (h *ProfileHandler) GetProfilesBatch(w http.ResponseWriter, r *http.Request) {
	var req types.BatchProfilesRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		badRequest(w, r)
		return
	}

	if len(req.IDs) == 0 {
		_ = json.NewEncoder(w).Encode([]types.Profile{})
		return
	}

	profiles, err := h.store.ListByUserIDs(req.IDs)
	if err != nil {
		internalServerError(w, r)
		return
	}

	_ = json.NewEncoder(w).Encode(profiles)
}

func (h *ProfileHandler) ListProfiles(w http.ResponseWriter, r *http.Request) {
	profiles, err := h.store.ListAll()
	if err != nil {
		internalServerError(w, r)
		return
	}
	_ = json.NewEncoder(w).Encode(profiles)
}
