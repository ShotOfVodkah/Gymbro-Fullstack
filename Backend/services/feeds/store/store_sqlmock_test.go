package store

import (
	"database/sql"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
	"github.com/jmoiron/sqlx"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func newMockDB(t *testing.T) (*sqlx.DB, sqlmock.Sqlmock, func()) {
	t.Helper()
	raw, mock, err := sqlmock.New()
	require.NoError(t, err)
	db := sqlx.NewDb(raw, "sqlmock")
	return db, mock, func() { _ = db.Close() }
}

func TestFeedStore_PostExists(t *testing.T) {
	db, mock, cleanup := newMockDB(t)
	defer cleanup()

	mock.ExpectQuery(`SELECT EXISTS`).
		WithArgs("p1").
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))

	s := NewFeedStore(db)
	ok, err := s.PostExists("p1")
	require.NoError(t, err)
	assert.True(t, ok)
	require.NoError(t, mock.ExpectationsWereMet())
}

func TestFeedStore_GetPostAuthorID(t *testing.T) {
	db, mock, cleanup := newMockDB(t)
	defer cleanup()

	mock.ExpectQuery(`SELECT author_id`).
		WithArgs("p1").
		WillReturnRows(sqlmock.NewRows([]string{"author_id"}).AddRow(42))

	s := NewFeedStore(db)
	authorID, err := s.GetPostAuthorID("p1")
	require.NoError(t, err)
	assert.Equal(t, 42, authorID)
	require.NoError(t, mock.ExpectationsWereMet())
}

func TestFeedStore_ListCommentsByPostID(t *testing.T) {
	db, mock, cleanup := newMockDB(t)
	defer cleanup()

	now := time.Now()
	mock.ExpectQuery(`FROM post_comments`).
		WithArgs("p1").
		WillReturnRows(sqlmock.NewRows([]string{"id", "post_id", "author_id", "content", "created_at"}).
			AddRow("c1", "p1", 1, "hi", now))

	s := NewFeedStore(db)
	items, err := s.ListCommentsByPostID("p1")
	require.NoError(t, err)
	require.Len(t, items, 1)
	assert.Equal(t, "c1", items[0].ID)
	require.NoError(t, mock.ExpectationsWereMet())
}

func TestPeopleStore_IsFollowing(t *testing.T) {
	db, mock, cleanup := newMockDB(t)
	defer cleanup()

	mock.ExpectQuery(`SELECT EXISTS`).
		WithArgs(1, 2).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(false))

	s := NewPeopleStore(db)
	ok, err := s.IsFollowing(1, 2)
	require.NoError(t, err)
	assert.False(t, ok)
	require.NoError(t, mock.ExpectationsWereMet())
}

func TestCalendarStore_ListCommunityMemberIDs(t *testing.T) {
	db, mock, cleanup := newMockDB(t)
	defer cleanup()

	mock.ExpectQuery(`FROM community_members`).
		WithArgs("comm1").
		WillReturnRows(sqlmock.NewRows([]string{"user_id"}).AddRow(1).AddRow(2))

	s := NewCalendarStore(db)
	ids, err := s.ListCommunityMemberIDs("comm1")
	require.NoError(t, err)
	assert.Equal(t, []int{1, 2}, ids)
	require.NoError(t, mock.ExpectationsWereMet())
}

func TestChatStore_FindDirectCommunityBetweenUsers_NotFound(t *testing.T) {
	db, mock, cleanup := newMockDB(t)
	defer cleanup()

	mock.ExpectQuery(`FROM communities`).
		WithArgs(1, 2).
		WillReturnError(sql.ErrNoRows)

	s := NewChatStore(db)
	got, err := s.FindDirectCommunityBetweenUsers(1, 2)
	assert.ErrorIs(t, err, ErrNotFound)
	assert.Nil(t, got)
	require.NoError(t, mock.ExpectationsWereMet())
}

func TestFeedStore_GetPostLikeState(t *testing.T) {
	db, mock, cleanup := newMockDB(t)
	defer cleanup()

	mock.ExpectQuery(`AS likes_count`).
		WithArgs("p1", 7).
		WillReturnRows(sqlmock.NewRows([]string{"likes_count", "is_liked"}).AddRow(3, true))

	s := NewFeedStore(db)
	got, err := s.GetPostLikeState("p1", 7)
	require.NoError(t, err)
	require.NotNil(t, got)
	assert.Equal(t, "p1", got.PostID)
	assert.Equal(t, 3, got.LikesCount)
	assert.True(t, got.IsLiked)
	require.NoError(t, mock.ExpectationsWereMet())
}

func TestFeedStore_ListFeedPostsForUserPaginated_MinimalRow(t *testing.T) {
	db, mock, cleanup := newMockDB(t)
	defer cleanup()

	now := time.Now()
	rows := sqlmock.NewRows([]string{
		"id", "author_id", "community_id", "community_title", "session_id", "kind",
		"description", "location", "created_at",
		"likes_count", "comments_count",
		"is_liked", "is_from_following", "is_from_direct_chat", "is_from_group_community",
	}).AddRow(
		"p1", "1", nil, nil, nil, "workout", "", nil, now,
		0, 0,
		false, false, false, false,
	)

	mock.ExpectQuery(`WITH feed_rows AS`).
		WithArgs(7, nil, 20, "all").
		WillReturnRows(rows)

	s := NewFeedStore(db)
	items, err := s.ListFeedPostsForUserPaginated(7, 20, nil, types.FeedScopeAll)
	require.NoError(t, err)
	require.Len(t, items, 1)
	assert.Equal(t, "p1", items[0].ID)
	require.NoError(t, mock.ExpectationsWereMet())
}

