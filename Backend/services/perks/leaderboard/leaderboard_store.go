package leaderboard

import (
	"context"
	"fmt"

	"github.com/jmoiron/sqlx"
	"github.com/lib/pq"

	"github.com/alexandra-gritsaenko/gymbro-perks/clients"
	"github.com/alexandra-gritsaenko/gymbro-perks/store"
	"github.com/alexandra-gritsaenko/gymbro-perks/types"
)

type Store struct {
	db          *sqlx.DB
	perksBase  *store.PerksStore
	feedsClient *clients.FeedsClient
}

func NewStore(
	db *sqlx.DB,
	perksBase *store.PerksStore,
	feedsClient *clients.FeedsClient,
) *Store {
	return &Store{
		db:          db,
		perksBase:  perksBase,
		feedsClient: feedsClient,
	}
}

func (s *Store) GetLeaderboard(
	ctx context.Context,
	currentUserID int64,
	filter string,
	sort string,
) ([]types.LeaderboardResponse, error) {
	if err := s.perksBase.EnsureUser(ctx, currentUserID); err != nil {
		return nil, err
	}

	orderBy := leaderboardOrderBy(sort)

	switch filter {
	case "following":
		userIDs, err := s.feedsClient.FetchFollowingIDs(currentUserID)
		if err != nil {
			return nil, err
		}
		userIDs = append(userIDs, currentUserID)
		return s.queryScopedLeaderboard(ctx, currentUserID, userIDs, orderBy, "following")

	case "friends":
		userIDs, err := s.feedsClient.FetchFriendIDs(currentUserID)
		if err != nil {
			return nil, err
		}
		userIDs = append(userIDs, currentUserID)
		return s.queryScopedLeaderboard(ctx, currentUserID, userIDs, orderBy, "friends")

	default:
		return s.queryAllLeaderboard(ctx, currentUserID, orderBy)
	}
}

func (s *Store) queryAllLeaderboard(
	ctx context.Context,
	currentUserID int64,
	orderBy string,
) ([]types.LeaderboardResponse, error) {
	query := fmt.Sprintf(`
		SELECT
			up.user_id,
			COALESCE(up.completed_workouts, 0) AS completed_workouts,
			us.current_streak_weeks
		FROM user_perks up
		JOIN user_streaks us ON us.user_id = up.user_id
		ORDER BY %s
		LIMIT 20
	`, orderBy)

	var rows []leaderboardRow
	if err := s.db.SelectContext(ctx, &rows, query); err != nil {
		return nil, err
	}

	return mapRows(rows, currentUserID, "all"), nil
}

func (s *Store) queryScopedLeaderboard(
	ctx context.Context,
	currentUserID int64,
	userIDs []int64,
	orderBy string,
	filter string,
) ([]types.LeaderboardResponse, error) {
	if len(userIDs) == 0 {
		return []types.LeaderboardResponse{}, nil
	}

	query := fmt.Sprintf(`
		SELECT
			up.user_id,
			COALESCE(up.completed_workouts, 0) AS completed_workouts,
			us.current_streak_weeks
		FROM user_perks up
		JOIN user_streaks us ON us.user_id = up.user_id
		WHERE up.user_id = ANY($1)
		ORDER BY %s
		LIMIT 20
	`, orderBy)

	var rows []leaderboardRow
	if err := s.db.SelectContext(ctx, &rows, query, pq.Array(userIDs)); err != nil {
		return nil, err
	}

	return mapRows(rows, currentUserID, filter), nil
}

type leaderboardRow struct {
	UserID             int64 `db:"user_id"`
	CompletedWorkouts  int   `db:"completed_workouts"`
	CurrentStreakWeeks int   `db:"current_streak_weeks"`
}

func leaderboardOrderBy(sort string) string {
	switch sort {
	case "workouts":
		return "completed_workouts DESC, current_streak_weeks DESC, up.user_id ASC"
	default:
		return "current_streak_weeks DESC, completed_workouts DESC, up.user_id ASC"
	}
}

func mapRows(
	rows []leaderboardRow,
	currentUserID int64,
	filter string,
) []types.LeaderboardResponse {
	result := make([]types.LeaderboardResponse, 0, len(rows))

	for index, row := range rows {
		isCurrentUser := row.UserID == currentUserID

		result = append(result, types.LeaderboardResponse{
			ID:                 fmt.Sprintf("%d", row.UserID),
			Rank:               index + 1,
			UserID:             fmt.Sprintf("%d", row.UserID),
			Name:               displayName(row.UserID, isCurrentUser),
			Username:           displayUsername(row.UserID, isCurrentUser),
			AvatarSystemName:   "person.fill",
			CurrentStreakWeeks: row.CurrentStreakWeeks,
			CompletedWorkouts:  row.CompletedWorkouts,
			IsCurrentUser:      isCurrentUser,
			IsFollowing:        isCurrentUser || filter == "following",
			IsFriend:           isCurrentUser || filter == "friends",
		})
	}

	return result
}

func displayName(userID int64, isCurrentUser bool) string {
	if isCurrentUser {
		return "You"
	}
	return fmt.Sprintf("User %d", userID)
}

func displayUsername(userID int64, isCurrentUser bool) string {
	if isCurrentUser {
		return "you"
	}
	return fmt.Sprintf("user%d", userID)
}