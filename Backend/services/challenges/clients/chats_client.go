package clients

import (
	"encoding/json"
	"fmt"
	"net/http"
	"bytes"
)

type GroupChat struct {
	ID                string `json:"id"`
	Name              string `json:"name"`
	AvatarSystemName  string `json:"avatar_system_name"`
	MembersCount      int    `json:"members_count"`
	IsGroup           bool   `json:"is_group"`
}

type GroupChatMember struct {
	UserID int64 `json:"user_id"`
}

type ChallengeSystemMessageRequest struct {
	Kind        string `json:"kind"`
	Text        string `json:"text"`
	ChallengeID string `json:"challenge_id,omitempty"`
}

type ChatsClient interface {
	GetUserGroupChats(userID int64) ([]GroupChat, error)
	IsUserMemberOfChat(userID int64, chatID string) (bool, error)
	GetGroupChat(chatID string) (*GroupChat, error)
	GetGroupChatMembers(chatID string) ([]GroupChatMember, error)
	SendChallengeSystemMessage(chatID string, request ChallengeSystemMessageRequest) error
}

type HTTPChatsClient struct {
	baseURL        string
	internalSecret string
	client         *http.Client
}

func NewHTTPChatsClient(baseURL string, internalSecret string) *HTTPChatsClient {
	return &HTTPChatsClient{
		baseURL:        baseURL,
		internalSecret: internalSecret,
		client:         http.DefaultClient,
	}
}

func (c *HTTPChatsClient) GetUserGroupChats(userID int64) ([]GroupChat, error) {
	var response []GroupChat
	err := c.get(fmt.Sprintf("/internal/chats/users/%d/groups", userID), &response)
	return response, err
}

func (c *HTTPChatsClient) GetGroupChat(chatID string) (*GroupChat, error) {
	var response GroupChat
	err := c.get(fmt.Sprintf("/internal/chats/%s", chatID), &response)
	return &response, err
}

func (c *HTTPChatsClient) GetGroupChatMembers(chatID string) ([]GroupChatMember, error) {
	var response []GroupChatMember
	err := c.get(fmt.Sprintf("/internal/chats/%s/members", chatID), &response)
	return response, err
}

func (c *HTTPChatsClient) IsUserMemberOfChat(userID int64, chatID string) (bool, error) {
	members, err := c.GetGroupChatMembers(chatID)
	if err != nil {
		return false, err
	}

	for _, member := range members {
		if member.UserID == userID {
			return true, nil
		}
	}

	return false, nil
}

func (c *HTTPChatsClient) get(path string, target any) error {
	req, err := http.NewRequest(http.MethodGet, c.baseURL+path, nil)
	if err != nil {
		return err
	}

	req.Header.Set("X-Internal-Secret", c.internalSecret)

	resp, err := c.client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return fmt.Errorf("feeds service returned status %d", resp.StatusCode)
	}

	return json.NewDecoder(resp.Body).Decode(target)
}

func (c *HTTPChatsClient) SendChallengeSystemMessage(chatID string, request ChallengeSystemMessageRequest,) error {
	return c.post(
		fmt.Sprintf("/internal/chats/%s/system-message", chatID),
		request,
		nil,
	)
}

func (c *HTTPChatsClient) post(path string, body any, target any) error {
	data, err := json.Marshal(body)
	if err != nil {
		return err
	}

	req, err := http.NewRequest(
		http.MethodPost,
		c.baseURL+path,
		bytes.NewReader(data),
	)
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-Internal-Secret", c.internalSecret)

	resp, err := c.client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return fmt.Errorf("feeds service returned status %d", resp.StatusCode)
	}

	if target == nil {
		return nil
	}

	return json.NewDecoder(resp.Body).Decode(target)
}