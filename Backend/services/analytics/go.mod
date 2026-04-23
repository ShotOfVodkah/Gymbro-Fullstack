module github.com/alexandra-gritsaenko/gymbro-analytics

go 1.25.6

require (
	github.com/alexandra-gritsaenko/gymbro-authmw v0.0.0
	github.com/google/uuid v1.6.0
	github.com/jmoiron/sqlx v1.4.0
	github.com/lib/pq v1.10.9
)

require github.com/dgrijalva/jwt-go v3.2.0+incompatible // indirect

replace github.com/alexandra-gritsaenko/gymbro-authmw => ../../pkg/authmw
