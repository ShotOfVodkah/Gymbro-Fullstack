package store

import (
	"fmt"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
)

type PeopleStore struct {
	db *sqlx.DB
}

func NewPeopleStore(db *sqlx.DB) PeopleStore {
	return PeopleStore{db: db}
}

func (ps *PeopleStore) ListFriendIDsForUser(userID int) ([]int, error) {
	query := `
		SELECT uf.followee_id
		FROM user_follows uf
		JOIN user_follows back
		  ON back.follower_id = uf.followee_id
		 AND back.followee_id = uf.follower_id
		WHERE uf.follower_id = $1
		ORDER BY uf.followee_id
	`

	var ids []int
	if err := ps.db.Select(&ids, query, userID); err != nil {
		return nil, fmt.Errorf("ListFriendIDsForUser: %w", err)
	}
	return ids, nil
}

func (ps *PeopleStore) ListFollowingIDsForUser(userID int) ([]int, error) {
	query := `
		SELECT uf.followee_id
		FROM user_follows uf
		WHERE uf.follower_id = $1
		  AND NOT EXISTS (
			SELECT 1
			FROM user_follows back
			WHERE back.follower_id = uf.followee_id
			  AND back.followee_id = uf.follower_id
		  )
		ORDER BY uf.followee_id
	`

	var ids []int
	if err := ps.db.Select(&ids, query, userID); err != nil {
		return nil, fmt.Errorf("ListFollowingIDsForUser: %w", err)
	}
	return ids, nil
}

func (ps *PeopleStore) ListAllFollowedIDsForUser(userID int) ([]int, error) {
	query := `
		SELECT followee_id
		FROM user_follows
		WHERE follower_id = $1
		ORDER BY followee_id
	`

	var ids []int
	if err := ps.db.Select(&ids, query, userID); err != nil {
		return nil, fmt.Errorf("ListAllFollowedIDsForUser: %w", err)
	}
	return ids, nil
}

func (ps *PeopleStore) IsFollowing(followerID, followeeID int) (bool, error) {
	query := `
		SELECT EXISTS(
			SELECT 1
			FROM user_follows
			WHERE follower_id = $1 AND followee_id = $2
		)
	`

	var exists bool
	if err := ps.db.Get(&exists, query, followerID, followeeID); err != nil {
		return false, fmt.Errorf("IsFollowing: %w", err)
	}
	return exists, nil
}

func (ps *PeopleStore) IsFriend(userID, otherUserID int) (bool, error) {
	query := `
		SELECT EXISTS(
			SELECT 1
			FROM user_follows a
			JOIN user_follows b
			  ON b.follower_id = a.followee_id
			 AND b.followee_id = a.follower_id
			WHERE a.follower_id = $1
			  AND a.followee_id = $2
		)
	`

	var exists bool
	if err := ps.db.Get(&exists, query, userID, otherUserID); err != nil {
		return false, fmt.Errorf("IsFriend: %w", err)
	}
	return exists, nil
}

func (ps *PeopleStore) Follow(followerID, followeeID int) error {
	query := `
		INSERT INTO user_follows (id, follower_id, followee_id)
		VALUES ($1, $2, $3)
		ON CONFLICT (follower_id, followee_id) DO NOTHING
	`

	_, err := ps.db.Exec(query, uuid.NewString(), followerID, followeeID)
	if err != nil {
		return fmt.Errorf("Follow: %w", err)
	}
	return nil
}

func (ps *PeopleStore) Unfollow(followerID, followeeID int) error {
	query := `
		DELETE FROM user_follows
		WHERE follower_id = $1 AND followee_id = $2
	`

	_, err := ps.db.Exec(query, followerID, followeeID)
	if err != nil {
		return fmt.Errorf("Unfollow: %w", err)
	}
	return nil
}