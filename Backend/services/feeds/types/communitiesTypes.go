package types

type FeedCommunityRow struct {
	ID          string `db:"id"`
	Title       string `db:"title"`
	Kind        string `db:"kind"`
	MembersCount int   `db:"members_count"`
}

type FeedCommunityItemResponse struct {
	ID            string `json:"id"`
	Title         string `json:"title"`
	Kind          string `json:"kind"`
	Icon          string `json:"icon"`
	IsSystemImage bool   `json:"is_system_image"`
	MembersCount  int    `json:"members_count"`
}