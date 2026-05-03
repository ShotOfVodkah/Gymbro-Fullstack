module github.com/alexandra-gritsaenko/gymbro-challenges

go 1.25.6

replace github.com/alexandra-gritsaenko/gymbro-authmw => ../../pkg/authmw

require (
	github.com/alexandra-gritsaenko/gymbro-authmw v0.0.0-00010101000000-000000000000
	github.com/jmoiron/sqlx v1.4.0
	github.com/lib/pq v1.12.3
)

require github.com/dgrijalva/jwt-go v3.2.0+incompatible // indirect
