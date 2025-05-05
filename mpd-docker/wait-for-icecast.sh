#!/bin/bash
set -e

HOST=${ICECAST_HOST:-icecast_server}
PORT=${ICECAST_PORT:-8000}

echo "Waiting for Icecast server on: ${HOST}:${PORT}"

for i in {1..30}; do
  if nc -z "$HOST" "$PORT"; then
    echo "Icecast is ready."
    break
  fi
  echo "Icecast not ready... (${i})"
  sleep 2
done

if ! nc -z "$HOST" "$PORT"; then
  echo "Icecast server not found."
  exit 1
fi

exec "$@"
