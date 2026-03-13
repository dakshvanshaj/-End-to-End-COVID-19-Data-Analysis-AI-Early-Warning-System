#!/bin/bash
set -e

# Wait for Postgres
echo "Waiting for Postgres at $DB_HOST:$DB_PORT..."
until python -c "import socket; s = socket.socket(); s.connect(('$DB_HOST', int('$DB_PORT')))" 2>/dev/null; do
  sleep 1
done
echo "Postgres is UP"

# Run the Command
exec "$@"

