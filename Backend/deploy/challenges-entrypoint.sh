#!/usr/bin/env bash
set -e

echo "Waiting for Postgres at ${PGHOST}:${PGPORT:-5432}..."
until nc -z "$PGHOST" "${PGPORT:-5432}"; do
  sleep 1
done

echo "Running challenges migrations..."
goose -dir ./db/migrations postgres "${DATABASE_URL}" up

echo "Starting challengesserver..."
exec challengesserver