package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-workouts/stats"
	"github.com/jmoiron/sqlx"
)

type InternalTemporalHandler struct {
	db             *sqlx.DB
	internalSecret string
}

func NewInternalTemporalHandler(db *sqlx.DB, internalSecret string) *InternalTemporalHandler {
	return &InternalTemporalHandler{db: db, internalSecret: internalSecret}
}

type temporalResponse struct {
	Summary struct {
		WorkoutsThisWeek  int `json:"workouts_this_week"`
		WorkoutsThisMonth int `json:"workouts_this_month"`
		Consistency       int `json:"consistency"`
	} `json:"summary"`
	MonthlyTrend     []stats.WeeklyPoint `json:"monthly_trend"`
	WorkoutsByMonth  []stats.MonthPoint  `json:"workouts_by_month"`
	ServerTimeRFC3339 string            `json:"server_time_rfc3339"`
}

func (h *InternalTemporalHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if h.internalSecret == "" || h.internalSecret != r.Header.Get("X-Internal-Secret") {
		http.Error(w, `{"error":"unauthorized"}`, http.StatusUnauthorized)
		return
	}
	if r.Method != http.MethodGet {
		http.Error(w, `{"error":"method not allowed"}`, http.StatusMethodNotAllowed)
		return
	}
	uid := r.URL.Query().Get("user_id")
	if uid == "" {
		http.Error(w, `{"error":"user_id required"}`, http.StatusBadRequest)
		return
	}
	now := nowFromHeaderOrDefault(r)
	b := stats.NewBuilder(h.db)
	tb, err := b.BuildTemporalBlock(uid, now)
	if err != nil {
		log.Println("BuildTemporalBlock:", err)
		http.Error(w, `{"error":"internal error"}`, http.StatusInternalServerError)
		return
	}
	var out temporalResponse
	out.Summary.WorkoutsThisWeek = tb.ThisWeek
	out.Summary.WorkoutsThisMonth = tb.ThisMonth
	out.Summary.Consistency = tb.Consistency
	out.MonthlyTrend = tb.MonthlyTrend
	out.WorkoutsByMonth = tb.WorkoutsByMonth
	out.ServerTimeRFC3339 = now.UTC().Format(time.RFC3339)

	w.Header().Set("content-type", "application/json")
	_ = json.NewEncoder(w).Encode(out)
}

func nowFromHeaderOrDefault(r *http.Request) time.Time {
	if s := r.Header.Get("X-Reference-Time"); s != "" {
		if t, err := time.Parse(time.RFC3339, s); err == nil {
			return t
		}
	}
	return time.Now()
}
