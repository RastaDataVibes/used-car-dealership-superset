#!/bin/bash
set -e

echo "=== SUPERSET: Starting Init ==="

# === RUN SUPERSET USING PYTHON MODULE ===
python - <<'PY'
import os
import sys

# Set config path
os.environ['SUPERSET_CONFIG_PATH'] = '/app/superset_config.py'

# Import and run Superset CLI
from superset import app, db
from superset.cli import superset as superset_cli
import click

@click.group()
def cli():
    pass

# Register commands
cli.add_command(superset_cli.db_upgrade, name="db_upgrade")
cli.add_command(superset_cli.init, name="init")

# Run db upgrade
print("Running: superset db upgrade")
cli(["db_upgrade"])

# Run create-admin (skip if exists)
try:
    from superset.cli import fab
    fab.create_admin(
        username="zaga",
        firstname="zaga",
        lastname="dat",
        email="opiobethle@gmail.com",
        password="zagadat"
    )
    print("Created admin user")
except Exception as e:
    if "already exists" in str(e).lower():
        print("Admin 'zaga' already exists")
    else:
        print("Admin error:", e)

# Run init
print("Running: superset init")
cli(["init"])

print("Superset init complete")
PY

# === START GUNICORN USING PYTHON MODULE ===
echo "=== Starting Superset (NO GEVENT) ==="
exec python -m gunicorn \
  --worker-class sync \
  -w 4 \
  -k sync \
  --timeout 300 \
  -b 0.0.0.0:$PORT \
  "superset.app:create_app()"
