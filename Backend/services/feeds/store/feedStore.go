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
			p.session_id,
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

func (fs *FeedStore) ListCommunitiesForUser(userID int) ([]types.FeedCommunityRow, error) {
	query := `
		SELECT
			c.id,
			c.title,
			c.kind,
			COUNT(cm2.id) AS members_count
		FROM communities c
		JOIN community_members cm
			ON cm.community_id = c.id
		LEFT JOIN community_members cm2
			ON cm2.community_id = c.id
		WHERE cm.user_id = $1
		GROUP BY c.id, c.title, c.kind
		ORDER BY c.title
	`

	var rows []types.FeedCommunityRow
	err := fs.db.Select(&rows, query, userID)
	if err != nil {
		return nil, fmt.Errorf("ListCommunitiesForUser: %w", err)
	}

	return rows, nil
}