# ---------- build stage ----------
FROM golang:1.25 AS build

WORKDIR /app

COPY pkg/authmw ./pkg/authmw
COPY services/challenges/go.mod services/challenges/go.sum ./services/challenges/
RUN cd services/challenges && go mod download

COPY services/challenges ./services/challenges
RUN cd services/challenges && go build -o /bin/challengesserver ./cmd/challengesserver

RUN go install github.com/pressly/goose/v3/cmd/goose@latest

# ---------- runtime stage ----------
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates netcat-openbsd && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /bin/challengesserver /usr/local/bin/challengesserver
COPY --from=build /go/bin/goose /usr/local/bin/goose
COPY services/challenges/db/migrations ./db/migrations
COPY deploy/challenges-entrypoint.sh /usr/local/bin/challenges-entrypoint.sh

RUN chmod +x /usr/local/bin/challenges-entrypoint.sh

EXPOSE 8088
CMD ["/usr/local/bin/challenges-entrypoint.sh"]
