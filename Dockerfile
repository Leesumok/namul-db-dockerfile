FROM mongo:7.0

# 환경변수 설정 (CloudType에서 주입됨)
ENV MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME}
ENV MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
ENV MONGO_INITDB_DATABASE=${MONGO_INITDB_DATABASE}

# CloudType 보안 정책에 맞는 UID/GID 설정
ARG USER_ID=1001
ARG GROUP_ID=1001

# 기존 mongodb 사용자 수정
RUN usermod -u ${USER_ID} mongodb && \
    groupmod -g ${GROUP_ID} mongodb && \
    chown -R mongodb:mongodb /data/db /data/configdb

# 포트 노출
EXPOSE 27017

# non-root 사용자로 변경
USER mongodb

# 헬스체크
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD mongosh --eval "db.adminCommand('ping')" --quiet || exit 1

# MongoDB 기본 엔트리포인트 사용 (환경변수 자동 처리)
CMD ["mongod", "--bind_ip_all"]