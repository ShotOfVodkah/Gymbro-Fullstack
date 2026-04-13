# ---------- build stage ----------
FROM golang:1.25 AS build

WORKDIR /app

COPY pkg/authmw ./pkg/authmw
COPY services/workouts/go.mod services/workouts/go.sum ./services/workouts/
RUN cd services/workouts && go mod download
COPY services/workouts ./services/workouts
RUN cd services/workouts && go build -o /bin/workoutserver ./cmd/workoutserver
RUN go install github.com/pressly/goose/v3/cmd/goose@latest

# ---------- runtime stage ----------
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates netcat-openbsd && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /bin/workoutserver /usr/local/bin/workoutserver
COPY --from=build /go/bin/goose /usr/local/bin/goose
COPY services/workouts/db/migrations ./db/migrations
COPY deploy/workouts-entrypoint.sh /usr/local/bin/workouts-entrypoint.sh
RUN chmod +x /usr/local/bin/workouts-entrypoint.sh

EXPOSE 8082
ENTRYPOINT ["/usr/local/bin/workouts-entrypoint.sh"]
