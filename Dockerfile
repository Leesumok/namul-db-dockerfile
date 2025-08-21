FROM mongo:7.0

# 환경 변수는 CloudType에서 주입 받기
ENV MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME}
ENV MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
ENV MONGO_INITDB_DATABASE=${MONGO_INITDB_DATABASE}

# init 스크립트 복사
COPY init.js /docker-entrypoint-initdb.d/

# CloudType 보안 정책: non-root 사용자로 실행
USER mongodb

EXPOSE 27017
