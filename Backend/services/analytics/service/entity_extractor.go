package service

type ExtractedEntities struct {
	WorkoutID    *string
	PostID       *string
	PersonID     *string
	TargetUserID *string
	CommunityID  *string
	EntityType   *string
	EntityID     *string
}

func ExtractEntities(properties map[string]string) ExtractedEntities {
	var result ExtractedEntities

	if v, ok := properties["workout_id"]; ok && v != "" {
		value := v
		result.WorkoutID = &value
		t := "workout"
		result.EntityType = &t
		result.EntityID = &value
		return result
	}

	if v, ok := properties["post_id"]; ok && v != "" {
		value := v
		result.PostID = &value
		t := "post"
		result.EntityType = &t
		result.EntityID = &value
		return result
	}

	if v, ok := properties["person_id"]; ok && v != "" {
		value := v
		result.PersonID = &value
		t := "person"
		result.EntityType = &t
		result.EntityID = &value
		return result
	}

	if v, ok := properties["target_user_id"]; ok && v != "" {
		value := v
		result.TargetUserID = &value
		t := "user"
		result.EntityType = &t
		result.EntityID = &value
		return result
	}

	if v, ok := properties["community_id"]; ok && v != "" {
		value := v
		result.CommunityID = &value
		t := "community"
		result.EntityType = &t
		result.EntityID = &value
		return result
	}

	return result
}