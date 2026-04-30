package service

import (
	"fmt"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-challenges/clients"
	"github.com/alexandra-gritsaenko/gymbro-challenges/models"
	"github.com/alexandra-gritsaenko/gymbro-challenges/store"
)

type ChallengesService interface {
	ListChallenges(userID int64) (*models.ChallengesListResponse, error)
	GetChallengeDetails(userID int64, challengeID string) (*models.ChallengeDetailsResponse, error)
	GetAvailableTeams(userID int64, challengeID string) (*models.AvailableChallengeTeamsResponse, error)
	JoinChallenge(userID int64, challengeID string, chatID string) (*models.JoinChallengeResponse, error)
	LeaveChallenge(userID int64, challengeID string, teamID string) (*models.LeaveChallengeResponse, error)
	GetLeaderboard(userID int64, challengeID string) (*models.ChallengeLeaderboardResponse, error)
	GetActivity(challengeID string) ([]models.ChallengeActivityResponse, error)
	HandleWorkoutCompletedEvent(request models.WorkoutCompletedEventRequest) error
	FinalizeExpiredChallenges() error
}

type ChallengeServiceImpl struct {
	store      store.ChallengeStore
	chatsClient clients.ChatsClient
	analyticsClient *clients.AnalyticsClient
}

func NewChallengesService(
	store store.ChallengeStore,
	chatsClient clients.ChatsClient,
	analyticsClient *clients.AnalyticsClient,
) *ChallengeServiceImpl {
	return &ChallengeServiceImpl{
		store:       store,
		chatsClient: chatsClient,
		analyticsClient: analyticsClient,
	}
}

func (s *ChallengeServiceImpl) ListChallenges(userID int64) (*models.ChallengesListResponse, error) {
	challenges, err := s.store.ListChallenges()
	if err != nil {
		return nil, err
	}

	items := make([]models.ChallengeResponse, 0, len(challenges))
	for _, challenge := range challenges {
		team, err := s.store.GetUserTeamForChallenge(challenge.ID, userID)
		if err != nil {
			return nil, err
		}

		items = append(items, toChallengeResponse(challenge, team))
	}

	return &models.ChallengesListResponse{Challenges: items}, nil
}

func (s *ChallengeServiceImpl) GetChallengeDetails(userID int64, challengeID string) (*models.ChallengeDetailsResponse, error) {
	challenge, err := s.store.GetChallenge(challengeID)
	if err != nil {
		return nil, err
	}

	team, err := s.store.GetUserTeamForChallenge(challengeID, userID)
	if err != nil {
		return nil, err
	}

	var participants []models.ChallengeParticipantResponse
	var teamResponse *models.ChallengeTeamResponse

	if team != nil {
		stats, err := s.store.ListParticipants(challengeID, team.ID)
		if err != nil {
			return nil, err
		}

		participants = toParticipantResponses(stats, challenge.Unit)
		teamResponse = toTeamResponse(*team, len(stats))
	} else {
		participants = []models.ChallengeParticipantResponse{}
	}

	response := &models.ChallengeDetailsResponse{
		ID:                  challenge.ID,
		Title:               challenge.Title,
		Description:         challenge.Description,
		Rules:               defaultRules(),
		Type:                challenge.Type,
		Status:              challenge.Status,
		ParticipationStatus: participationStatus(team),
		Difficulty:          challenge.Difficulty,
		CoverIcon:           challenge.CoverIcon,
		AccentColor:         challenge.AccentColor,
		TargetFilter: 		 challenge.TargetFilter,
		StartDate:           challenge.StartDate,
		EndDate:             challenge.EndDate,
		TargetValue:         challenge.TargetValue,
		CurrentValue:        currentValue(team),
		ProgressPercent:     progressPercent(currentValue(team), challenge.TargetValue),
		Unit:                challenge.Unit,
		Team:                teamResponse,
		Participants:        participants,
		Rewards:             defaultRewards(),
	}

	return response, nil
}

func (s *ChallengeServiceImpl) GetAvailableTeams(userID int64, challengeID string) (*models.AvailableChallengeTeamsResponse, error) {
	_, err := s.store.GetChallenge(challengeID)
	if err != nil {
		return nil, err
	}

	groupChats, err := s.chatsClient.GetUserGroupChats(userID)
	if err != nil {
		return nil, err
	}

	teams := make([]models.AvailableChallengeTeamResponse, 0, len(groupChats))
	for _, chat := range groupChats {
		alreadyJoined, err := s.store.IsChatAlreadyJoined(challengeID, chat.ID)
		if err != nil {
			return nil, err
		}

		canJoin := !alreadyJoined
		var reason *string
		if alreadyJoined {
			value := "Team already participates in this challenge."
			reason = &value
		}

		teams = append(teams, models.AvailableChallengeTeamResponse{
			ChatID:           chat.ID,
			ChatName:         chat.Name,
			AvatarSystemName: chat.AvatarSystemName,
			MembersCount:     chat.MembersCount,
			CanJoin:          canJoin,
			Reason:           reason,
		})
	}

	return &models.AvailableChallengeTeamsResponse{Teams: teams}, nil
}

func (s *ChallengeServiceImpl) JoinChallenge(
	userID int64,
	challengeID string,
	chatID string,
) (*models.JoinChallengeResponse, error) {
	challenge, err := s.store.GetChallenge(challengeID)
	if err != nil {
		return nil, err
	}

	if challenge.Status != "active" {
		return nil, fmt.Errorf("challenge is not active")
	}

	alreadyJoined, err := s.store.IsChatAlreadyJoined(challengeID, chatID)
	if err != nil {
		return nil, err
	}
	if alreadyJoined {
		return nil, fmt.Errorf("team already participates in this challenge")
	}

	chat, err := s.chatsClient.GetGroupChat(chatID)
	if err != nil {
		return nil, err
	}

	if !chat.IsGroup {
		return nil, fmt.Errorf("only group chats can join challenges")
	}

	isMember, err := s.chatsClient.IsUserMemberOfChat(userID, chatID)
	if err != nil {
		return nil, err
	}
	if !isMember {
		return nil, fmt.Errorf("user is not a member of this group chat")
	}

	members, err := s.chatsClient.GetGroupChatMembers(chatID)
	if err != nil {
		return nil, err
	}
	if len(members) == 0 {
		return nil, fmt.Errorf("group chat has no members")
	}

	now := time.Now()
	teamID := fmt.Sprintf("team_%d", now.UnixNano())

	team := models.ChallengeTeam{
		ID:           teamID,
		ChallengeID:  challenge.ID,
		ChatID:       chat.ID,
		TeamName:     chat.Name,
		TeamAvatar:   chat.AvatarSystemName,
		Status:       "in_progress",
		CurrentValue: 0,
		TargetValue:  challenge.TargetValue,
		JoinedAt:     now,
	}

	participants := make([]models.ChallengeParticipantStat, 0, len(members))
	for _, member := range members {
		participants = append(participants, models.ChallengeParticipantStat{
			ID:                fmt.Sprintf("participant_%s_%d", teamID, member.UserID),
			ChallengeID:       challenge.ID,
			TeamID:            teamID,
			UserID:            member.UserID,
			ContributionValue: 0,
			LastActivityAt:    nil,
		})
	}

	if err := s.store.CreateTeamWithParticipants(team, participants); err != nil {
		return nil, err
	}

	s.sendChallengeSystemMessage(team.ChatID, "challenge_joined", fmt.Sprintf("%s joined %s.", team.TeamName, challenge.Title), challenge.ID,)
	s.trackBackendEvent("challenge_joined", map[string]string{ 
		"challenge_id":   challenge.ID,
		"chat_id":        team.ChatID,
		"team_id":        team.ID,
		"team_name":      team.TeamName,
		"challenge_type": challenge.Type,
	})

	return &models.JoinChallengeResponse{
		TeamID:          team.ID,
		ChallengeID:     team.ChallengeID,
		ChatID:          team.ChatID,
		TeamName:        team.TeamName,
		Status:          team.Status,
		CurrentValue:    team.CurrentValue,
		TargetValue:     team.TargetValue,
		ProgressPercent: progressPercent(team.CurrentValue, team.TargetValue),
	}, nil
}

func (s *ChallengeServiceImpl) LeaveChallenge(userID int64, challengeID string, teamID string) (*models.LeaveChallengeResponse, error) {
	team, err := s.store.GetTeamByID(teamID)
	if err != nil {
		return nil, err
	}

	if team.ChallengeID != challengeID {
		return nil, fmt.Errorf("team does not belong to challenge")
	}

	if err := s.store.UpdateTeamStatus(teamID, "left"); err != nil {
		return nil, err
	}

	return &models.LeaveChallengeResponse{Status: "left"}, nil
}

func (s *ChallengeServiceImpl) GetLeaderboard(userID int64, challengeID string) (*models.ChallengeLeaderboardResponse, error) {
	teams, err := s.store.ListLeaderboard(challengeID)
	if err != nil {
		return nil, err
	}

	userTeam, err := s.store.GetUserTeamForChallenge(challengeID, userID)
	if err != nil {
		return nil, err
	}

	items := make([]models.ChallengeLeaderboardTeamResponse, 0, len(teams))
	for index, team := range teams {
		items = append(items, models.ChallengeLeaderboardTeamResponse{
			Rank:              index + 1,
			TeamID:            team.ID,
			ChatID:            team.ChatID,
			TeamName:          team.TeamName,
			TeamAvatar:        team.TeamAvatar,
			MembersCount:      0,
			CurrentValue:      team.CurrentValue,
			TargetValue:       team.TargetValue,
			ProgressPercent:   progressPercent(team.CurrentValue, team.TargetValue),
			Status:            team.Status,
			IsCurrentUserTeam: userTeam != nil && userTeam.ID == team.ID,
		})
	}

	return &models.ChallengeLeaderboardResponse{
		ChallengeID:  challengeID,
		Leaderboard: items,
	}, nil
}

func (s *ChallengeServiceImpl) GetActivity(challengeID string) ([]models.ChallengeActivityResponse, error) {
	events, err := s.store.ListActivity(challengeID)
	if err != nil {
		return nil, err
	}

	items := make([]models.ChallengeActivityResponse, 0, len(events))
	for _, event := range events {
		sourceID := event.SourceID
		items = append(items, models.ChallengeActivityResponse{
			ID:               event.ID,
			UserID:           event.UserID,
			UserName:         fmt.Sprintf("User %d", event.UserID),
			AvatarSystemName: "person.crop.circle.fill",
			Action:           "completed_workout",
			Value:            event.Value,
			Unit:             "workouts",
			SourceID:         &sourceID,
			CreatedAt:        event.CreatedAt,
		})
	}

	return items, nil
}

func toChallengeResponse(challenge models.Challenge, team *models.ChallengeTeam) models.ChallengeResponse {
	return models.ChallengeResponse{
		ID:                  challenge.ID,
		Title:               challenge.Title,
		Description:         challenge.Description,
		Type:                challenge.Type,
		Status:              challenge.Status,
		ParticipationStatus: participationStatus(team),
		Difficulty:          challenge.Difficulty,
		CoverIcon:           challenge.CoverIcon,
		AccentColor:         challenge.AccentColor,
		TargetFilter: 		 challenge.TargetFilter,
		StartDate:           challenge.StartDate,
		EndDate:             challenge.EndDate,
		TargetValue:         challenge.TargetValue,
		CurrentValue:        currentValue(team),
		ProgressPercent:     progressPercent(currentValue(team), challenge.TargetValue),
		Unit:                challenge.Unit,
		Team:                toTeamPreview(team),
	}
}

func toTeamPreview(team *models.ChallengeTeam) *models.ChallengeTeamPreviewResponse {
	if team == nil {
		return nil
	}
	return &models.ChallengeTeamPreviewResponse{
		TeamID:   team.ID,
		ChatID:   team.ChatID,
		TeamName: team.TeamName,
	}
}

func toTeamResponse(team models.ChallengeTeam, membersCount int) *models.ChallengeTeamResponse {
	return &models.ChallengeTeamResponse{
		TeamID:          team.ID,
		ChallengeID:     team.ChallengeID,
		ChatID:          team.ChatID,
		TeamName:        team.TeamName,
		TeamAvatar:      team.TeamAvatar,
		MembersCount:    membersCount,
		CurrentValue:    team.CurrentValue,
		TargetValue:     team.TargetValue,
		ProgressPercent: progressPercent(team.CurrentValue, team.TargetValue),
		Status:          team.Status,
		JoinedAt:        team.JoinedAt,
	}
}

func toParticipantResponses(stats []models.ChallengeParticipantStat, unit string) []models.ChallengeParticipantResponse {
	items := make([]models.ChallengeParticipantResponse, 0, len(stats))
	for index, stat := range stats {
		items = append(items, models.ChallengeParticipantResponse{
			UserID:            stat.UserID,
			Name:              fmt.Sprintf("User %d", stat.UserID),
			AvatarSystemName:  "person.crop.circle.fill",
			ContributionValue: stat.ContributionValue,
			ContributionUnit:  unit,
			RankInTeam:        index + 1,
			LastActivityAt:    stat.LastActivityAt,
			IsMVP:             index == 0,
		})
	}
	return items
}

func participationStatus(team *models.ChallengeTeam) string {
	if team == nil {
		return "not_joined"
	}
	return team.Status
}

func currentValue(team *models.ChallengeTeam) int {
	if team == nil {
		return 0
	}
	return team.CurrentValue
}

func progressPercent(current int, target int) float64 {
	if target <= 0 {
		return 0
	}
	return float64(current) / float64(target) * 100
}

func defaultRules() []string {
	return []string{
		"Only completed workouts count.",
		"Progress is collected from all team members.",
		"Each workout session can be counted only once.",
	}
}

func defaultRewards() []models.ChallengeRewardResponse {
	return []models.ChallengeRewardResponse{
		{
			ID:          "team_crusher",
			Title:       "Team Crusher",
			Description: "Complete a group challenge.",
			IconName:    "trophy.fill",
			IsUnlocked:  false,
		},
	}
}

func (s *ChallengeServiceImpl) HandleWorkoutCompletedEvent(
	request models.WorkoutCompletedEventRequest,
) error {
	if request.UserID <= 0 {
		return fmt.Errorf("user_id is required")
	}

	if request.SessionID == "" {
		return fmt.Errorf("session_id is required")
	}

	teams, err := s.store.ListActiveTeamsForUser(request.UserID)
	if err != nil {
		return err
	}

	completedAt := time.Now()
	if request.CompletedAt != "" {
		if parsed, err := time.Parse(time.RFC3339, request.CompletedAt); err == nil {
			completedAt = parsed
		}
	}

	for _, team := range teams {
		challenge, err := s.store.GetChallengeByTeamID(team.ID)
		if err != nil {
			return err
		}

		value, shouldCount := progressValueForChallenge(*challenge, request)
		if !shouldCount || value <= 0 {
			continue
		}

		event := models.ChallengeProgressEvent{
			ID:          fmt.Sprintf("event_%d", time.Now().UnixNano()),
			ChallengeID: challenge.ID,
			TeamID:      team.ID,
			UserID:      request.UserID,
			SourceType:  "workout_session",
			SourceID:    request.SessionID,
			Value:       value,
			CreatedAt:   completedAt,
		}

		created, updatedTeam, err := s.store.CreateProgressEventAndUpdateProgress(
			event,
			request.UserID,
			value,
		)
		if err != nil {
			return err
		}

		if created && updatedTeam != nil && updatedTeam.Status == "completed" {
			s.sendChallengeSystemMessage(
				updatedTeam.ChatID,
				"challenge_completed",
				fmt.Sprintf("Challenge completed! %d/%d %s done.", updatedTeam.CurrentValue, updatedTeam.TargetValue, challenge.Unit),
				challenge.ID,
			)

			s.trackBackendEvent("challenge_completed", map[string]string{
				"challenge_id":   challenge.ID,
				"chat_id":        updatedTeam.ChatID,
				"team_id":        updatedTeam.ID,
				"team_name":      updatedTeam.TeamName,
				"challenge_type": challenge.Type,
				"current_value":  fmt.Sprintf("%d", updatedTeam.CurrentValue),
				"target_value":   fmt.Sprintf("%d", updatedTeam.TargetValue),
			})
		}
	}

	return nil
}

func progressValueForChallenge(
	challenge models.Challenge,
	event models.WorkoutCompletedEventRequest,
) (int, bool) {
	switch challenge.Type {
	case "team_workouts_count":
		return 1, true

	case "team_training_minutes":
		if event.DurationMinutes <= 0 {
			return 0, false
		}
		return event.DurationMinutes, true

	case "team_calories_burned":
		if event.Calories <= 0 {
			return 0, false
		}
		return event.Calories, true
	
	case "individual_contribution":
		return 1, true

	case "team_streak_days":
		return 1, true

	case "workout_category":
		if challenge.TargetFilter == nil || *challenge.TargetFilter == "" {
			return 0, false
		}

		if *challenge.TargetFilter != event.WorkoutType {
			return 0, false
		}

		return 1, true

	case "exercise_specific":
		if challenge.TargetFilter == nil || *challenge.TargetFilter == "" {
			return 0, false
		}

		if contains(event.ExerciseIDs, *challenge.TargetFilter) {
			return 1, true
		}

		return 0, false

	case "muscle_group":
		if challenge.TargetFilter == nil || *challenge.TargetFilter == "" {
			return 0, false
		}

		if contains(event.MuscleGroups, *challenge.TargetFilter) {
			return 1, true
		}

		return 0, false

	default:
		return 0, false
	}
}

func contains(items []string, target string) bool {
	for _, item := range items {
		if item == target {
			return true
		}
	}
	return false
}

func (s *ChallengeServiceImpl) sendChallengeSystemMessage(
	chatID string,
	kind string,
	text string,
	challengeID string,
) {
	if s.chatsClient == nil {
		return
	}

	err := s.chatsClient.SendChallengeSystemMessage(
		chatID,
		clients.ChallengeSystemMessageRequest{
			Kind:        kind,
			Text:        text,
			ChallengeID: challengeID,
		},
	)
	if err != nil {
		fmt.Printf("failed to send challenge system message: %v\n", err)
	}
}

func (s *ChallengeServiceImpl) FinalizeExpiredChallenges() error {
	teams, err := s.store.FinalizeExpiredTeams()
	if err != nil {
		return err
	}

	for _, team := range teams {
		challenge, err := s.store.GetChallenge(team.ChallengeID)
		if err != nil {
			continue
		}

		switch team.Status {
		case "completed":
			s.sendChallengeSystemMessage(
				team.ChatID,
				"challenge_completed",
				fmt.Sprintf("Challenge completed! %d/%d %s done.", team.CurrentValue, team.TargetValue, challenge.Unit),
				challenge.ID,
			)
			s.trackBackendEvent("challenge_completed", map[string]string{
				"challenge_id":   challenge.ID,
				"chat_id":        team.ChatID,
				"team_id":        team.ID,
				"team_name":      team.TeamName,
				"challenge_type": challenge.Type,
				"current_value":  fmt.Sprintf("%d", team.CurrentValue),
				"target_value":   fmt.Sprintf("%d", team.TargetValue),
				"source":         "daily_finalizer",
			})

		case "failed":
			s.sendChallengeSystemMessage(
				team.ChatID,
				"challenge_failed",
				fmt.Sprintf("Challenge failed. Final progress: %d/%d %s.", team.CurrentValue, team.TargetValue, challenge.Unit),
				challenge.ID,
			)

			s.trackBackendEvent("challenge_failed", map[string]string{
				"challenge_id":   challenge.ID,
				"chat_id":        team.ChatID,
				"team_id":        team.ID,
				"team_name":      team.TeamName,
				"challenge_type": challenge.Type,
				"current_value":  fmt.Sprintf("%d", team.CurrentValue),
				"target_value":   fmt.Sprintf("%d", team.TargetValue),
				"source":         "daily_finalizer",
			})
		}
	}

	return nil
}

func (s *ChallengeServiceImpl) trackBackendEvent(
	eventName string,
	properties map[string]string,
) {
	if s.analyticsClient == nil {
		return
	}

	if err := s.analyticsClient.Track(eventName, properties); err != nil {
		fmt.Printf("failed to send analytics event %s: %v\n", eventName, err)
	}
}