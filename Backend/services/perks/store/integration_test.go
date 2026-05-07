//go:build integration

package store

import (
	"context"
	"os"
	"testing"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
	"github.com/stretchr/testify/require"
)

func TestPerksStore_Integration_EnsureUser(t *testing.T) {
	dsn := os.Getenv("PERKS_TEST_DATABASE_URL")
	if dsn == "" {
		t.Skip("PERKS_TEST_DATABASE_URL is not set")
	}

	db, err := sqlx.Connect("postgres", dsn)
	require.NoError(t, err)
	t.Cleanup(func() { _ = db.Close() })

	s := NewPerksStore(db)
	require.NoError(t, s.EnsureUser(context.Background(), 7))
}

