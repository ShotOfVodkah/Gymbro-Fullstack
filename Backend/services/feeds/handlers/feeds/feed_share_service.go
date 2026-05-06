package feeds

import (
	"context"
	"strconv"
	"strings"
	"errors"

	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

type ShareService struct {
	feedStore FeedStore
	chatStore ChatStore
}

func NewShareService(
	feedStore FeedStore,
	chatStore ChatStore,
) *ShareService {
	return &ShareService{
		feedStore: feedStore,
		chatStore: chatStore,
	}
}

func (s *ShareService) ShareWorkout(
	ctx context.Context,
	userID int,
	req types.ShareWorkoutRequest,
) (*types.ShareWorkoutResponse, error) {
	if strings.TrimSpace(req.SessionID) == "" {
		return nil, ErrBadRequest
	}

	createdChatIDs := make([]string, 0)
	deliveredChatIDs := make([]string, 0)
	var createdPostID *string

	if req.PublishToFeed {
		postRow, err := s.feedStore.InsertPost(
			userID,
			req.SessionID,
			strings.TrimSpace(req.Description),
			req.Location,
			nil,
			"personal",
		)
		if err != nil {
			return nil, err
		}
		createdPostID = &postRow.ID
	}

	resolvedChatIDs := make([]string, 0, len(req.ExistingChatIDs)+len(req.DirectUserIDs))
	seenChatIDs := make(map[string]struct{})

	for _, chatID := range req.ExistingChatIDs {
		chatID = strings.TrimSpace(chatID)
		if chatID == "" {
			continue
		}
		if _, ok := seenChatIDs[chatID]; ok {
			continue
		}
		seenChatIDs[chatID] = struct{}{}
		resolvedChatIDs = append(resolvedChatIDs, chatID)
	}

	for _, userIDStr := range req.DirectUserIDs {
		userIDStr = strings.TrimSpace(userIDStr)
		if userIDStr == "" {
			continue
		}

		targetUserID, err := strconv.Atoi(userIDStr)
		if err != nil {
			return nil, ErrBadRequest
		}
		if targetUserID == userID {
			continue
		}

		community, created, err := s.chatStore.FindOrCreateDirectCommunity(userID, targetUserID)
		if err != nil {
			return nil, err
		}

		if created {
			createdChatIDs = append(createdChatIDs, community.ID)
		}

		if _, ok := seenChatIDs[community.ID]; ok {
			continue
		}
		seenChatIDs[community.ID] = struct{}{}
		resolvedChatIDs = append(resolvedChatIDs, community.ID)
	}

	sessionID := strings.TrimSpace(req.SessionID)

	for _, chatID := range resolvedChatIDs {
		isMember, err := s.chatStore.IsCommunityMember(chatID, userID)
		if err != nil {
			return nil, err
		}
		if !isMember {
			return nil, ErrForbidden
		}

		_, err = s.chatStore.InsertMessage(
			chatID,
			userID,
			"workout",
			nil,
			&sessionID,
		)
		if err != nil {
			return nil, err
		}

		deliveredChatIDs = append(deliveredChatIDs, chatID)
	}

	resp := &types.ShareWorkoutResponse{
		CreatedPostID:    createdPostID,
		DeliveredChatIDs: deliveredChatIDs,
		CreatedChatIDs:   createdChatIDs,
	}

	return resp, nil
}

var (
	ErrBadRequest = errors.New("bad request")
	ErrForbidden  = errors.New("forbidden")
)