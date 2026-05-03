package clients

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

type WorkoutCompletedEventRequest struct {
	UserID          int64    `json:"user_id"`
	SessionID       string   `json:"session_id"`
	WorkoutID       string   `json:"workout_id"`
	WorkoutType     string   `json:"workout_type"`
	DurationMinutes int      `json:"duration_minutes"`
	Calories        int      `json:"calories"`
	ExerciseIDs     []string `json:"exercise_ids"`
	ExerciseTypes   []string `json:"exercise_types"`
	MuscleGroups     []string `json:"muscle_groups"`
	CompletedAt     string   `json:"completed_at"`
}

type ChallengesClient struct {
	baseURL        string
	internalSecret string
	client         *http.Client
}

func NewChallengesClient(baseURL string, internalSecret string) *ChallengesClient {
	return &ChallengesClient{
		baseURL:        baseURL,
		internalSecret: internalSecret,
		client:         http.DefaultClient,
	}
}

func (c *ChallengesClient) SendWorkoutCompleted(
	ctx context.Context,
	request WorkoutCompletedEventRequest,
) error {
	body, err := json.Marshal(request)
	if err != nil {
		return err
	}

	req, err := http.NewRequestWithContext(
		ctx,
		http.MethodPost,
		c.baseURL+"/internal/challenges/events/workout-completed",
		bytes.NewReader(body),
	)
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-Internal-Secret", c.internalSecret)

	resp, err := c.client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return fmt.Errorf("challenges service returned status %d", resp.StatusCode)
	}

	return nil
}

func NewWorkoutCompletedEvent(
	userID int64,
	sessionID string,
	workoutID string,
	workoutType string,
	durationMinutes int,
	calories int,
	exerciseIDs []string,
	exerciseTypes []string,
	muscleGroups []string,
	completedAt time.Time,
) WorkoutCompletedEventRequest {
	return WorkoutCompletedEventRequest{
		UserID:          userID,
		SessionID:       sessionID,
		WorkoutID:       workoutID,
		WorkoutType:     workoutType,
		DurationMinutes: durationMinutes,
		Calories:        calories,
		ExerciseIDs:     exerciseIDs,
		ExerciseTypes:   exerciseTypes,
		MuscleGroups:    muscleGroups,
		CompletedAt:     completedAt.Format(time.RFC3339),
	}
}