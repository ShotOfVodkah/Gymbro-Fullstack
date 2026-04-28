module github.com/alexandra-gritsaenko/gymbro-perks

go 1.25.6

require (
	github.com/alexandra-gritsaenko/gymbro-authmw v0.0.0
	github.com/jmoiron/sqlx v1.4.0
	github.com/lib/pq v1.12.3
)

require github.com/dgrijalva/jwt-go v3.2.0+incompatible // indirect

replace github.com/alexandra-gritsaenko/gymbro-authmw => ../../pkg/authmw
