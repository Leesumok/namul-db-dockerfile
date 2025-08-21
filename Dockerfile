FROM mongo:7.0

# 환경변수 설정 (CloudType에서 주입됨)
ENV MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME}
ENV MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
ENV MONGO_INITDB_DATABASE=${MONGO_INITDB_DATABASE}

# MongoDB 사용자 생성 및 UID/GID 설정 (CloudType 권장)
RUN groupadd -g 1001 mongouser && \
    useradd -u 1001 -g 1001 -m -s /bin/bash mongouser

# 데이터 디렉토리 생성 및 권한 설정
RUN mkdir -p /data/db /data/configdb && \
    chown -R 1001:1001 /data/db /data/configdb && \
    chmod 755 /data/db /data/configdb

# MongoDB 바이너리 권한 설정
RUN chown 1001:1001 /usr/bin/mongod /usr/bin/mongosh

# MongoDB 설정 파일 생성
RUN echo "net:" > /etc/mongod.conf && \
    echo "  port: 27017" >> /etc/mongod.conf && \
    echo "  bindIp: 0.0.0.0" >> /etc/mongod.conf && \
    echo "storage:" >> /etc/mongod.conf && \
    echo "  dbPath: /data/db" >> /etc/mongod.conf && \
    echo "security:" >> /etc/mongod.conf && \
    echo "  authorization: enabled" >> /etc/mongod.conf && \
    chown 1001:1001 /etc/mongod.conf

# non-root 사용자로 변경
USER 1001

# 포트 노출
EXPOSE 27017

# 헬스체크 (non-root 사용자로 실행)
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD mongosh --quiet --eval "db.adminCommand('ping').ok" || exit 1

# MongoDB 시작 (설정 파일 사용)
CMD ["mongod", "--config", "/etc/mongod.conf"]