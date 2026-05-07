package store_test

import (
	"os"
	"testing"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
	"github.com/stretchr/testify/suite"
)

type StoreTestSuite struct {
	suite.Suite
	db *sqlx.DB
}

func (s *StoreTestSuite) SetupTest() {
	conn := os.Getenv("TEST_DATABASE_URL")
	if conn == "" {
		s.T().Skip("TEST_DATABASE_URL is not set")
		return
	}
	db, err := sqlx.Connect("postgres", conn)
	if err != nil {
		s.T().Skipf("failed to connect to TEST_DATABASE_URL: %v", err)
		return
	}
	s.db = db
	s.db.MustExec("truncate users cascade")
}

func TestStoreTestSuite(t *testing.T) {
	suite.Run(t, new(StoreTestSuite))
}
