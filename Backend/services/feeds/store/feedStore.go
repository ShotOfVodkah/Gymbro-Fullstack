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

func (fs *FeedStore) ListFeedPostsForUserPaginated(
	userID int,
	limit int,
	cursor *string,
	scope types.FeedScope,
) ([]types.FeedPostRow, error) {
	query := `
		WITH feed_rows AS (
			SELECT
				p.id,
				p.author_id::text AS author_id,
				p.community_id,
				c.title AS community_title,
				p.session_id,
				p.kind,
				p.description,
				p.location,
				p.created_at,

				COALESCE((
					SELECT COUNT(*)
					FROM post_reactions pr
					WHERE pr.post_id = p.id
				), 0) AS likes_count,

				COALESCE((
					SELECT COUNT(*)
					FROM post_comments pc
					WHERE pc.post_id = p.id
				), 0) AS comments_count,

				EXISTS(
					SELECT 1
					FROM post_reactions pr2
					WHERE pr2.post_id = p.id
					  AND pr2.user_id = $1
				) AS is_liked,

				EXISTS(
					SELECT 1
					FROM user_follows uf
					WHERE uf.follower_id = $1
					  AND uf.followee_id = p.author_id
				) AS is_from_following,

				EXISTS(
					SELECT 1
					FROM communities dc
					JOIN community_members me
						ON me.community_id = dc.id
					   AND me.user_id = $1
					JOIN community_members other_member
						ON other_member.community_id = dc.id
					   AND other_member.user_id = p.author_id
					WHERE dc.kind = 'direct'
				) AS is_from_direct_chat,

				EXISTS(
					SELECT 1
					FROM communities gc
					JOIN community_members me2
						ON me2.community_id = gc.id
					   AND me2.user_id = $1
					WHERE gc.id = p.community_id
					  AND gc.kind = 'joined_group'
				) AS is_from_group_community

			FROM posts p
			LEFT JOIN communities c ON c.id = p.community_id
			WHERE ($2::timestamptz IS NULL OR p.created_at < $2::timestamptz)
		)
		SELECT *
		FROM feed_rows
		WHERE
			$4 = 'all'
			OR ($4 = 'friends' AND is_from_following = true)
			OR ($4 = 'direct' AND is_from_direct_chat = true)
			OR ($4 = 'groups' AND is_from_group_community = true)
			OR ($4 = 'mine' AND author_id = $1::text)
		ORDER BY created_at DESC
		LIMIT $3
	`

	var rows []types.FeedPostRow
	if err := fs.db.Select(&rows, query, userID, cursor, limit, string(scope)); err != nil {
		return nil, fmt.Errorf("ListFeedPostsForUserPaginated: %w", err)
	}

	return rows, nil
}

func (fs *FeedStore) ListCommunitiesForUser(userID int) ([]types.FeedCommunityRow, error) {
	query := `
		SELECT
			c.id,
			c.title,
			c.kind,
			COUNT(cm2.id) AS members_count,
			CASE
				WHEN c.kind = 'direct' THEN (
					SELECT cm_other.user_id
					FROM community_members cm_other
					WHERE cm_other.community_id = c.id
					  AND cm_other.user_id <> $1
					LIMIT 1
				)
				ELSE NULL
			END AS other_user_id
		FROM communities c
		JOIN community_members cm
			ON cm.community_id = c.id
		   AND cm.user_id = $1
		LEFT JOIN community_members cm2
			ON cm2.community_id = c.id
		GROUP BY c.id, c.title, c.kind
		ORDER BY COALESCE(c.updated_at, c.created_at) DESC
	`

	var rows []types.FeedCommunityRow
	if err := fs.db.Select(&rows, query, userID); err != nil {
		return nil, fmt.Errorf("ListCommunitiesForUser: %w", err)
	}

	return rows, nil
}

func (fs *FeedStore) PostExists(postID string) (bool, error) {
	var exists bool
	query := `
		SELECT EXISTS(
			SELECT 1
			FROM posts
			WHERE id = $1
		)
	`

	if err := fs.db.Get(&exists, query, postID); err != nil {
		return false, fmt.Errorf("PostExists: %w", err)
	}

	return exists, nil
}

func (fs *FeedStore) ListCommentsByPostID(postID string) ([]types.FeedCommentRow, error) {
	query := `
		SELECT
			id,
			post_id,
			author_id,
			content,
			created_at
		FROM post_comments
		WHERE post_id = $1
		ORDER BY created_at ASC
	`

	var rows []types.FeedCommentRow
	if err := fs.db.Select(&rows, query, postID); err != nil {
		return nil, fmt.Errorf("ListCommentsByPostID: %w", err)
	}

	return rows, nil
}

func (fs *FeedStore) InsertComment(postID string, authorID int, content string) (*types.FeedCommentRow, error) {
	query := `
		INSERT INTO post_comments (
			id,
			post_id,
			author_id,
			content,
			created_at
		)
		VALUES (
			gen_random_uuid(),
			$1,
			$2,
			$3,
			NOW()
		)
		RETURNING id, post_id, author_id, content, created_at
	`

	var row types.FeedCommentRow
	if err := fs.db.Get(&row, query, postID, authorID, content); err != nil {
		return nil, fmt.Errorf("InsertComment: %w", err)
	}

	return &row, nil
}

func (fs *FeedStore) LikePost(postID string, userID int) error {
	query := `
		INSERT INTO post_reactions (id, post_id, user_id, reaction_type, created_at)
		VALUES (gen_random_uuid(), $1::uuid, $2, 'like', NOW())
		ON CONFLICT (post_id, user_id) DO NOTHING
	`

	if _, err := fs.db.Exec(query, postID, userID); err != nil {
		return fmt.Errorf("LikePost: %w", err)
	}

	return nil
}

func (fs *FeedStore) UnlikePost(postID string, userID int) error {
	query := `
		DELETE FROM post_reactions
		WHERE post_id = $1::uuid
		  AND user_id = $2
	`

	if _, err := fs.db.Exec(query, postID, userID); err != nil {
		return fmt.Errorf("UnlikePost: %w", err)
	}

	return nil
}

func (fs *FeedStore) GetPostLikeState(postID string, userID int) (*types.FeedLikeResponse, error) {
	query := `
		SELECT
			COALESCE((
				SELECT COUNT(*)
				FROM post_reactions
				WHERE post_id = $1::uuid
			), 0) AS likes_count,
			EXISTS(
				SELECT 1
				FROM post_reactions
				WHERE post_id = $1::uuid
				  AND user_id = $2
			) AS is_liked
	`

	var resp types.FeedLikeResponse
	if err := fs.db.Get(&resp, query, postID, userID); err != nil {
		return nil, fmt.Errorf("GetPostLikeState: %w", err)
	}

	resp.PostID = postID
	return &resp, nil
}

func (fs *FeedStore) ListPostsByAuthorID(authorID string, currentUserID int) ([]types.FeedPostRow, error) {
	query := `
		SELECT
			p.id,
			p.author_id::text AS author_id,
			p.community_id,
			c.title AS community_title,
			p.session_id,
			p.kind,
			p.description,
			p.location,
			p.created_at,
			COALESCE((
				SELECT COUNT(*)
				FROM post_reactions pr
				WHERE pr.post_id = p.id
			), 0) AS likes_count,
			COALESCE((
				SELECT COUNT(*)
				FROM post_comments pc
				WHERE pc.post_id = p.id
			), 0) AS comments_count,
			EXISTS(
				SELECT 1
				FROM post_reactions pr2
				WHERE pr2.post_id = p.id
				  AND pr2.user_id = $2
			) AS is_liked,
			EXISTS(
				SELECT 1
				FROM user_follows uf
				WHERE uf.follower_id = $2
				  AND uf.followee_id = p.author_id
			) AS is_from_following,
			EXISTS(
				SELECT 1
				FROM communities dc
				JOIN community_members me
					ON me.community_id = dc.id
				   AND me.user_id = $2
				JOIN community_members other_member
					ON other_member.community_id = dc.id
				   AND other_member.user_id = p.author_id
				WHERE dc.kind = 'direct'
			) AS is_from_direct_chat,
			EXISTS(
				SELECT 1
				FROM communities gc
				JOIN community_members me2
					ON me2.community_id = gc.id
				   AND me2.user_id = $2
				WHERE gc.id = p.community_id
				  AND gc.kind = 'joined_group'
			) AS is_from_group_community
		FROM posts p
		LEFT JOIN communities c
			ON c.id = p.community_id
		WHERE p.author_id::text = $1
		ORDER BY p.created_at DESC
		LIMIT 50
	`

	var rows []types.FeedPostRow
	if err := fs.db.Select(&rows, query, authorID, currentUserID); err != nil {
		return nil, fmt.Errorf("ListPostsByAuthorID: %w", err)
	}

	return rows, nil
}

func (fs *FeedStore) InsertPost(authorID int, sessionID string, description string, location *string, communityID *string, kind string,) (*types.FeedPostRow, error) {
	query := `
		INSERT INTO posts (
			id,
			author_id,
			community_id,
			session_id,
			kind,
			description,
			location,
			created_at
		)
		VALUES (
			gen_random_uuid(),
			$1,
			$2,
			$3,
			$4,
			$5,
			$6,
			NOW()
		)
		RETURNING
			id,
			author_id::text AS author_id,
			community_id,
			NULL::text AS community_title,
			session_id,
			kind,
			description,
			location,
			created_at,
			0 AS likes_count,
			0 AS comments_count,
			false AS is_liked,
			false AS is_from_following,
			false AS is_from_direct_chat,
			false AS is_from_group_community
	`

	var row types.FeedPostRow
	if err := fs.db.Get(
		&row,
		query,
		authorID,
		communityID,
		sessionID,
		kind,
		description,
		location,
	); err != nil {
		return nil, fmt.Errorf("InsertPost: %w", err)
	}

	return &row, nil
}

func (fs *FeedStore) GetPostAuthorID(postID string) (int, error) {
	var authorID int

	query := `
		SELECT author_id
		FROM posts
		WHERE id = $1::uuid
	`

	if err := fs.db.Get(&authorID, query, postID); err != nil {
		return 0, fmt.Errorf("GetPostAuthorID: %w", err)
	}

	return authorID, nil
}