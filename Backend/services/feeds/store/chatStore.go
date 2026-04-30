package store

import (
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
	"github.com/jmoiron/sqlx"
)

var ErrNotFound = errors.New("not found")

type ChatStore struct {
	db *sqlx.DB
}

func NewChatStore(db *sqlx.DB) ChatStore {
	return ChatStore{db: db}
}

func newUUIDLikeID() string {
	b := make([]byte, 16)
	_, _ = rand.Read(b)
	hexStr := hex.EncodeToString(b)

	return fmt.Sprintf(
		"%s-%s-%s-%s-%s",
		hexStr[0:8],
		hexStr[8:12],
		hexStr[12:16],
		hexStr[16:20],
		hexStr[20:32],
	)
}

type Community struct {
	ID          string
	Title       *string
	Description *string
	Kind        string
	CreatedBy   int
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

type CommunityMember struct {
	ID          string
	CommunityID string
	UserID      int
	Role        string
	CreatedAt   time.Time
}

type CommunityMessage struct {
	ID          string
	CommunityID string
	SenderID    int
	Kind        string
	Text        *string
	SessionID   *string
	CreatedAt   time.Time
}

type communityRow struct {
	ID          string     `db:"id"`
	Title       *string    `db:"title"`
	Description *string    `db:"description"`
	Kind        string     `db:"kind"`
	CreatedBy   int        `db:"created_by"`
	CreatedAt   time.Time  `db:"created_at"`
	UpdatedAt   time.Time  `db:"updated_at"`
}

type communityMemberRow struct {
	ID          string    `db:"id"`
	CommunityID string    `db:"community_id"`
	UserID      int       `db:"user_id"`
	Role        string    `db:"role"`
	CreatedAt   time.Time `db:"created_at"`
}

type communityMessageRow struct {
	ID          string    `db:"id"`
	CommunityID string    `db:"community_id"`
	SenderID    int       `db:"sender_id"`
	Kind        string    `db:"kind"`
	Text        *string   `db:"text"`
	SessionID   *string   `db:"session_id"`
	CreatedAt   time.Time `db:"created_at"`
}

type messageReactionRow struct {
	MessageID        string `db:"message_id"`
	Emoji            string `db:"emoji"`
	Count            int    `db:"count"`
	IsSelectedByMe   bool   `db:"is_selected_by_me"`
}

func rowToCommunity(row communityRow) Community {
	return Community{
		ID:          row.ID,
		Title:       row.Title,
		Description: row.Description,
		Kind:        row.Kind,
		CreatedBy:   row.CreatedBy,
		CreatedAt:   row.CreatedAt,
		UpdatedAt:   row.UpdatedAt,
	}
}

func rowToCommunityMember(row communityMemberRow) CommunityMember {
	return CommunityMember{
		ID:          row.ID,
		CommunityID: row.CommunityID,
		UserID:      row.UserID,
		Role:        row.Role,
		CreatedAt:   row.CreatedAt,
	}
}

func rowToCommunityMessage(row communityMessageRow) CommunityMessage {
	return CommunityMessage{
		ID:          row.ID,
		CommunityID: row.CommunityID,
		SenderID:    row.SenderID,
		Kind:        row.Kind,
		Text:        row.Text,
		SessionID:   row.SessionID,
		CreatedAt:   row.CreatedAt,
	}
}

func (cs *ChatStore) FindDirectCommunityBetweenUsers(userA, userB int) (*Community, error) {
	query := `
		SELECT
			c.id,
			c.title,
			c.description,
			c.kind,
			c.created_by,
			c.created_at,
			c.updated_at
		FROM communities c
		JOIN community_members cm1 ON cm1.community_id = c.id
		JOIN community_members cm2 ON cm2.community_id = c.id
		WHERE c.kind = 'direct'
		  AND cm1.user_id = $1
		  AND cm2.user_id = $2
		  AND (
			SELECT COUNT(*)
			FROM community_members cm
			WHERE cm.community_id = c.id
		  ) = 2
		LIMIT 1
	`

	var row communityRow
	err := cs.db.Get(&row, query, userA, userB)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("FindDirectCommunityBetweenUsers: %w", err)
	}

	community := rowToCommunity(row)
	return &community, nil
}

func (cs *ChatStore) CreateCommunity(kind string, title, description *string, createdBy int) (*Community, error) {
	id := newUUIDLikeID()

	query := `
		INSERT INTO communities (
			id,
			title,
			description,
			kind,
			created_by,
			created_at,
			updated_at
		)
		VALUES ($1, $2, $3, $4, $5, NOW(), NOW())
	`

	_, err := cs.db.Exec(query, id, title, description, kind, createdBy)
	if err != nil {
		return nil, fmt.Errorf("CreateCommunity: %w", err)
	}

	return cs.GetCommunityByID(id)
}

func (cs *ChatStore) GetCommunityByID(id string) (*Community, error) {
	query := `
		SELECT
			id,
			title,
			description,
			kind,
			created_by,
			created_at,
			updated_at
		FROM communities
		WHERE id = $1
	`

	var row communityRow
	err := cs.db.Get(&row, query, id)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("GetCommunityByID: %w", err)
	}

	community := rowToCommunity(row)
	return &community, nil
}

func (cs *ChatStore) UpdateCommunity(id string, title, description string) (*Community, error) {
	query := `
		UPDATE communities
		SET title = $1,
		    description = $2,
		    updated_at = NOW()
		WHERE id = $3
	`

	res, err := cs.db.Exec(query, nullableString(title), nullableString(description), id)
	if err != nil {
		return nil, fmt.Errorf("UpdateCommunity: %w", err)
	}

	affected, _ := res.RowsAffected()
	if affected == 0 {
		return nil, ErrNotFound
	}

	return cs.GetCommunityByID(id)
}

func (cs *ChatStore) DeleteCommunity(id string) error {
	res, err := cs.db.Exec(`DELETE FROM communities WHERE id = $1`, id)
	if err != nil {
		return fmt.Errorf("DeleteCommunity: %w", err)
	}

	affected, _ := res.RowsAffected()
	if affected == 0 {
		return ErrNotFound
	}

	return nil
}

func (cs *ChatStore) AddCommunityMembers(communityID string, userIDs []int) error {
	if len(userIDs) == 0 {
		return nil
	}

	tx, err := cs.db.Beginx()
	if err != nil {
		return fmt.Errorf("AddCommunityMembers begin: %w", err)
	}
	defer tx.Rollback()

	for _, userID := range userIDs {
		_, err := tx.Exec(`
			INSERT INTO community_members (
				id,
				community_id,
				user_id,
				role,
				created_at
			)
			VALUES ($1, $2, $3, 'member', NOW())
			ON CONFLICT (community_id, user_id) DO NOTHING
		`, newUUIDLikeID(), communityID, userID)
		if err != nil {
			return fmt.Errorf("AddCommunityMembers insert user %d: %w", userID, err)
		}
	}

	if err := tx.Commit(); err != nil {
		return fmt.Errorf("AddCommunityMembers commit: %w", err)
	}

	return nil
}

func (cs *ChatStore) ListCommunityMembers(communityID string) ([]CommunityMember, error) {
	query := `
		SELECT
			id,
			community_id,
			user_id,
			role,
			created_at
		FROM community_members
		WHERE community_id = $1
		ORDER BY created_at, user_id
	`

	var rows []communityMemberRow
	if err := cs.db.Select(&rows, query, communityID); err != nil {
		return nil, fmt.Errorf("ListCommunityMembers: %w", err)
	}

	result := make([]CommunityMember, 0, len(rows))
	for _, row := range rows {
		result = append(result, rowToCommunityMember(row))
	}

	return result, nil
}

func (cs *ChatStore) RemoveCommunityMember(communityID string, userID int) error {
	res, err := cs.db.Exec(`
		DELETE FROM community_members
		WHERE community_id = $1 AND user_id = $2
	`, communityID, userID)
	if err != nil {
		return fmt.Errorf("RemoveCommunityMember: %w", err)
	}

	affected, _ := res.RowsAffected()
	if affected == 0 {
		return ErrNotFound
	}

	return nil
}

func (cs *ChatStore) IsCommunityMember(communityID string, userID int) (bool, error) {
	var exists bool
	query := `
		SELECT EXISTS(
			SELECT 1
			FROM community_members
			WHERE community_id = $1
			  AND user_id = $2
		)
	`

	if err := cs.db.Get(&exists, query, communityID, userID); err != nil {
		return false, fmt.Errorf("IsCommunityMember: %w", err)
	}

	return exists, nil
}

func (cs *ChatStore) InsertMessage(
	communityID string,
	senderID int,
	kind string,
	text, sessionID *string,
) (*CommunityMessage, error) {
	id := newUUIDLikeID()

	query := `
		INSERT INTO community_messages (
			id,
			community_id,
			sender_id,
			kind,
			text,
			session_id,
			created_at
		)
		VALUES ($1, $2, $3, $4, $5, $6, NOW())
	`

	_, err := cs.db.Exec(query, id, communityID, senderID, kind, text, sessionID)
	if err != nil {
		return nil, fmt.Errorf("InsertMessage: %w", err)
	}

	var row communityMessageRow
	err = cs.db.Get(&row, `
		SELECT
			id,
			community_id,
			sender_id,
			kind,
			text,
			session_id,
			created_at
		FROM community_messages
		WHERE id = $1
	`, id)
	if err != nil {
		return nil, fmt.Errorf("InsertMessage fetch: %w", err)
	}

	message := rowToCommunityMessage(row)
	return &message, nil
}

func (cs *ChatStore) ListMessagesByCommunityID(communityID string) ([]CommunityMessage, error) {
	query := `
		SELECT
			id,
			community_id,
			sender_id,
			kind,
			text,
			session_id,
			created_at
		FROM community_messages
		WHERE community_id = $1
		ORDER BY created_at ASC
	`

	var rows []communityMessageRow
	if err := cs.db.Select(&rows, query, communityID); err != nil {
		return nil, fmt.Errorf("ListMessagesByCommunityID: %w", err)
	}

	result := make([]CommunityMessage, 0, len(rows))
	for _, row := range rows {
		result = append(result, rowToCommunityMessage(row))
	}

	return result, nil
}

func (cs *ChatStore) GetMessageByID(messageID string) (*CommunityMessage, error) {
	query := `
		SELECT
			id,
			community_id,
			sender_id,
			kind,
			text,
			session_id,
			created_at
		FROM community_messages
		WHERE id = $1
	`

	var row communityMessageRow
	err := cs.db.Get(&row, query, messageID)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("GetMessageByID: %w", err)
	}

	message := rowToCommunityMessage(row)
	return &message, nil
}

func (cs *ChatStore) ToggleReaction(messageID string, userID int, emoji string) error {
	tx, err := cs.db.Beginx()
	if err != nil {
		return fmt.Errorf("ToggleReaction begin: %w", err)
	}
	defer tx.Rollback()

	var exists bool
	err = tx.Get(&exists, `
		SELECT EXISTS(
			SELECT 1
			FROM community_message_reactions
			WHERE message_id = $1
			  AND user_id = $2
			  AND emoji = $3
		)
	`, messageID, userID, emoji)
	if err != nil {
		return fmt.Errorf("ToggleReaction exists: %w", err)
	}

	if exists {
		_, err = tx.Exec(`
			DELETE FROM community_message_reactions
			WHERE message_id = $1
			  AND user_id = $2
			  AND emoji = $3
		`, messageID, userID, emoji)
		if err != nil {
			return fmt.Errorf("ToggleReaction delete: %w", err)
		}
	} else {
		_, err = tx.Exec(`
			INSERT INTO community_message_reactions (
				id,
				message_id,
				user_id,
				emoji,
				created_at
			)
			VALUES ($1, $2, $3, $4, NOW())
		`, newUUIDLikeID(), messageID, userID, emoji)
		if err != nil {
			return fmt.Errorf("ToggleReaction insert: %w", err)
		}
	}

	if err := tx.Commit(); err != nil {
		return fmt.Errorf("ToggleReaction commit: %w", err)
	}

	return nil
}

func (cs *ChatStore) ListReactionsByMessageIDs(
	messageIDs []string,
	currentUserID int,
) (map[string][]types.ChatReactionResponse, error) {
	result := make(map[string][]types.ChatReactionResponse)
	if len(messageIDs) == 0 {
		return result, nil
	}

	query, args, err := sqlx.In(`
		SELECT
			r.message_id,
			r.emoji,
			COUNT(*) AS count,
			BOOL_OR(r.user_id = ?) AS is_selected_by_me
		FROM community_message_reactions r
		WHERE r.message_id IN (?)
		GROUP BY r.message_id, r.emoji
		ORDER BY r.message_id, r.emoji
	`, currentUserID, messageIDs)
	if err != nil {
		return nil, fmt.Errorf("ListReactionsByMessageIDs build: %w", err)
	}

	query = cs.db.Rebind(query)

	var rows []messageReactionRow
	if err := cs.db.Select(&rows, query, args...); err != nil {
		return nil, fmt.Errorf("ListReactionsByMessageIDs select: %w", err)
	}

	for _, row := range rows {
		result[row.MessageID] = append(result[row.MessageID], types.ChatReactionResponse{
			Emoji:          row.Emoji,
			Count:          row.Count,
			IsSelectedByMe: row.IsSelectedByMe,
		})
	}

	return result, nil
}

func nullableString(v string) *string {
	if strings.TrimSpace(v) == "" {
		return nil
	}
	s := v
	return &s
}

func (cs *ChatStore) FindOrCreateDirectCommunity(userA, userB int) (*Community, bool, error) {
	community, err := cs.FindDirectCommunityBetweenUsers(userA, userB)
	if err == nil {
		return community, false, nil
	}
	if !errors.Is(err, ErrNotFound) {
		return nil, false, fmt.Errorf("FindOrCreateDirectCommunity find: %w", err)
	}

	directTitle := "Direct chat"

	community, err = cs.CreateCommunity("direct", &directTitle, nil, userA)
	if err != nil {
		return nil, false, fmt.Errorf("FindOrCreateDirectCommunity create: %w", err)
	}

	if err := cs.AddCommunityMembers(community.ID, []int{userA, userB}); err != nil {
		return nil, false, fmt.Errorf("FindOrCreateDirectCommunity add members: %w", err)
	}

	return community, true, nil
}

func (cs *ChatStore) ListGroupCommunitiesForUser(userID int) ([]Community, error) {
	query := `
		SELECT
			c.id,
			c.title,
			c.description,
			c.kind,
			c.created_by,
			c.created_at,
			c.updated_at
		FROM communities c
		JOIN community_members cm
			ON cm.community_id = c.id
		   AND cm.user_id = $1
		WHERE c.kind = 'joined_group'
		ORDER BY c.updated_at DESC
	`

	var rows []communityRow
	if err := cs.db.Select(&rows, query, userID); err != nil {
		return nil, err
	}

	result := make([]Community, 0, len(rows))
	for _, row := range rows {
		result = append(result, rowToCommunity(row))
	}

	return result, nil
}

func (cs *ChatStore) InsertSystemMessage(
	communityID string,
	kind string,
	text string,
) (*CommunityMessage, error) {
	id := newUUIDLikeID()

	query := `
		INSERT INTO community_messages (
			id,
			community_id,
			sender_id,
			kind,
			text,
			session_id,
			created_at
		)
		VALUES ($1, $2, 0, $3, $4, NULL, NOW())
	`

	_, err := cs.db.Exec(query, id, communityID, kind, text)
	if err != nil {
		return nil, fmt.Errorf("InsertSystemMessage: %w", err)
	}

	return cs.GetMessageByID(id)
}