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

func TestAnalyticsStore_Integration_SaveBatchEmpty(t *testing.T) {
	dsn := os.Getenv("ANALYTICS_TEST_DATABASE_URL")
	if dsn == "" {
		t.Skip("ANALYTICS_TEST_DATABASE_URL is not set")
	}

	db, err := sqlx.Connect("postgres", dsn)
	require.NoError(t, err)
	t.Cleanup(func() { _ = db.Close() })

	s := NewAnalyticsStore(db)
	_, err = s.SaveBatch(context.Background(), "rid", "b1", "fp1", 7, nil)
	require.NoError(t, err)
}

