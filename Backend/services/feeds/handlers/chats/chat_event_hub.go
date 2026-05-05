package chats

import (
	"sync"

	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

type ChatEventHub struct {
	mu          sync.RWMutex
	subscribers map[string]map[chan types.ChatRealtimeEvent]struct{}
}

func NewChatEventHub() *ChatEventHub {
	return &ChatEventHub{
		subscribers: make(map[string]map[chan types.ChatRealtimeEvent]struct{}),
	}
}

func (h *ChatEventHub) Subscribe(chatID string) chan types.ChatRealtimeEvent {
	ch := make(chan types.ChatRealtimeEvent, 16)

	h.mu.Lock()
	defer h.mu.Unlock()

	if h.subscribers[chatID] == nil {
		h.subscribers[chatID] = make(map[chan types.ChatRealtimeEvent]struct{})
	}

	h.subscribers[chatID][ch] = struct{}{}
	return ch
}

func (h *ChatEventHub) Unsubscribe(chatID string, ch chan types.ChatRealtimeEvent) {
	h.mu.Lock()
	defer h.mu.Unlock()

	if subs, ok := h.subscribers[chatID]; ok {
		delete(subs, ch)
		close(ch)

		if len(subs) == 0 {
			delete(h.subscribers, chatID)
		}
	}
}

func (h *ChatEventHub) Publish(chatID string, event types.ChatRealtimeEvent) {
	h.mu.RLock()
	defer h.mu.RUnlock()

	for ch := range h.subscribers[chatID] {
		select {
		case ch <- event:
		default:
		}
	}
}