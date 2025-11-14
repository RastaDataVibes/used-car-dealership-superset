#!/bin/bash
set -e

echo "=== SUPERSET: Starting Init ==="

superset db upgrade

superset fab create-admin \
  --username zaga \
  --firstname zaga \
  --lastname dat \
  --email opiobethle@gmail.com \
  --password zagadat || echo "Admin 'zaga' already exists"

superset init

echo "=== Starting Superset (sync workers) ==="
exec gunicorn \
  --worker-class sync \
  -w 4 \
  -k sync \
  --timeout 120 \
  -b 0.0.0.0:$PORT \
  "superset.app:create_app()"
