package store

import (
	"fmt"

	"github.com/jmoiron/sqlx"
)

type CalendarStore struct {
	db *sqlx.DB
}

func NewCalendarStore(db *sqlx.DB) CalendarStore {
	return CalendarStore{db: db}
}

func (cs *CalendarStore) ListCommunityMemberIDs(communityID string) ([]int, error) {
	query := `
		SELECT user_id
		FROM community_members
		WHERE community_id = $1
		ORDER BY created_at
	`

	var ids []int
	if err := cs.db.Select(&ids, query, communityID); err != nil {
		return nil, fmt.Errorf("ListCommunityMemberIDs: %w", err)
	}

	return ids, nil
}