# ---------- build stage ----------
FROM golang:1.25 as build

WORKDIR /app

COPY services/auth/go.mod services/auth/go.sum ./
RUN go mod download
COPY services/auth ./services/auth
RUN cd services/auth && go build -o /bin/authserver ./cmd/authserver
RUN go install github.com/pressly/goose/v3/cmd/goose@latest

# ---------- runtime stage ----------
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates netcat-openbsd && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /bin/authserver /usr/local/bin/authserver
COPY --from=build /go/bin/goose /usr/local/bin/goose
COPY services/auth/db/migrations ./db/migrations
COPY deploy/auth-entrypoint.sh /usr/local/bin/auth-entrypoint.sh
RUN chmod +x /usr/local/bin/auth-entrypoint.sh

EXPOSE 8081
ENTRYPOINT ["/usr/local/bin/auth-entrypoint.sh"]