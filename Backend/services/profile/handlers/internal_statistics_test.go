package handlers

import (
	"bytes"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/alexandra-gritsaenko/gymbro-profile/store"
	"github.com/alexandra-gritsaenko/gymbro-profile/types"
	"github.com/stretchr/testify/require"
)

type mockProfileStore struct {
	getByUserID             func(userID int) (*types.Profile, error)
	listByUserIDs           func(ids []int) ([]types.Profile, error)
	listAll                 func() ([]types.Profile, error)
	patchProfile            func(userID int, p types.PatchMeRequest) error
	getSettings             func(userID int) (*types.ProfileSettings, error)
	patchSettings           func(userID int, p types.PatchSettingsRequest) error
	getStatisticsRaw        func(userID int) ([]byte, bool, error)
	upsertStatisticsPayload func(userID int, payloadJSON []byte) error
}

func (m *mockProfileStore) GetByUserID(userID int) (*types.Profile, error) {
	if m.getByUserID != nil {
		return m.getByUserID(userID)
	}
	return nil, store.ErrNotFound
}

func (m *mockProfileStore) ListByUserIDs(ids []int) ([]types.Profile, error) {
	if m.listByUserIDs != nil {
		return m.listByUserIDs(ids)
	}
	return nil, nil
}

func (m *mockProfileStore) ListAll() ([]types.Profile, error) {
	if m.listAll != nil {
		return m.listAll()
	}
	return nil, nil
}

func (m *mockProfileStore) PatchProfile(userID int, p types.PatchMeRequest) error {
	if m.patchProfile != nil {
		return m.patchProfile(userID, p)
	}
	return nil
}

func (m *mockProfileStore) GetSettings(userID int) (*types.ProfileSettings, error) {
	if m.getSettings != nil {
		return m.getSettings(userID)
	}
	return nil, store.ErrNotFound
}

func (m *mockProfileStore) PatchSettings(userID int, p types.PatchSettingsRequest) error {
	if m.patchSettings != nil {
		return m.patchSettings(userID, p)
	}
	return nil
}

func (m *mockProfileStore) GetStatisticsRaw(userID int) ([]byte, bool, error) {
	if m.getStatisticsRaw != nil {
		return m.getStatisticsRaw(userID)
	}
	return nil, false, nil
}

func (m *mockProfileStore) UpsertStatisticsPayload(userID int, payloadJSON []byte) error {
	if m.upsertStatisticsPayload != nil {
		return m.upsertStatisticsPayload(userID, payloadJSON)
	}
	return nil
}

var _ store.ProfileStorer = (*mockProfileStore)(nil)

func TestServeHTTP_PostInternalStatistics_OK(t *testing.T) {
	var gotUserID int
	var gotPayload []byte
	st := &mockProfileStore{
		upsertStatisticsPayload: func(userID int, payloadJSON []byte) error {
			gotUserID = userID
			gotPayload = append([]byte(nil), payloadJSON...)
			return nil
		},
	}

	h := NewProfileHandler(st, []byte("jwt-secret"), nil, "internal-secret", nil)

	body := map[string]any{
		"user_id": 42,
		"payload": map[string]any{"summary": map[string]any{"total_workouts": 3}},
	}
	buf, err := json.Marshal(body)
	require.NoError(t, err)

	req := httptest.NewRequest(http.MethodPost, "/profiles/internal/statistics", bytes.NewReader(buf))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-Internal-Secret", "internal-secret")
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)

	require.Equal(t, http.StatusNoContent, rr.Code)
	require.Equal(t, 42, gotUserID)
	wantPayload, err := json.Marshal(map[string]any{"summary": map[string]any{"total_workouts": 3}})
	require.NoError(t, err)
	require.JSONEq(t, string(wantPayload), string(gotPayload))
}

func TestServeHTTP_PostInternalStatistics_WrongSecret(t *testing.T) {
	st := &mockProfileStore{
		upsertStatisticsPayload: func(int, []byte) error {
			t.Error("UpsertStatisticsPayload should not be called")
			return nil
		},
	}
	h := NewProfileHandler(st, []byte("jwt"), nil, "good", nil)

	req := httptest.NewRequest(http.MethodPost, "/profiles/internal/statistics", bytes.NewReader([]byte(`{"user_id":1,"payload":{}}`)))
	req.Header.Set("X-Internal-Secret", "bad")
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)

	require.Equal(t, http.StatusUnauthorized, rr.Code)
}

func TestServeHTTP_PostInternalStatistics_EmptySecretOnServer(t *testing.T) {
	st := &mockProfileStore{
		upsertStatisticsPayload: func(int, []byte) error {
			t.Error("UpsertStatisticsPayload should not be called")
			return nil
		},
	}
	h := NewProfileHandler(st, []byte("jwt"), nil, "", nil)

	req := httptest.NewRequest(http.MethodPost, "/profiles/internal/statistics", bytes.NewReader([]byte(`{"user_id":1,"payload":{}}`)))
	req.Header.Set("X-Internal-Secret", "anything")
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)

	require.Equal(t, http.StatusUnauthorized, rr.Code)
}

func TestServeHTTP_PostInternalStatistics_StoreError(t *testing.T) {
	st := &mockProfileStore{
		upsertStatisticsPayload: func(int, []byte) error {
			return errors.New("db unavailable")
		},
	}
	h := NewProfileHandler(st, []byte("jwt"), nil, "internal-secret", nil)

	req := httptest.NewRequest(http.MethodPost, "/profiles/internal/statistics", bytes.NewReader([]byte(`{"user_id":1,"payload":{"a":1}}`)))
	req.Header.Set("X-Internal-Secret", "internal-secret")
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)

	require.Equal(t, http.StatusInternalServerError, rr.Code)
}
