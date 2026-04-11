package store

import (
	"fmt"

	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
	"github.com/jmoiron/sqlx"
)

type FeedStore struct {
	db *sqlx.DB
}

func NewFeedStore(db *sqlx.DB) FeedStore {
	return FeedStore{db: db}
}

func (fs *FeedStore) ListFeedPostsForUser(userID int) ([]types.FeedPostRow, error) {
	query := `
		SELECT
			p.id,
			p.author_id,
			p.community_id,
			c.title AS community_title,
			p.workout_id,
			p.kind,
			p.description,
			p.location,
			p.created_at,
			COALESCE((SELECT COUNT(*) FROM post_reactions pr WHERE pr.post_id = p.id), 0) AS likes_count,
			COALESCE((SELECT COUNT(*) FROM post_comments pc WHERE pc.post_id = p.id), 0) AS comments_count,
			EXISTS(
				SELECT 1
				FROM post_reactions pr2
				WHERE pr2.post_id = p.id
				AND pr2.user_id = $1
			) AS is_liked,
			CASE
				WHEN p.community_id IS NOT NULL THEN true
				ELSE false
			END AS is_from_joined_community
		FROM posts p
		LEFT JOIN communities c ON c.id = p.community_id
		ORDER BY p.created_at DESC
		LIMIT 20
	`

	var rows []types.FeedPostRow
	err := fs.db.Select(&rows, query, userID)
	if err != nil {
		return nil, fmt.Errorf("ListFeedPostsForUser: %w", err)
	}

	return rows, nil
}
