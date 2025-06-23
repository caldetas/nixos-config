#!/usr/bin/env bash
set -euo pipefail

echo "Waiting for Immich Postgres container to be healthy..."
RETRY=0
MAX_RETRIES=100
# Wait until the container is healthy (use 'starting' if healthcheck not defined)
while true; do
  STATUS=$(docker inspect --format='{{.State.Health.Status}}' immich_postgres 2>/dev/null || echo "unknown")
  echo "Health status: $STATUS"
  if [ "$STATUS" = "healthy" ]; then
    break
  fi
  RETRY=$((RETRY+1))
  if [ "$RETRY" -ge "$MAX_RETRIES" ]; then
    echo "Timed out waiting for container health"
    exit 1
  fi
  sleep 5
done

echo "Checking if admin user exists..."

if ! docker exec --tty=false immich_postgres \
  psql -U postgres -d immich -tAc "SELECT 1 FROM users WHERE email='admin@qemu.com';" | grep -q 1; then
  echo "Creating admin user..."
  docker exec --tty=false immich_postgres \
    psql -U postgres -d immich -c "INSERT INTO users (
      id,
      email,
      password,
      \"isAdmin\",
      \"createdAt\",
      \"updatedAt\"
    ) VALUES (
      gen_random_uuid(),
      'admin@qemu.com',
      '\$2b\$10\$RXXkKsjYhUZ1c1aIk4F8peA3k.jCh1OHOT2NQiYV3Z2dIA7N2IYX2',
      true,
      now(),
      now()
    );"
else
  echo "Admin user already exists, skipping."
fi
