module github.com/alexandra-gritsaenko/gymbro-profile

go 1.22.12

require (
	github.com/alexandra-gritsaenko/gymbro-authmw v0.0.0
	github.com/dgrijalva/jwt-go v3.2.0+incompatible
	github.com/jmoiron/sqlx v1.4.0
	github.com/lib/pq v1.10.9
	github.com/stretchr/testify v1.11.1
)

require (
	filippo.io/edwards25519 v1.1.0 
	github.com/davecgh/go-spew v1.1.1 
	github.com/go-sql-driver/mysql v1.8.1
	github.com/mattn/go-sqlite3 v1.14.22 
	github.com/pmezard/go-difflib v1.0.0 
	github.com/stretchr/objx v0.5.2 
	gopkg.in/yaml.v3 v3.0.1 
)

replace github.com/alexandra-gritsaenko/gymbro-authmw => ../../pkg/authmw
