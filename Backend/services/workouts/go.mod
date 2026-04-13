module github.com/alexandra-gritsaenko/gymbro-workouts

go 1.22.12

require (
	github.com/alexandra-gritsaenko/gymbro-authmw v0.0.0
	github.com/jmoiron/sqlx v1.4.0
	github.com/lib/pq v1.11.2
	github.com/stretchr/testify v1.11.1
)

replace github.com/alexandra-gritsaenko/gymbro-authmw => ../../pkg/authmw

require (
	github.com/davecgh/go-spew v1.1.1 // indirect
	github.com/dgrijalva/jwt-go v3.2.0+incompatible // indirect
	github.com/pmezard/go-difflib v1.0.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
)
