#!/usr/bin/env bash
# Генерация пары RSA для dev M2M (DivKit → Workouts). Запускать из этой папки или с любого cwd.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
TMP="$DIR/.tmp_m2m.key"
openssl genrsa -out "$TMP" 2048
openssl pkcs8 -topk8 -nocrypt -in "$TMP" -out "$DIR/bdui_m2m_private_pkcs8.pem"
openssl rsa -in "$TMP" -pubout -out "$DIR/bdui_m2m_public.pem"
rm -f "$TMP"
echo "OK: $DIR/bdui_m2m_{private_pkcs8,public}.pem"
echo "Вставь содержимое bdui_m2m_public.pem в docker-compose.yml → workouts_service → BDUI_M2M_JWT_PUBLIC_KEY_PEM (блок |)."
