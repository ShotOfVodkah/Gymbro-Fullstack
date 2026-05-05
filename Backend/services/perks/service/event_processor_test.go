package service

import (
	"context"
	"testing"

	"github.com/alexandra-gritsaenko/gymbro-perks/achievements"
	"github.com/alexandra-gritsaenko/gymbro-perks/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type mockStreakStore struct {
	called int
	err    error
}

func (m *mockStreakStore) ApplyWorkoutCompleted(ctx context.Context, userID int64) error {
	m.called++
	return m.err
}

type mockAchievementStore struct {
	getCalled     int
	applyCalled   int
	lastUpdates   []achievements.AchievementProgressUpdate
	getErr        error
	applyErr      error
	current       map[string]int
	target        map[string]int
}

func (m *mockAchievementStore) GetProgressMaps(ctx context.Context, userID int64) (map[string]int, map[string]int, error) {
	m.getCalled++
	if m.getErr != nil {
		return nil, nil, m.getErr
	}
	return m.current, m.target, nil
}

func (m *mockAchievementStore) ApplyProgressUpdates(ctx context.Context, userID int64, updates []achievements.AchievementProgressUpdate) error {
	m.applyCalled++
	m.lastUpdates = updates
	return m.applyErr
}

type mockUserStatsUpdater struct {
	called int
	err    error
}

func (m *mockUserStatsUpdater) IncrementCompletedWorkouts(ctx context.Context, userID int64) error {
	m.called++
	return m.err
}

func TestEventProcessor_WorkoutCompletedCallsStreakAndStatsAndUpdatesAchievements(t *testing.T) {
	streakMock := &mockStreakStore{}
	statsMock := &mockUserStatsUpdater{}
	achMock := &mockAchievementStore{
		current: map[string]int{},
		target:  map[string]int{"rookie": 1},
	}

	p := NewEventProcessor(streakMock, achMock, statsMock, achievements.NewAchievementEngine())
	err := p.Process(context.Background(), 7, types.PerksEventRequest{Type: "workout_completed", Metadata: nil})
	require.NoError(t, err)

	assert.Equal(t, 1, streakMock.called)
	assert.Equal(t, 1, statsMock.called)
	assert.Equal(t, 1, achMock.getCalled)
	assert.Equal(t, 1, achMock.applyCalled)
	assert.NotEmpty(t, achMock.lastUpdates)

	foundRookie := false
	for _, u := range achMock.lastUpdates {
		if u.Code == "rookie" {
			foundRookie = true
			break
		}
	}
	assert.True(t, foundRookie, "expected rookie update")
}

func TestEventProcessor_NonWorkoutEventDoesNotCallStreakOrStats(t *testing.T) {
	streakMock := &mockStreakStore{}
	statsMock := &mockUserStatsUpdater{}
	achMock := &mockAchievementStore{
		current: map[string]int{},
		target:  map[string]int{},
	}

	p := NewEventProcessor(streakMock, achMock, statsMock, achievements.NewAchievementEngine())
	err := p.Process(context.Background(), 7, types.PerksEventRequest{Type: "profile_opened"})
	require.NoError(t, err)

	assert.Equal(t, 0, streakMock.called)
	assert.Equal(t, 0, statsMock.called)
	assert.Equal(t, 1, achMock.applyCalled)
}

