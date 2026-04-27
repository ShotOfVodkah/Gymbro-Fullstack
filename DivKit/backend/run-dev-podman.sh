#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PEM="${BDUI_M2M_PRIVATE_PEM:-$REPO_ROOT/Backend/deploy/keys/dev/bdui_m2m_private_pkcs8.pem}"
if [[ ! -f "$PEM" ]]; then
  echo "Нет приватного ключа: $PEM" >&2
  echo "Сгенерируй: (cd $REPO_ROOT/Backend/deploy/keys/dev && ./generate_m2m_keys.sh)" >&2
  echo "и обнови public в docker-compose, если перегенерировал." >&2
  exit 1
fi
export BDUI_M2M_JWT_PRIVATE_KEY_PEM="$(cat "$PEM")"
exec docker run --rm -p 8090:8090 \
  -e JWT_SECRET="${JWT_SECRET:-supersecret_noone_will_get_out}" \
  -e GYMBRO_BACKEND_URL="${GYMBRO_BACKEND_URL:-http://host.docker.internal:8080}" \
  -e BDUI_M2M_JWT_PRIVATE_KEY_PEM \
  divkit-backend
