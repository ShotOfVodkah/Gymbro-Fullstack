package service_test

import (
	"database/sql"

	"github.com/alexandra-gritsaenko/gymbro-backend/service"
	"github.com/alexandra-gritsaenko/gymbro-backend/store"
	"github.com/alexandra-gritsaenko/gymbro-backend/types"
	"github.com/alexedwards/argon2id"
)

func (s *ServiceTestSuite) TestAuthenticateUserByEmailPassword() {
	password := "hunter2"
	hash, err := argon2id.CreateHash(password, argon2id.DefaultParams)
	s.NoError(err)
	user := &types.User{
		Email:        "authenticate@example.com",
		PasswordHash: &hash,
	}

	store := store.NewUserStore(s.db)
	user, err = store.InsertUser(user)
	s.NoError(err)

	srv := service.NewUserService(s.db)
	actual, err := srv.AuthenticateUserByEmailPassword(user.Email, password)
	s.NoError(err)
	s.Equal(user.ID, actual.ID)

	actual, err = srv.AuthenticateUserByEmailPassword(user.Email, "invalid")
	s.Nil(actual)
	s.ErrorIs(err, types.ErrInvalidPassword)

	actual, err = srv.AuthenticateUserByEmailPassword("invalid@example.com", password)
	s.Nil(actual)
	s.ErrorIs(err, sql.ErrNoRows)

	s.db.MustExec("update users set password_hash = $1 where email = $2", "invalid", user.Email)
	actual, err = srv.AuthenticateUserByEmailPassword(user.Email, password)
	s.ErrorIs(err, types.ErrNoPasswordSet)
	s.Nil(actual)
}
