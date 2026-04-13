# ---------- build stage ----------
FROM golang:1.25 AS build

WORKDIR /app

COPY pkg/authmw ./pkg/authmw
COPY services/feeds/go.mod services/feeds/go.sum ./services/feeds/
RUN cd services/feeds && go mod download
COPY services/feeds ./services/feeds
RUN cd services/feeds && go build -o /bin/feedserver ./cmd/feedserver
RUN go install github.com/pressly/goose/v3/cmd/goose@latest

# ---------- runtime stage ----------
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates netcat-openbsd && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /bin/feedserver /usr/local/bin/feedserver
COPY --from=build /go/bin/goose /usr/local/bin/goose
COPY services/feeds/db/migrations ./db/migrations
COPY deploy/feeds-entrypoint.sh /usr/local/bin/feeds-entrypoint.sh
RUN chmod +x /usr/local/bin/feeds-entrypoint.sh

EXPOSE 8083
CMD ["/usr/local/bin/feeds-entrypoint.sh"]
