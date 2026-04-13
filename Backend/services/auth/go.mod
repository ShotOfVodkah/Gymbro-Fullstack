module github.com/alexandra-gritsaenko/gymbro-auth

go 1.25.6

require (
	github.com/alexandra-gritsaenko/gymbro-authmw v0.0.0
	github.com/alexedwards/argon2id v1.0.0
	github.com/dgrijalva/jwt-go v3.2.0+incompatible
	github.com/jmoiron/sqlx v1.4.0
	github.com/lib/pq v1.11.2
	github.com/stretchr/testify v1.11.1
)

replace github.com/alexandra-gritsaenko/gymbro-authmw => ../../pkg/authmw

require (
	github.com/davecgh/go-spew v1.1.1 // indirect
	github.com/pmezard/go-difflib v1.0.0 // indirect
	golang.org/x/crypto v0.14.0 // indirect
	golang.org/x/sys v0.13.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
)
