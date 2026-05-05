package handlers

import (
	"context"
	"encoding/json"
	"net/http"
	"slices"
	"strconv"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexandra-gritsaenko/gymbro-feeds/clients"
	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

type CalendarHandler struct {
	calendarStore   CalendarStore
	profileClient   ProfileClient
	workoutsClient  WorkoutsCalendarClient
}

type CalendarStore interface {
	ListCommunityMemberIDs(communityID string) ([]int, error)
}

type ProfileClient interface {
	FetchProfilesBatch(ctx context.Context, ids []int) (map[int]clients.ProfilePreview, error)
}

type WorkoutsCalendarClient interface {
	FetchUserCalendarMonth(ctx context.Context, userID string, month string) ([]types.CalendarWorkoutDayResponse, error)
}

func NewCalendarHandler(
	calendarStore CalendarStore,
	profileClient ProfileClient,
	workoutsClient WorkoutsCalendarClient,
) *CalendarHandler {
	return &CalendarHandler{
		calendarStore:  calendarStore,
		profileClient:  profileClient,
		workoutsClient: workoutsClient,
	}
}

func (h *CalendarHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch {
	case r.Method == http.MethodGet && r.URL.Path == "/calendar/people":
		h.GetCalendarPeople(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/calendar/month":
		h.GetCalendarMonth(w, r)
		return
	default:
		http.NotFound(w, r)
	}
}

func (h *CalendarHandler) GetCalendarPeople(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	contextType := r.URL.Query().Get("context")
	personID := r.URL.Query().Get("person_id")
	chatID := r.URL.Query().Get("chat_id")
	groupID := r.URL.Query().Get("group_id")

	var userIDs []int

	switch contextType {
	case "mine":
		userIDs = []int{claims.UserID}

	case "person":
		id, err := strconv.Atoi(personID)
		if err != nil {
			http.Error(w, "invalid person_id", http.StatusBadRequest)
			return
		}
		userIDs = []int{id}

	case "direct_chat":
		if chatID == "" {
			http.Error(w, "chat_id is required", http.StatusBadRequest)
			return
		}
		ids, err := h.calendarStore.ListCommunityMemberIDs(chatID)
		if err != nil {
			http.Error(w, "failed to load chat members", http.StatusInternalServerError)
			return
		}
		userIDs = ids

	case "group_chat":
		if groupID == "" {
			http.Error(w, "group_id is required", http.StatusBadRequest)
			return
		}
		ids, err := h.calendarStore.ListCommunityMemberIDs(groupID)
		if err != nil {
			http.Error(w, "failed to load group members", http.StatusInternalServerError)
			return
		}
		userIDs = ids

	default:
		http.Error(w, "invalid context", http.StatusBadRequest)
		return
	}

	if len(userIDs) == 0 {
		_ = json.NewEncoder(w).Encode([]types.CalendarPersonResponse{})
		return
	}

	profilesMap, err := h.profileClient.FetchProfilesBatch(r.Context(), userIDs)
	if err != nil {
		http.Error(w, "failed to load profiles", http.StatusInternalServerError)
		return
	}

	resp := make([]types.CalendarPersonResponse, 0, len(userIDs))
	for _, id := range userIDs {
		profile, ok := profilesMap[id]
		if !ok {
			continue
		}
		resp = append(resp, types.CalendarPersonResponse{
			ID:               strconv.Itoa(profile.UserID),
			Name:             profile.Name,
			AvatarSystemName: profile.AvatarSystemName,
		})
	}

	slices.SortFunc(resp, func(a, b types.CalendarPersonResponse) int {
		if a.ID == strconv.Itoa(claims.UserID) {
			return -1
		}
		if b.ID == strconv.Itoa(claims.UserID) {
			return 1
		}
		if a.Name < b.Name {
			return -1
		}
		if a.Name > b.Name {
			return 1
		}
		return 0
	})

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
}

func (h *CalendarHandler) GetCalendarMonth(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	contextType := r.URL.Query().Get("context")
	month := r.URL.Query().Get("month")
	selectedPersonID := r.URL.Query().Get("selected_person_id")
	personID := r.URL.Query().Get("person_id")

	if month == "" {
		http.Error(w, "month is required", http.StatusBadRequest)
		return
	}

	myWorkouts := []types.CalendarWorkoutDayResponse{}
	partnerWorkouts := []types.CalendarWorkoutDayResponse{}

	switch contextType {
	case "mine":
		items, err := h.workoutsClient.FetchUserCalendarMonth(r.Context(), strconv.Itoa(claims.UserID), month)
		if err != nil {
			http.Error(w, "failed to load my workouts", http.StatusInternalServerError)
			return
		}
		myWorkouts = items

	case "person":
		if personID == "" {
			http.Error(w, "person_id is required", http.StatusBadRequest)
			return
		}
		items, err := h.workoutsClient.FetchUserCalendarMonth(r.Context(), personID, month)
		if err != nil {
			http.Error(w, "failed to load person workouts", http.StatusInternalServerError)
			return
		}
		partnerWorkouts = items

	case "direct_chat", "group_chat":
		items, err := h.workoutsClient.FetchUserCalendarMonth(r.Context(), strconv.Itoa(claims.UserID), month)
		if err != nil {
			http.Error(w, "failed to load my workouts", http.StatusInternalServerError)
			return
		}
		myWorkouts = items

		if selectedPersonID != "" && selectedPersonID != strconv.Itoa(claims.UserID) {
			partnerItems, err := h.workoutsClient.FetchUserCalendarMonth(r.Context(), selectedPersonID, month)
			if err != nil {
				http.Error(w, "failed to load partner workouts", http.StatusInternalServerError)
				return
			}
			partnerWorkouts = partnerItems
		}

	default:
		http.Error(w, "invalid context", http.StatusBadRequest)
		return
	}

	if myWorkouts == nil {
    	myWorkouts = []types.CalendarWorkoutDayResponse{}
	}
	if partnerWorkouts == nil {
		partnerWorkouts = []types.CalendarWorkoutDayResponse{}
	}

	resp := types.CalendarMonthResponse{
		Month:           month,
		MyWorkouts:      myWorkouts,
		PartnerWorkouts: partnerWorkouts,
	}

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
}