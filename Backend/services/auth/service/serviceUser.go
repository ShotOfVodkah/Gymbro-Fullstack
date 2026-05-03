package service

import (
	"github.com/alexandra-gritsaenko/gymbro-auth/store"
	"github.com/alexandra-gritsaenko/gymbro-auth/types"
	"github.com/jmoiron/sqlx"
)

type UserService struct {
	store store.UserStore
}

func NewUserService(db *sqlx.DB) UserService {
	return UserService{store: store.NewUserStore(db)}
}

func (us *UserService) AuthenticateUserByEmailPassword(email, password string) (*types.User, error) {
	user, err := us.store.GetUserByEmail(email)
	if err != nil {
		return nil, err
	}
	if _, err := user.CheckPassword(password); err != nil {
		return nil, err
	}
	return user, nil
}

func (us *UserService) CreateUser(user *types.User) (*types.User, error) {
	return us.store.InsertUser(user)
}

func (us *UserService) ListUsers() ([]types.User, error) {
	return us.store.ListUsers()
}

func (us *UserService) GetUserByID(id int) (*types.User, error) {
	return us.store.GetUserByID(id)
}

func (us *UserService) GetUserByEmail(email string) (*types.User, error) {
	return us.store.GetUserByEmail(email)
}

func (us *UserService) MarkEmailVerified(userID int) error {
    return us.store.MarkEmailVerified(userID)
}