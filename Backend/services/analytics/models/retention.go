package models

type RetentionCohortItem struct {
	CohortDate   string  `db:"cohort_date" json:"cohort_date"`
	CohortSize   int     `db:"cohort_size" json:"cohort_size"`
	RetainedD1   int     `db:"retained_d1" json:"retained_d1"`
	RetainedD7   int     `db:"retained_d7" json:"retained_d7"`
	RetainedD14  int     `db:"retained_d14" json:"retained_d14"`
	RetainedD30  int     `db:"retained_d30" json:"retained_d30"`
	RetentionD1  float64 `db:"retention_d1" json:"retention_d1"`
	RetentionD7  float64 `db:"retention_d7" json:"retention_d7"`
	RetentionD14 float64 `db:"retention_d14" json:"retention_d14"`
	RetentionD30 float64 `db:"retention_d30" json:"retention_d30"`
}

type RetentionCohortsResponse struct {
	Items []RetentionCohortItem `json:"items"`
}