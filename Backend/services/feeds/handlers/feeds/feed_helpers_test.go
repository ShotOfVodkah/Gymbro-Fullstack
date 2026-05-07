package feeds

import (
	"net/http/httptest"
	"testing"

	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
	"github.com/stretchr/testify/assert"
)

func TestParseFeedPageLimit(t *testing.T) {
	t.Run("default", func(t *testing.T) {
		req := httptest.NewRequest("GET", "/feed?cursor=x", nil)
		assert.Equal(t, 20, parseFeedPageLimit(req))
	})

	t.Run("invalid_returns_default", func(t *testing.T) {
		req := httptest.NewRequest("GET", "/feed?limit=abc", nil)
		assert.Equal(t, 20, parseFeedPageLimit(req))
	})

	t.Run("caps_max", func(t *testing.T) {
		req := httptest.NewRequest("GET", "/feed?limit=1000", nil)
		assert.Equal(t, 50, parseFeedPageLimit(req))
	})
}

func TestParseFeedCursor(t *testing.T) {
	req := httptest.NewRequest("GET", "/feed", nil)
	assert.Nil(t, parseFeedCursor(req))

	req = httptest.NewRequest("GET", "/feed?cursor=c1", nil)
	got := parseFeedCursor(req)
	if assert.NotNil(t, got) {
		assert.Equal(t, "c1", *got)
	}
}

func TestParseFeedScope(t *testing.T) {
	req := httptest.NewRequest("GET", "/feed", nil)
	assert.Equal(t, types.FeedScopeAll, parseFeedScope(req))

	req = httptest.NewRequest("GET", "/feed?scope=friends", nil)
	assert.Equal(t, types.FeedScopeFriends, parseFeedScope(req))

	req = httptest.NewRequest("GET", "/feed?scope=nope", nil)
	assert.Equal(t, types.FeedScopeAll, parseFeedScope(req))
}

func TestUniqueSessionIDs(t *testing.T) {
	s1 := "s1"
	s2 := "s2"
	rows := []types.FeedPostRow{
		{SessionID: &s1, AuthorID: "1"},
		{SessionID: &s1, AuthorID: "2"},
		{SessionID: nil, AuthorID: "3"},
		{SessionID: &s2, AuthorID: "4"},
	}
	assert.ElementsMatch(t, []string{"s1", "s2"}, uniqueSessionIDs(rows))
}

func TestUniqueAuthorIDs(t *testing.T) {
	rows := []types.FeedPostRow{
		{AuthorID: "10"},
		{AuthorID: "10"},
		{AuthorID: "bad"},
		{AuthorID: "11"},
	}
	assert.ElementsMatch(t, []int{10, 11}, uniqueAuthorIDs(rows))
}

func TestMapCommunityIcon(t *testing.T) {
	assert.Equal(t, "person.fill", mapCommunityIcon("direct"))
	assert.Equal(t, "person.3.fill", mapCommunityIcon("joined_group"))
	assert.Equal(t, "person.3.fill", mapCommunityIcon("other"))
}

func TestHasSuffixAndExtractors(t *testing.T) {
	assert.True(t, hasSuffix("/posts/p1/likes", "/likes"))
	assert.False(t, hasSuffix("/posts/p1/likes", "/comments"))

	assert.Equal(t, "p1", extractPostID("/posts/p1/likes", "/likes"))
	assert.Equal(t, "", extractPostID("/posts//likes", "/likes"))
	assert.Equal(t, "", extractPostID("/posts/p1", "/likes"))

	assert.Equal(t, "42", extractUserIDFromFeedPostsPath("/feed/users/42/posts"))
	assert.Equal(t, "", extractUserIDFromFeedPostsPath("/feed/users//posts"))
	assert.Equal(t, "", extractUserIDFromFeedPostsPath("/feed/users/42"))
}

