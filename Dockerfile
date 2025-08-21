FROM mongo:7.0

# 환경변수 설정 (CloudType에서 주입됨)
ENV MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME}
ENV MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
ENV MONGO_INITDB_DATABASE=${MONGO_INITDB_DATABASE}

# 기존 mongodb 사용자의 UID/GID 변경
RUN usermod -u 1001 mongodb && \
    groupmod -g 1001 mongodb

# 데이터 디렉토리 및 하위 디렉토리 모두 생성 및 권한 설정
RUN mkdir -p /data/db /data/configdb /data/db/.mongodb && \
    chown -R mongodb:mongodb /data/db /data/configdb && \
    chmod -R 755 /data/db /data/configdb

# 포트 노출
EXPOSE 27017

# non-root 사용자로 변경
USER mongodb

# 헬스체크 단순화
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD mongosh --eval "db.adminCommand('ping')" --quiet || exit 1

# 단순한 MongoDB 시작 (설정 파일 없이)
CMD ["mongod", "--bind_ip_all", "--port", "27017"]