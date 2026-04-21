module github.com/alexandra-gritsaenko/gymbro-profile

go 1.22.12

require (
	github.com/alexandra-gritsaenko/gymbro-authmw v0.0.0
	github.com/dgrijalva/jwt-go v3.2.0+incompatible
	github.com/jmoiron/sqlx v1.4.0
	github.com/lib/pq v1.10.9
)

replace github.com/alexandra-gritsaenko/gymbro-authmw => ../../pkg/authmw
