package store

import (
	"database/sql"
	"errors"
	"fmt"

	"github.com/alexandra-gritsaenko/gymbro-profile/types"
	"github.com/jmoiron/sqlx"
	"github.com/lib/pq"
)

var ErrNotFound = errors.New("not found")

type ProfileStore struct {
	db *sqlx.DB
}

func NewProfileStore(db *sqlx.DB) ProfileStore {
	return ProfileStore{db: db}
}

const profileSelectCols = `user_id, name, username, status, subtitle, bio, avatar_system_name, badge, workouts_this_month`

func (ps *ProfileStore) GetByUserID(userID int) (*types.Profile, error) {
	var profile types.Profile
	err := ps.db.Get(&profile, `
		SELECT `+profileSelectCols+`
		FROM profiles
		WHERE user_id = $1
	`, userID)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("GetByUserID: %w", err)
	}
	return &profile, nil
}

func (ps *ProfileStore) ListByUserIDs(ids []int) ([]types.Profile, error) {
	query, args, err := sqlx.In(`
		SELECT `+profileSelectCols+`
		FROM profiles
		WHERE user_id IN (?)
		ORDER BY user_id
	`, ids)
	if err != nil {
		return nil, fmt.Errorf("ListByUserIDs build query: %w", err)
	}
	query = ps.db.Rebind(query)

	var profiles []types.Profile
	if err := ps.db.Select(&profiles, query, args...); err != nil {
		return nil, fmt.Errorf("ListByUserIDs: %w", err)
	}
	return profiles, nil
}

func (ps *ProfileStore) ListAll() ([]types.Profile, error) {
	var profiles []types.Profile
	err := ps.db.Select(&profiles, `
		SELECT `+profileSelectCols+`
		FROM profiles
		ORDER BY user_id
	`)
	if err != nil {
		return nil, fmt.Errorf("ListAll: %w", err)
	}
	return profiles, nil
}

func (ps *ProfileStore) PatchProfile(userID int, p types.PatchMeRequest) error {
	row := ps.db.QueryRowx(`
		SELECT name, username, status, subtitle, bio, avatar_system_name
		FROM profiles WHERE user_id = $1
	`, userID)
	var cur struct {
		Name             string `db:"name"`
		Username         string `db:"username"`
		Status           string `db:"status"`
		Subtitle         string `db:"subtitle"`
		Bio              string `db:"bio"`
		AvatarSystemName string `db:"avatar_system_name"`
	}
	if err := row.StructScan(&cur); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return ErrNotFound
		}
		return fmt.Errorf("PatchProfile load: %w", err)
	}

	name := cur.Name
	if p.Name != nil {
		name = *p.Name
	}
	username := cur.Username
	if p.Username != nil {
		username = *p.Username
	}
	status := cur.Status
	if p.Status != nil {
		status = *p.Status
	}
	subtitle := cur.Subtitle
	if p.Subtitle != nil {
		subtitle = *p.Subtitle
	}
	bio := cur.Bio
	if p.Bio != nil {
		bio = *p.Bio
	}
	avatar := cur.AvatarSystemName
	if p.AvatarSystemName != nil {
		avatar = *p.AvatarSystemName
	}

	_, err := ps.db.Exec(`
		UPDATE profiles SET
			name = $1,
			username = $2,
			status = $3,
			subtitle = $4,
			bio = $5,
			avatar_system_name = $6,
			updated_at = NOW()
		WHERE user_id = $7
	`, name, username, status, subtitle, bio, avatar, userID)
	if err != nil {
		var pqErr *pq.Error
		if errors.As(err, &pqErr) && pqErr.Code == "23505" {
			return ErrUsernameTaken
		}
		return fmt.Errorf("PatchProfile: %w", err)
	}
	return nil
}

var ErrUsernameTaken = errors.New("username taken")

func (ps *ProfileStore) GetSettings(userID int) (*types.ProfileSettings, error) {
	var s types.ProfileSettings
	err := ps.db.Get(&s, `
		SELECT user_id, push_notifications_enabled, workout_reminders, private_account,
		       show_activity, discover_visibility
		FROM profile_settings
		WHERE user_id = $1
	`, userID)
	if errors.Is(err, sql.ErrNoRows) {
		if err := ps.ensureSettingsRow(userID); err != nil {
			return nil, err
		}
		return ps.GetSettings(userID)
	}
	if err != nil {
		return nil, fmt.Errorf("GetSettings: %w", err)
	}
	return &s, nil
}

func (ps *ProfileStore) ensureSettingsRow(userID int) error {
	_, err := ps.db.Exec(`
		INSERT INTO profile_settings (user_id)
		VALUES ($1)
		ON CONFLICT (user_id) DO NOTHING
	`, userID)
	return err
}

func (ps *ProfileStore) PatchSettings(userID int, p types.PatchSettingsRequest) error {
	cur, err := ps.GetSettings(userID)
	if err != nil {
		return err
	}
	push := cur.PushNotificationsEnabled
	if p.PushNotificationsEnabled != nil {
		push = *p.PushNotificationsEnabled
	}
	rem := cur.WorkoutReminders
	if p.WorkoutReminders != nil {
		rem = *p.WorkoutReminders
	}
	priv := cur.PrivateAccount
	if p.PrivateAccount != nil {
		priv = *p.PrivateAccount
	}
	show := cur.ShowActivity
	if p.ShowActivity != nil {
		show = *p.ShowActivity
	}
	disc := cur.DiscoverVisibility
	if p.DiscoverVisibility != nil {
		disc = *p.DiscoverVisibility
	}

	_, err = ps.db.Exec(`
		UPDATE profile_settings SET
			push_notifications_enabled = $1,
			workout_reminders = $2,
			private_account = $3,
			show_activity = $4,
			discover_visibility = $5,
			updated_at = NOW()
		WHERE user_id = $6
	`, push, rem, priv, show, disc, userID)
	if err != nil {
		return fmt.Errorf("PatchSettings: %w", err)
	}
	return nil
}

func (ps *ProfileStore) GetStatisticsRaw(userID int) ([]byte, bool, error) {
	var raw []byte
	err := ps.db.Get(&raw, `SELECT payload FROM profile_statistics WHERE user_id = $1`, userID)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, false, nil
	}
	if err != nil {
		return nil, false, fmt.Errorf("GetStatisticsRaw: %w", err)
	}
	return raw, true, nil
}

func (ps *ProfileStore) UpsertStatisticsPayload(userID int, payloadJSON []byte) error {
	_, err := ps.db.Exec(`
		INSERT INTO profile_statistics (user_id, payload, updated_at)
		VALUES ($1, $2::jsonb, NOW())
		ON CONFLICT (user_id) DO UPDATE SET
			payload = EXCLUDED.payload,
			updated_at = NOW()
	`, userID, payloadJSON)
	if err != nil {
		return fmt.Errorf("UpsertStatisticsPayload: %w", err)
	}
	return nil
}
