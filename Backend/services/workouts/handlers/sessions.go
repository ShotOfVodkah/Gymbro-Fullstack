package handlers

import (
	"context"
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"regexp"
	"strconv"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-workouts/clients"
	"github.com/alexandra-gritsaenko/gymbro-workouts/stats"
	"github.com/alexandra-gritsaenko/gymbro-workouts/store"
	"github.com/alexandra-gritsaenko/gymbro-workouts/types"
	"github.com/jmoiron/sqlx"
	"github.com/lib/pq"
)

var reSessionByID = regexp.MustCompile(`^/sessions/([^/]+)$`)

type sessionHandler struct {
	sessionStore  store.SessionStorer
	workoutStore  store.WorkoutStorer
	statsBuilder  *stats.Builder
	profileStats  *clients.ProfileStatsClient
	challengesClient *clients.ChallengesClient
}

func NewSessionHandler(db *sqlx.DB, profileStats *clients.ProfileStatsClient, challengesClient *clients.ChallengesClient,) *sessionHandler {
	return &sessionHandler{
		sessionStore: store.NewSessionStore(db),
		workoutStore: store.NewWorkoutStore(db),
		statsBuilder: stats.NewBuilder(db),
		profileStats: profileStats,
		challengesClient: challengesClient,
	}
}

func (h *sessionHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")

	if r.URL.Path == "/sessions/preview/batch" {
		if r.Method == http.MethodPost {
			h.GetSessionPreviewBatch(w, r)
		} else {
			notFound(w, r)
		}
		return
	}

	if r.URL.Path == "/sessions/save-as-workout" || r.URL.Path == "/sessions/save-as-workout/" {
		if r.Method == http.MethodPost {
			h.SaveSessionAsWorkout(w, r)
		} else {
			notFound(w, r)
		}
		return
	}

	if r.URL.Path == "/sessions/calendar" {
		if r.Method == http.MethodGet {
			h.GetCalendarSessions(w, r)
		} else {
			notFound(w, r)
		}
		return
	}

	if m := reSessionByID.FindStringSubmatch(r.URL.Path); m != nil {
		if r.Method == http.MethodGet {
			h.GetSessionByID(w, r, m[1])
			return
		}
		notFound(w, r)
		return
	}

	if r.URL.Path == "/sessions" || r.URL.Path == "/sessions/" {
		switch r.Method {
		case http.MethodGet:
			h.ListSessionsByUser(w, r)
		case http.MethodPost:
			h.CreateSession(w, r)
		default:
			notFound(w, r)
		}
		return
	}

	notFound(w, r)
}

func (h *sessionHandler) GetSessionPreviewBatch(w http.ResponseWriter, r *http.Request) {
	var req types.SessionPreviewBatchRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		badRequest(w, r)
		return
	}

	if len(req.IDs) == 0 {
		json.NewEncoder(w).Encode(types.SessionPreviewBatchResponse{
			Items: []types.SessionPreviewItem{},
		})
		return
	}

	items, err := h.sessionStore.GetSessionPreviewsByIDs(req.IDs, requestLocale(r))
	if err != nil {
		internalServerError(w, r)
		return
	}

	json.NewEncoder(w).Encode(types.SessionPreviewBatchResponse{
		Items: items,
	})
}

func (h *sessionHandler) GetCalendarSessions(w http.ResponseWriter, r *http.Request) {
	userID := r.URL.Query().Get("user_id")
	month := r.URL.Query().Get("month")

	if userID == "" || month == "" {
		badRequest(w, r)
		return
	}

	items, err := h.sessionStore.ListCalendarSessionsByUserAndMonth(userID, month)
	if err != nil {
		log.Println("GetCalendarSessions error:", err)
		internalServerError(w, r)
		return
	}

	json.NewEncoder(w).Encode(items)
}

func (h *sessionHandler) GetSessionByID(w http.ResponseWriter, r *http.Request, id string) {
	if _, ok := userIDFromContext(r); !ok {
		unauthorized(w, r)
		return
	}

	session, err := h.sessionStore.GetSessionByID(id, requestLocale(r))
	if errors.Is(err, store.ErrNotFound) {
		notFound(w, r)
		return
	}
	if err != nil {
		internalServerError(w, r)
		return
	}
	json.NewEncoder(w).Encode(session)
}

func (h *sessionHandler) ListSessionsByUser(w http.ResponseWriter, r *http.Request) {
	userID, ok := userIDFromContext(r)
	if !ok {
		unauthorized(w, r)
		return
	}

	var from, to *time.Time
	if s := r.URL.Query().Get("from"); s != "" {
		t, err := time.Parse(time.RFC3339, s)
		if err != nil {
			badRequest(w, r)
			return
		}
		from = &t
	}
	if s := r.URL.Query().Get("to"); s != "" {
		t, err := time.Parse(time.RFC3339, s)
		if err != nil {
			badRequest(w, r)
			return
		}
		to = &t
	}

	sessions, err := h.sessionStore.ListSessionsByUserID(userID, from, to, requestLocale(r))
	if err != nil {
		internalServerError(w, r)
		return
	}
	json.NewEncoder(w).Encode(sessions)
}

func (h *sessionHandler) CreateSession(w http.ResponseWriter, r *http.Request) {
	userID, ok := userIDFromContext(r)
	if !ok {
		unauthorized(w, r)
		return
	}

	var input types.SessionInput
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		badRequest(w, r)
		return
	}
	if input.ID == "" || input.WorkoutID == "" {
		badRequest(w, r)
		return
	}
	input.UserID = userID

	workout, err := h.workoutStore.GetWorkoutByID(input.WorkoutID, types.LocaleEN)
	if errors.Is(err, store.ErrNotFound) {
		notFound(w, r)
		return
	}
	if err != nil {
		internalServerError(w, r)
		return
	}
	if workout.UserID != userID {
		unauthorized(w, r)
		return
	}

	if err := h.sessionStore.InsertSession(&input); err != nil {
		internalServerError(w, r)
		return
	}

	h.pushProfileStats(r.Context(), userID)
	h.pushChallengeProgress(r.Context(), userID, input)

	session, err := h.sessionStore.GetSessionByID(input.ID, requestLocale(r))
	if err != nil {
		internalServerError(w, r)
		return
	}

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(session)
}

func (h *sessionHandler) pushProfileStats(ctx context.Context, userID string) {
	if h.statsBuilder == nil {
		return
	}
	uid, err := strconv.Atoi(userID)
	if err != nil {
		log.Printf("profile stats: skip non-numeric user_id %q", userID)
		return
	}
	payload, err := h.statsBuilder.BuildPayloadJSON(userID, time.Now())
	if err != nil {
		log.Printf("profile stats build: %v", err)
		return
	}
	if h.profileStats == nil {
		return
	}
	if err := h.profileStats.UpsertStatistics(ctx, uid, payload); err != nil {
		log.Printf("profile stats upsert: %v", err)
	}
}

func (h *sessionHandler) pushChallengeProgress(
	ctx context.Context,
	userID string,
	input types.SessionInput,
) {
	if h.challengesClient == nil {
		return
	}

	uid, err := strconv.ParseInt(userID, 10, 64)
	if err != nil {
		log.Printf("challenges event: skip non-numeric user_id %q", userID)
		return
	}

	session, err := h.sessionStore.GetSessionByID(input.ID, types.LocaleEN)
	if err != nil {
		log.Printf("challenges event: failed to load session %s: %v", input.ID, err)
		return
	}

	durationMinutes := 0
	exerciseIDs := make([]string, 0, len(session.Exercises))
	exerciseTypes := make([]string, 0, len(session.Exercises))
	muscleGroups := make([]string, 0, len(session.Exercises))

	for _, exercise := range session.Exercises {
		exerciseIDs = append(exerciseIDs, exercise.ID)
		exerciseTypes = append(exerciseTypes, exercise.Type)
		muscleGroups = append(muscleGroups, exercise.MuscleGroup)

		if exercise.DurationMinutes != nil {
			durationMinutes += *exercise.DurationMinutes
		}
	}

	workoutID := ""
	if session.WorkoutID != nil {
		workoutID = *session.WorkoutID
	}

	event := clients.NewWorkoutCompletedEvent(
		uid,
		session.ID,
		workoutID,
		session.WorkoutType,
		durationMinutes,
		0,
		exerciseIDs,
		exerciseTypes,
		muscleGroups,
		session.CompletedAt,
	)

	if err := h.challengesClient.SendWorkoutCompleted(ctx, event); err != nil {
		log.Printf("challenges event failed: %v", err)
	}
}

func (h *sessionHandler) SaveSessionAsWorkout(w http.ResponseWriter, r *http.Request) {
	userID, ok := userIDFromContext(r)
	if !ok {
		unauthorized(w, r)
		return
	}

	var req types.SaveSessionAsWorkoutRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		badRequest(w, r)
		return
	}
	if req.SessionID == "" {
		badRequest(w, r)
		return
	}

	session, err := h.sessionStore.GetSessionByID(req.SessionID, types.LocaleEN)
	if errors.Is(err, store.ErrNotFound) {
		notFound(w, r)
		return
	}
	if err != nil {
		internalServerError(w, r)
		return
	}

	wt, ok := parseSessionWorkoutType(session.WorkoutType)
	if !ok {
		badRequest(w, r)
		return
	}

	exerciseIDs := make([]string, 0, len(session.Exercises))
	for _, ex := range session.Exercises {
		exerciseIDs = append(exerciseIDs, ex.ID)
	}
	if err := h.sessionStore.EnsureExercisesFromSessionDictionary(exerciseIDs); err != nil {
		if errors.Is(err, store.ErrInvalidExerciseDictionary) {
			badRequest(w, r)
			return
		}
		internalServerError(w, r)
		return
	}

	exercises := make([]types.WorkoutExerciseInput, len(session.Exercises))
	for i, ex := range session.Exercises {
		exercises[i] = types.WorkoutExerciseInput{
			ExerciseID:      ex.ID,
			Sets:            ex.Sets,
			Reps:            ex.Reps,
			WeightKg:        ex.WeightKg,
			DurationMinutes: ex.DurationMinutes,
			Pace:            ex.Pace,
			HoldSeconds:     ex.HoldSeconds,
			BreathCount:     ex.BreathCount,
		}
	}

	newWorkoutID := req.WorkoutID
	if newWorkoutID == "" {
		newWorkoutID = newID()
	} else {
		if _, err := h.workoutStore.GetWorkoutByID(newWorkoutID, types.LocaleEN); err == nil {
			conflict(w, r)
			return
		} else if !errors.Is(err, store.ErrNotFound) {
			internalServerError(w, r)
			return
		}
	}

	name := session.WorkoutName
	if req.Name != "" {
		name = req.Name
	}

	input := types.WorkoutInput{
		ID:        newWorkoutID,
		UserID:    userID,
		Name:      name,
		Type:      wt,
		Exercises: exercises,
	}

	if err := h.workoutStore.InsertWorkout(&input); err != nil {
		var pqErr *pq.Error
		if errors.As(err, &pqErr) && pqErr.Code == "23505" {
			conflict(w, r)
			return
		}
		internalServerError(w, r)
		return
	}

	workout, err := h.workoutStore.GetWorkoutByID(newWorkoutID, requestLocale(r))
	if err != nil {
		internalServerError(w, r)
		return
	}

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(workout)
}

func parseSessionWorkoutType(s string) (types.WorkoutType, bool) {
	t := types.WorkoutType(s)
	switch t {
	case types.WorkoutTypeStrength, types.WorkoutTypeCardio, types.WorkoutTypeYoga:
		return t, true
	default:
		return "", false
	}
}
