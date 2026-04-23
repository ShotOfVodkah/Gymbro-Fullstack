# ---------- build stage ----------
FROM golang:1.25 AS build

WORKDIR /app

COPY pkg/authmw ./pkg/authmw
COPY services/analytics/go.mod services/analytics/go.sum ./services/analytics/
RUN cd services/analytics && go mod download
COPY services/analytics ./services/analytics
RUN cd services/analytics && go build -o /bin/analyticsserver ./cmd/analyticsserver
RUN go install github.com/pressly/goose/v3/cmd/goose@latest

# ---------- runtime stage ----------
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates netcat-openbsd && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /bin/analyticsserver /usr/local/bin/analyticsserver
COPY --from=build /go/bin/goose /usr/local/bin/goose
COPY services/analytics/db/migrations ./db/migrations
COPY deploy/analytics-entrypoint.sh /usr/local/bin/analytics-entrypoint.sh
RUN chmod +x /usr/local/bin/analytics-entrypoint.sh

EXPOSE 8086
CMD ["/usr/local/bin/analytics-entrypoint.sh"]
