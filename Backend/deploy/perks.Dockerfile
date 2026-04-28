# ---------- build stage ----------
FROM golang:1.25 AS build

WORKDIR /app

COPY pkg/authmw ./pkg/authmw
COPY services/perks/go.mod services/perks/go.sum ./services/perks/
RUN cd services/perks && go mod download

COPY services/perks ./services/perks
RUN cd services/perks && go build -o /bin/perksserver ./cmd/perksserver

RUN go install github.com/pressly/goose/v3/cmd/goose@latest

# ---------- runtime stage ----------
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates netcat-openbsd && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /bin/perksserver /usr/local/bin/perksserver
COPY --from=build /go/bin/goose /usr/local/bin/goose
COPY services/perks/db/migrations ./db/migrations
COPY deploy/perks-entrypoint.sh /usr/local/bin/perks-entrypoint.sh

RUN chmod +x /usr/local/bin/perks-entrypoint.sh

EXPOSE 8087
CMD ["/usr/local/bin/perks-entrypoint.sh"]