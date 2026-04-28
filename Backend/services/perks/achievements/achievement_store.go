package achievements

import (
	"context"

	"github.com/jmoiron/sqlx"

	"github.com/alexandra-gritsaenko/gymbro-perks/store"
	"github.com/alexandra-gritsaenko/gymbro-perks/types"
)

type Store struct {
	db         *sqlx.DB
	perksBase *store.PerksStore
}

func NewStore(db *sqlx.DB, perksBase *store.PerksStore) *Store {
	return &Store{db: db, perksBase: perksBase}
}

func (s *Store) GetAchievements(ctx context.Context, userID int64) ([]types.AchievementResponse, error) {
	if err := s.perksBase.EnsureUser(ctx, userID); err != nil {
		return nil, err
	}

	var achievements []types.AchievementResponse

	err := s.db.SelectContext(ctx, &achievements, `
		SELECT
			d.id::TEXT AS id,
			d.code,
			d.name,
			d.description,
			d.icon_name,
			d.category,
			d.rarity,
			ua.status,
			ua.progress_current,
			ua.progress_target,
			ua.unlocked_at,
			FALSE AS is_secret
		FROM achievement_definitions d
		JOIN user_achievements ua
			ON ua.achievement_code = d.code
		WHERE ua.user_id = $1
		AND d.is_active = TRUE
		ORDER BY
			CASE ua.status WHEN 'unlocked' THEN 0 ELSE 1 END,
			ua.unlocked_at DESC NULLS LAST,
			d.id ASC
	`, userID)

	return achievements, err
}

func (s *Store) GetProgressMaps(
	ctx context.Context,
	userID int64,
) (map[string]int, map[string]int, error) {
	if err := s.perksBase.EnsureUser(ctx, userID); err != nil {
		return nil, nil, err
	}

	var rows []struct {
		Code            string `db:"achievement_code"`
		ProgressCurrent int    `db:"progress_current"`
		ProgressTarget  int    `db:"progress_target"`
	}

	err := s.db.SelectContext(ctx, &rows, `
		SELECT
			achievement_code,
			progress_current,
			progress_target
		FROM user_achievements
		WHERE user_id = $1
	`, userID)
	if err != nil {
		return nil, nil, err
	}

	current := make(map[string]int, len(rows))
	target := make(map[string]int, len(rows))

	for _, row := range rows {
		current[row.Code] = row.ProgressCurrent
		target[row.Code] = row.ProgressTarget
	}

	return current, target, nil
}

func (s *Store) ApplyProgressUpdates(
	ctx context.Context,
	userID int64,
	updates []AchievementProgressUpdate,
) error {
	if len(updates) == 0 {
		return nil
	}

	if err := s.perksBase.EnsureUser(ctx, userID); err != nil {
		return err
	}

	tx, err := s.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	for _, update := range updates {
		if update.Code == "" {
			continue
		}

		if update.Unlock {
			_, err = tx.ExecContext(ctx, `
				UPDATE user_achievements
				SET
					status = 'unlocked',
					progress_current = progress_target,
					unlocked_at = COALESCE(unlocked_at, NOW()),
					updated_at = NOW()
				WHERE user_id = $1
				  AND achievement_code = $2
				  AND status != 'unlocked'
			`, userID, update.Code)
		} else {
			_, err = tx.ExecContext(ctx, `
				UPDATE user_achievements
				SET
					progress_current = GREATEST(progress_current, $3),
					updated_at = NOW()
				WHERE user_id = $1
				  AND achievement_code = $2
				  AND status != 'unlocked'
			`, userID, update.Code, update.ProgressCurrent)
		}

		if err != nil {
			return err
		}
	}

	return tx.Commit()
}