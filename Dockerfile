FROM mongo:7.0

# 환경변수 설정 (CloudType에서 주입됨)
ENV MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME}
ENV MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
ENV MONGO_INITDB_DATABASE=${MONGO_INITDB_DATABASE}

# 데이터 디렉토리 권한 설정 (올바른 사용자로 변경)
RUN mkdir -p /data/db && chown -R 999:999 /data/db

# 포트 노출
EXPOSE 27017

# MongoDB 설정 파일 생성
RUN echo "net:" > /etc/mongod.conf && \
    echo "  port: 27017" >> /etc/mongod.conf && \
    echo "  bindIp: 0.0.0.0" >> /etc/mongod.conf && \
    echo "storage:" >> /etc/mongod.conf && \
    echo "  dbPath: /data/db" >> /etc/mongod.conf && \
    echo "security:" >> /etc/mongod.conf && \
    echo "  authorization: enabled" >> /etc/mongod.conf

# 헬스체크 수정 (인증 정보 포함)
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD mongosh --quiet --eval "db.adminCommand('ping').ok" || exit 1