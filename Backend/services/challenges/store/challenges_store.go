package store

import (
	"database/sql"
	"errors"

	"github.com/alexandra-gritsaenko/gymbro-challenges/models"
	"github.com/jmoiron/sqlx"
)

var ErrNotFound = errors.New("not found")

type ChallengeStore interface {
	ListChallenges() ([]models.Challenge, error)
	GetChallenge(id string) (*models.Challenge, error)
	GetUserTeamForChallenge(challengeID string, userID int64) (*models.ChallengeTeam, error)
	GetTeamByID(teamID string) (*models.ChallengeTeam, error)
	IsChatAlreadyJoined(challengeID string, chatID string) (bool, error)
	CreateTeam(team models.ChallengeTeam) error
	CreateTeamWithParticipants(team models.ChallengeTeam, participants []models.ChallengeParticipantStat,) error
	UpdateTeamStatus(teamID string, status string) error
	ListParticipants(challengeID string, teamID string) ([]models.ChallengeParticipantStat, error)
	ListActivity(challengeID string) ([]models.ChallengeProgressEvent, error)
	ListLeaderboard(challengeID string) ([]models.ChallengeTeam, error)
	ListActiveTeamsForUser(userID int64) ([]models.ChallengeTeam, error)
	GetChallengeByTeamID(teamID string) (*models.Challenge, error)
	CreateProgressEventAndUpdateProgress(event models.ChallengeProgressEvent, userID int64, value int,) (bool, *models.ChallengeTeam, error)
	FinalizeExpiredTeams() ([]models.ChallengeTeam, error)
}

type PostgresChallengeStore struct {
	db *sqlx.DB
}

func NewPostgresChallengeStore(db *sqlx.DB) *PostgresChallengeStore {
	return &PostgresChallengeStore{db: db}
}

func (s *PostgresChallengeStore) ListChallenges() ([]models.Challenge, error) {
	var challenges []models.Challenge
	err := s.db.Select(&challenges, `
		SELECT *
		FROM challenges
		ORDER BY start_date DESC
	`)
	return challenges, err
}

func (s *PostgresChallengeStore) GetChallenge(id string) (*models.Challenge, error) {
	var challenge models.Challenge
	err := s.db.Get(&challenge, `SELECT * FROM challenges WHERE id = $1`, id)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, ErrNotFound
	}
	return &challenge, err
}

func (s *PostgresChallengeStore) GetUserTeamForChallenge(challengeID string, userID int64) (*models.ChallengeTeam, error) {
	var team models.ChallengeTeam
	err := s.db.Get(&team, `
		SELECT ct.*
		FROM challenge_teams ct
		JOIN challenge_participant_stats cps ON cps.team_id = ct.id
		WHERE ct.challenge_id = $1 AND cps.user_id = $2
		ORDER BY ct.joined_at DESC
		LIMIT 1
	`, challengeID, userID)

	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	return &team, err
}

func (s *PostgresChallengeStore) GetTeamByID(teamID string) (*models.ChallengeTeam, error) {
	var team models.ChallengeTeam
	err := s.db.Get(&team, `SELECT * FROM challenge_teams WHERE id = $1`, teamID)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, ErrNotFound
	}
	return &team, err
}

func (s *PostgresChallengeStore) IsChatAlreadyJoined(challengeID string, chatID string) (bool, error) {
	var exists bool
	err := s.db.Get(&exists, `
		SELECT EXISTS(
			SELECT 1 FROM challenge_teams
			WHERE challenge_id = $1 AND chat_id = $2
		)
	`, challengeID, chatID)
	return exists, err
}

func (s *PostgresChallengeStore) CreateTeam(team models.ChallengeTeam) error {
	_, err := s.db.NamedExec(`
		INSERT INTO challenge_teams (
			id, challenge_id, chat_id, team_name, team_avatar,
			status, current_value, target_value, joined_at
		)
		VALUES (
			:id, :challenge_id, :chat_id, :team_name, :team_avatar,
			:status, :current_value, :target_value, :joined_at
		)
	`, team)
	return err
}

func (s *PostgresChallengeStore) CreateTeamWithParticipants(
	team models.ChallengeTeam,
	participants []models.ChallengeParticipantStat,
) error {
	tx, err := s.db.Beginx()
	if err != nil {
		return err
	}

	defer func() {
		_ = tx.Rollback()
	}()

	_, err = tx.NamedExec(`
		INSERT INTO challenge_teams (
			id, challenge_id, chat_id, team_name, team_avatar,
			status, current_value, target_value, joined_at
		)
		VALUES (
			:id, :challenge_id, :chat_id, :team_name, :team_avatar,
			:status, :current_value, :target_value, :joined_at
		)
	`, team)
	if err != nil {
		return err
	}

	for _, participant := range participants {
		_, err = tx.NamedExec(`
			INSERT INTO challenge_participant_stats (
				id, challenge_id, team_id, user_id,
				contribution_value, last_activity_at
			)
			VALUES (
				:id, :challenge_id, :team_id, :user_id,
				:contribution_value, :last_activity_at
			)
		`, participant)
		if err != nil {
			return err
		}
	}

	return tx.Commit()
}

func (s *PostgresChallengeStore) UpdateTeamStatus(teamID string, status string) error {
	_, err := s.db.Exec(`
		UPDATE challenge_teams
		SET status = $2
		WHERE id = $1
	`, teamID, status)
	return err
}

func (s *PostgresChallengeStore) ListParticipants(challengeID string, teamID string) ([]models.ChallengeParticipantStat, error) {
	var participants []models.ChallengeParticipantStat
	err := s.db.Select(&participants, `
		SELECT *
		FROM challenge_participant_stats
		WHERE challenge_id = $1 AND team_id = $2
		ORDER BY contribution_value DESC
	`, challengeID, teamID)
	return participants, err
}

func (s *PostgresChallengeStore) ListActivity(challengeID string) ([]models.ChallengeProgressEvent, error) {
	var events []models.ChallengeProgressEvent
	err := s.db.Select(&events, `
		SELECT *
		FROM challenge_progress_events
		WHERE challenge_id = $1
		ORDER BY created_at DESC
		LIMIT 50
	`, challengeID)
	return events, err
}

func (s *PostgresChallengeStore) ListLeaderboard(challengeID string) ([]models.ChallengeTeam, error) {
	var teams []models.ChallengeTeam
	err := s.db.Select(&teams, `
		SELECT *
		FROM challenge_teams
		WHERE challenge_id = $1
		ORDER BY current_value DESC, joined_at ASC
	`, challengeID)
	return teams, err
}

func (s *PostgresChallengeStore) ListActiveTeamsForUser(userID int64) ([]models.ChallengeTeam, error) {
	var teams []models.ChallengeTeam

	err := s.db.Select(&teams, `
		SELECT ct.*
		FROM challenge_teams ct
		JOIN challenge_participant_stats cps
			ON cps.team_id = ct.id
		   AND cps.user_id = $1
		JOIN challenges c
			ON c.id = ct.challenge_id
		WHERE c.status = 'active'
		  AND ct.status = 'in_progress'
		  AND NOW() BETWEEN c.start_date AND c.end_date
	`, userID)

	return teams, err
}

func (s *PostgresChallengeStore) GetChallengeByTeamID(teamID string) (*models.Challenge, error) {
	var challenge models.Challenge

	err := s.db.Get(&challenge, `
		SELECT c.*
		FROM challenges c
		JOIN challenge_teams ct
			ON ct.challenge_id = c.id
		WHERE ct.id = $1
	`, teamID)

	if errors.Is(err, sql.ErrNoRows) {
		return nil, ErrNotFound
	}

	return &challenge, err
}

func (s *PostgresChallengeStore) CreateProgressEventAndUpdateProgress(
	event models.ChallengeProgressEvent,
	userID int64,
	value int,
) (bool, *models.ChallengeTeam, error) {
	tx, err := s.db.Beginx()
	if err != nil {
		return false, nil, err
	}
	defer tx.Rollback()

	result, err := tx.NamedExec(`
		INSERT INTO challenge_progress_events (
			id,
			challenge_id,
			team_id,
			user_id,
			source_type,
			source_id,
			value,
			created_at
		)
		VALUES (
			:id,
			:challenge_id,
			:team_id,
			:user_id,
			:source_type,
			:source_id,
			:value,
			:created_at
		)
		ON CONFLICT (challenge_id, team_id, source_type, source_id) DO NOTHING
	`, event)
	if err != nil {
		return false, nil, err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return false, nil, err
	}

	if rowsAffected == 0 {
		return false, nil, nil
	}

	_, err = tx.Exec(`
		UPDATE challenge_participant_stats
		SET contribution_value = contribution_value + $1,
		    last_activity_at = $2
		WHERE challenge_id = $3
		  AND team_id = $4
		  AND user_id = $5
	`, value, event.CreatedAt, event.ChallengeID, event.TeamID, userID)
	if err != nil {
		return false, nil, err
	}

	_, err = tx.Exec(`
		UPDATE challenge_teams
		SET current_value = current_value + $1
		WHERE id = $2
	`, value, event.TeamID)
	if err != nil {
		return false, nil, err
	}

	_, err = tx.Exec(`
		UPDATE challenge_teams
		SET status = 'completed',
		    completed_at = $2
		WHERE id = $1
		  AND current_value >= target_value
		  AND status = 'in_progress'
	`, event.TeamID, event.CreatedAt)
	if err != nil {
		return false, nil, err
	}

	var updatedTeam models.ChallengeTeam
	err = tx.Get(&updatedTeam, `
		SELECT *
		FROM challenge_teams
		WHERE id = $1
	`, event.TeamID)
	if err != nil {
		return false, nil, err
	}

	if err := tx.Commit(); err != nil {
		return false, nil, err
	}

	return true, &updatedTeam, nil
}

func (s *PostgresChallengeStore) FinalizeExpiredTeams() ([]models.ChallengeTeam, error) {
	var teams []models.ChallengeTeam

	err := s.db.Select(&teams, `
		UPDATE challenge_teams ct
		SET status = CASE
				WHEN ct.current_value >= ct.target_value THEN 'completed'
				ELSE 'failed'
			END,
			completed_at = CASE
				WHEN ct.current_value >= ct.target_value THEN NOW()
				ELSE ct.completed_at
			END,
			failed_at = CASE
				WHEN ct.current_value < ct.target_value THEN NOW()
				ELSE ct.failed_at
			END
		FROM challenges c
		WHERE ct.challenge_id = c.id
		  AND ct.status = 'in_progress'
		  AND c.end_date < NOW()
		RETURNING ct.*
	`)

	return teams, err
}