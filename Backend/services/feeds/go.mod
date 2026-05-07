module github.com/alexandra-gritsaenko/gymbro-feeds

go 1.25.6

require (
	github.com/DATA-DOG/go-sqlmock v1.5.2
	github.com/alexandra-gritsaenko/gymbro-authmw v0.0.0
	github.com/google/uuid v1.6.0
	github.com/jmoiron/sqlx v1.4.0
	github.com/lib/pq v1.12.3
	github.com/stretchr/testify v1.11.1
)

require (
	github.com/davecgh/go-spew v1.1.1 // indirect
	github.com/dgrijalva/jwt-go v3.2.0+incompatible
	github.com/pmezard/go-difflib v1.0.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
)

replace github.com/alexandra-gritsaenko/gymbro-authmw => ../../pkg/authmw
