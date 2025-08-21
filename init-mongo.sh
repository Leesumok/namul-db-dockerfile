#!/bin/bash
set -e

echo "Starting MongoDB initialization..."

# 디렉토리 권한 확인 및 생성 (non-root 사용자로 실행)
if [ ! -d "/var/log/mongodb" ]; then
    mkdir -p /var/log/mongodb 2>/dev/null || echo "Log directory already exists"
fi
if [ ! -d "/var/run/mongodb" ]; then
    mkdir -p /var/run/mongodb 2>/dev/null || echo "Run directory already exists"
fi

# MongoDB를 백그라운드에서 시작 (인증 없이)
mongod --config /etc/mongod.conf &
MONGO_PID=$!

# MongoDB가 시작될 때까지 대기
echo "Waiting for MongoDB to start..."
until mongosh --eval "print('MongoDB is ready')" > /dev/null 2>&1; do
  sleep 1
done

# 관리자 사용자 생성 (환경변수가 설정된 경우)
if [ "$MONGO_INITDB_ROOT_USERNAME" ] && [ "$MONGO_INITDB_ROOT_PASSWORD" ]; then
  echo "Creating admin user..."
  mongosh admin --eval "
    db.createUser({
      user: '$MONGO_INITDB_ROOT_USERNAME',
      pwd: '$MONGO_INITDB_ROOT_PASSWORD',
      roles: ['root']
    })
  "
fi

# 데이터베이스 생성 (환경변수가 설정된 경우)
if [ "$MONGO_INITDB_DATABASE" ]; then
  echo "Creating database: $MONGO_INITDB_DATABASE"
  mongosh "$MONGO_INITDB_DATABASE" --eval "db.createCollection('init')"
fi

echo "MongoDB initialization complete!"

# 백그라운드 프로세스 종료
kill $MONGO_PID
wait $MONGO_PID

# 인증이 활성화된 설정으로 MongoDB 재시작
echo "Starting MongoDB with authentication..."
exec mongod --config /etc/mongod.conf --auth