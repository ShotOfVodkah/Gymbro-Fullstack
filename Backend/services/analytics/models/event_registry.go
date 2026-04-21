package models

import "strings"

type EventDefinition struct {
	Name               string
	Category           string
	IsErrorEvent       bool
	RequiredProperties []string
}

var eventRegistry = map[string]EventDefinition{
	"screen_viewed": {
		Name:               "screen_viewed",
		Category:           "navigation",
		IsErrorEvent:       false,
		RequiredProperties: []string{"screen"},
	},

	"user_logged_in": {
		Name:               "user_logged_in",
		Category:           "auth",
		IsErrorEvent:       false,
		RequiredProperties: nil,
	},
	"user_logged_out": {
		Name:               "user_logged_out",
		Category:           "auth",
		IsErrorEvent:       false,
		RequiredProperties: nil,
	},
	"user_registered": {
		Name:               "user_registered",
		Category:           "auth",
		IsErrorEvent:       false,
		RequiredProperties: nil,
	},

	"error_occurred": {
		Name:               "error_occurred",
		Category:           "error",
		IsErrorEvent:       true,
		RequiredProperties: []string{"screen", "message"},
	},
	"error_retry_tapped": {
		Name:               "error_retry_tapped",
		Category:           "error",
		IsErrorEvent:       false,
		RequiredProperties: []string{"screen"},
	},

	"feeds_post_author_tapped": {
		Name:               "feeds_post_author_tapped",
		Category:           "social",
		IsErrorEvent:       false,
		RequiredProperties: []string{"post_id"},
	},
	"feeds_post_liked": {
		Name:               "feeds_post_liked",
		Category:           "social",
		IsErrorEvent:       false,
		RequiredProperties: []string{"post_id", "is_liked"},
	},
	"feeds_post_comment_tapped": {
		Name:               "feeds_post_comment_tapped",
		Category:           "social",
		IsErrorEvent:       false,
		RequiredProperties: []string{"post_id"},
	},
	"feeds_post_exercise_tapped": {
		Name:               "feeds_post_exercise_tapped",
		Category:           "social",
		IsErrorEvent:       false,
		RequiredProperties: []string{"post_id"},
	},
	"feeds_post_show_all_exercises": {
		Name:               "feeds_post_show_all_exercises",
		Category:           "social",
		IsErrorEvent:       false,
		RequiredProperties: []string{"post_id"},
	},
	"feeds_tab_selected": {
		Name:               "feeds_tab_selected",
		Category:           "social",
		IsErrorEvent:       false,
		RequiredProperties: []string{"tab"},
	},
	"feeds_chat_type_selected": {
		Name:               "feeds_chat_type_selected",
		Category:           "social",
		IsErrorEvent:       false,
		RequiredProperties: []string{"type"},
	},
	"feeds_direct_chat_person_selected": {
		Name:               "feeds_direct_chat_person_selected",
		Category:           "social",
		IsErrorEvent:       false,
		RequiredProperties: []string{"person_id"},
	},
	"feeds_group_chat_created": {
		Name:               "feeds_group_chat_created",
		Category:           "social",
		IsErrorEvent:       false,
		RequiredProperties: []string{"member_count"},
	},
	"feeds_group_member_toggled": {
		Name:               "feeds_group_member_toggled",
		Category:           "social",
		IsErrorEvent:       false,
		RequiredProperties: []string{"person_id", "selected_count"},
	},
	"feeds_community_opened": {
		Name:               "feeds_community_opened",
		Category:           "social",
		IsErrorEvent:       false,
		RequiredProperties: []string{"community_id"},
	},

	"people_segment_selected": {
		Name:               "people_segment_selected",
		Category:           "social",
		IsErrorEvent:       false,
		RequiredProperties: []string{"segment"},
	},
	"people_person_opened": {
		Name:               "people_person_opened",
		Category:           "social",
		IsErrorEvent:       false,
		RequiredProperties: []string{"person_id"},
	},
	"people_follow_toggled": {
		Name:               "people_follow_toggled",
		Category:           "social",
		IsErrorEvent:       false,
		RequiredProperties: []string{"person_id", "is_following"},
	},
	"people_profile_opened": {
		Name:               "people_profile_opened",
		Category:           "social",
		IsErrorEvent:       false,
		RequiredProperties: []string{"person_id"},
	},
	"people_message_opened": {
		Name:               "people_message_opened",
		Category:           "social",
		IsErrorEvent:       false,
		RequiredProperties: []string{"person_id"},
	},

	"chat_message_sent": {
		Name:               "chat_message_sent",
		Category:           "chat",
		IsErrorEvent:       false,
		RequiredProperties: []string{"is_group"},
	},
	"chat_reaction_added": {
		Name:               "chat_reaction_added",
		Category:           "chat",
		IsErrorEvent:       false,
		RequiredProperties: []string{"emoji"},
	},
	"chat_reaction_toggled": {
		Name:               "chat_reaction_toggled",
		Category:           "chat",
		IsErrorEvent:       false,
		RequiredProperties: []string{"emoji"},
	},
	"chat_workout_message_tapped": {
		Name:               "chat_workout_message_tapped",
		Category:           "chat",
		IsErrorEvent:       false,
		RequiredProperties: []string{"workout_id"},
	},
	"chat_group_people_added": {
		Name:               "chat_group_people_added",
		Category:           "chat",
		IsErrorEvent:       false,
		RequiredProperties: []string{"count"},
	},

	"calendar_month_changed": {
		Name:               "calendar_month_changed",
		Category:           "calendar",
		IsErrorEvent:       false,
		RequiredProperties: []string{"direction"},
	},
	"calendar_person_selected": {
		Name:               "calendar_person_selected",
		Category:           "calendar",
		IsErrorEvent:       false,
		RequiredProperties: []string{"person_id"},
	},
	"calendar_day_tapped": {
		Name:               "calendar_day_tapped",
		Category:           "calendar",
		IsErrorEvent:       false,
		RequiredProperties: []string{"has_my_workout", "has_partner_workout"},
	},

	"profile_primary_action_tapped": {
		Name:               "profile_primary_action_tapped",
		Category:           "profile",
		IsErrorEvent:       false,
		RequiredProperties: []string{"action", "is_own_profile"},
	},
	"profile_relationship_follow_tapped": {
		Name:               "profile_relationship_follow_tapped",
		Category:           "profile",
		IsErrorEvent:       false,
		RequiredProperties: []string{"target_user_id", "is_following_after"},
	},
	"profile_relationship_message_tapped": {
		Name:               "profile_relationship_message_tapped",
		Category:           "profile",
		IsErrorEvent:       false,
		RequiredProperties: []string{"target_user_id"},
	},
	"profile_relationship_posts_tapped": {
		Name:               "profile_relationship_posts_tapped",
		Category:           "profile",
		IsErrorEvent:       false,
		RequiredProperties: []string{"target_user_id", "is_own_profile"},
	},
	"profile_statistics_screen_viewed": {
		Name:               "profile_statistics_screen_viewed",
		Category:           "profile",
		IsErrorEvent:       false,
		RequiredProperties: []string{"screen", "is_own_profile"},
	},

	"settings_row_opened": {
		Name:               "settings_row_opened",
		Category:           "settings",
		IsErrorEvent:       false,
		RequiredProperties: []string{"item_id"},
	},
	"settings_toggle_changed": {
		Name:               "settings_toggle_changed",
		Category:           "settings",
		IsErrorEvent:       false,
		RequiredProperties: []string{"item_id", "is_on"},
	},

	"statistics_chart_selected": {
		Name:               "statistics_chart_selected",
		Category:           "profile",
		IsErrorEvent:       false,
		RequiredProperties: []string{"chart_kind", "selection_id"},
	},

	"workout_created": {
		Name:               "workout_created",
		Category:           "workout",
		IsErrorEvent:       false,
		RequiredProperties: []string{"workout_id", "exercise_count", "workout_type"},
	},
	"workout_premade_added": {
		Name:               "workout_premade_added",
		Category:           "workout",
		IsErrorEvent:       false,
		RequiredProperties: []string{"workout_id", "workout_name"},
	},
	"workout_completed": {
		Name:               "workout_completed",
		Category:           "workout",
		IsErrorEvent:       false,
		RequiredProperties: []string{"workout_id", "duration_seconds", "exercise_count"},
	},
	"workout_generated": {
		Name:               "workout_generated",
		Category:           "workout",
		IsErrorEvent:       false,
		RequiredProperties: []string{"prompt_length", "exercise_count"},
	},
	"workout_share_opened": {
		Name:               "workout_share_opened",
		Category:           "sharing",
		IsErrorEvent:       false,
		RequiredProperties: []string{"screen", "session_id"},
	},
	"workout_share_closed": {
		Name:               "workout_share_closed",
		Category:           "sharing",
		IsErrorEvent:       false,
		RequiredProperties: []string{"screen", "step", "selected_destinations_count"},
	},
	"workout_share_step_viewed": {
		Name:               "workout_share_step_viewed",
		Category:           "sharing",
		IsErrorEvent:       false,
		RequiredProperties: []string{"screen", "step"},
	},
	"workout_share_step_next_tapped": {
		Name:               "workout_share_step_next_tapped",
		Category:           "sharing",
		IsErrorEvent:       false,
		RequiredProperties: []string{"screen", "step"},
	},
	"workout_share_step_back_tapped": {
		Name:               "workout_share_step_back_tapped",
		Category:           "sharing",
		IsErrorEvent:       false,
		RequiredProperties: []string{"screen", "step"},
	},
	"workout_share_feed_toggled": {
		Name:               "workout_share_feed_toggled",
		Category:           "sharing",
		IsErrorEvent:       false,
		RequiredProperties: []string{"screen", "is_enabled"},
	},
	"workout_share_destination_toggled": {
		Name:               "workout_share_destination_toggled",
		Category:           "sharing",
		IsErrorEvent:       false,
		RequiredProperties: []string{"screen", "kind", "is_selected", "selected_count"},
	},
	"workout_share_caption_edited": {
		Name:               "workout_share_caption_edited",
		Category:           "sharing",
		IsErrorEvent:       false,
		RequiredProperties: []string{"screen", "length"},
	},
	"workout_share_location_edited": {
		Name:               "workout_share_location_edited",
		Category:           "sharing",
		IsErrorEvent:       false,
		RequiredProperties: []string{"screen", "is_filled"},
	},
	"workout_share_submit_tapped": {
		Name:               "workout_share_submit_tapped",
		Category:           "sharing",
		IsErrorEvent:       false,
		RequiredProperties: []string{"screen", "publish_to_feed", "existing_chats_count", "direct_users_count", "has_caption", "has_location"},
	},
	"workout_share_submit_succeeded": {
		Name:               "workout_share_submit_succeeded",
		Category:           "sharing",
		IsErrorEvent:       false,
		RequiredProperties: []string{"screen", "created_post", "delivered_chats_count", "created_chats_count"},
	},
	"workout_share_submit_failed": {
		Name:               "workout_share_submit_failed",
		Category:           "sharing",
		IsErrorEvent:       true,
		RequiredProperties: []string{"screen", "message"},
	},
	"workout_share_success_viewed": {
		Name:               "workout_share_success_viewed",
		Category:           "sharing",
		IsErrorEvent:       false,
		RequiredProperties: []string{"screen", "created_post", "delivered_chats_count", "created_chats_count"},
	},
	"workout_share_done_tapped": {
		Name:               "workout_share_done_tapped",
		Category:           "sharing",
		IsErrorEvent:       false,
		RequiredProperties: []string{"screen"},
	},
}

func ResolveEventDefinition(eventName string) (EventDefinition, bool) {
	def, ok := eventRegistry[eventName]
	return def, ok
}

func HasRegisteredEvent(eventName string) bool {
	_, ok := eventRegistry[eventName]
	return ok
}

func IsAllowedEventName(eventName string) bool {
	_, ok := eventRegistry[eventName]
	return ok
}

func NormalizeEventName(eventName string) string {
	return strings.TrimSpace(eventName)
}