FROM golang:1.25 AS build

WORKDIR /app

COPY pkg/authmw ./pkg/authmw
COPY services/profile/go.mod services/profile/go.sum ./services/profile/
RUN cd services/profile && go mod download
COPY services/profile ./services/profile
RUN cd services/profile && go build -o /bin/profileserver ./cmd/profileserver
RUN go install github.com/pressly/goose/v3/cmd/goose@latest

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates netcat-openbsd && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /bin/profileserver /usr/local/bin/profileserver
COPY --from=build /go/bin/goose /usr/local/bin/goose
COPY services/profile/db/migrations ./db/migrations
COPY deploy/profile-entrypoint.sh /usr/local/bin/profile-entrypoint.sh
RUN chmod +x /usr/local/bin/profile-entrypoint.sh

EXPOSE 8084
ENTRYPOINT ["/usr/local/bin/profile-entrypoint.sh"]
