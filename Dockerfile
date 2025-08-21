FROM mongo:7.0

# 환경변수 설정 (CloudType에서 주입됨)
ENV MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME}
ENV MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
ENV MONGO_INITDB_DATABASE=${MONGO_INITDB_DATABASE}

# CloudType 보안 정책에 맞는 UID/GID 설정
ARG USER_ID=1001
ARG GROUP_ID=1001

RUN groupadd -g ${GROUP_ID} mongodb || groupmod -g ${GROUP_ID} mongodb && \
    useradd -u ${USER_ID} -g ${GROUP_ID} -s /bin/bash -m mongodb || usermod -u ${USER_ID} -g ${GROUP_ID} mongodb

# 필요한 디렉토리 생성 및 권한 설정
RUN mkdir -p /data/db && \
    chown -R mongodb:mongodb /data/db && \
    chmod -R 755 /data/db

# 포트 노출
EXPOSE 27017

# non-root 사용자로 변경
USER mongodb

# 헬스체크
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD mongosh --eval "db.adminCommand('ping')" --quiet || exit 1

# MongoDB 직접 실행 (초기화 스크립트 제거)
CMD ["mongod", "--bind_ip_all", "--auth"]