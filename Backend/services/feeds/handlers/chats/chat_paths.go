package chats

import "strings"

func parseChatsRootID(path string) (chatID string, ok bool) {
	prefix := "/chats/"
	if !strings.HasPrefix(path, prefix) {
		return "", false
	}
	id := strings.TrimPrefix(path, prefix)
	if id == "" || strings.Contains(id, "/") {
		return "", false
	}
	return id, true
}

func parseChatsResourceSuffix(path, suffix string) (chatID string, ok bool) {
	prefix := "/chats/"
	if !strings.HasPrefix(path, prefix) {
		return "", false
	}
	rest := strings.TrimPrefix(path, prefix)
	if !strings.HasSuffix(rest, suffix) {
		return "", false
	}
	id := strings.TrimSuffix(rest, suffix)
	if id == "" || strings.Contains(id, "/") {
		return "", false
	}
	return id, true
}
