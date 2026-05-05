//go:build integration

package store

import (
	"context"
	"os"
	"testing"

	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
	"github.com/stretchr/testify/require"
)

func TestFeedsStore_Integration_InsertPostAndExists(t *testing.T) {
	dsn := os.Getenv("FEEDS_TEST_DATABASE_URL")
	if dsn == "" {
		t.Skip("FEEDS_TEST_DATABASE_URL is not set")
	}

	db, err := sqlx.Connect("postgres", dsn)
	require.NoError(t, err)
	t.Cleanup(func() { _ = db.Close() })

	fs := NewFeedStore(db)

	row, err := fs.InsertPost(1, "sess-1", "hello", nil, nil, "workout")
	require.NoError(t, err)
	require.NotNil(t, row)

	ok, err := fs.PostExists(row.ID)
	require.NoError(t, err)
	require.True(t, ok)

	_, err = fs.ListFeedPostsForUserPaginated(1, 5, nil, types.FeedScopeAll)
	require.NoError(t, err)

	_ = context.Background()
}

