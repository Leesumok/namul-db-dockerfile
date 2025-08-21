FROM mongo:7.0

# 환경변수 설정 (CloudType에서 주입됨)
ENV MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME}
ENV MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
ENV MONGO_INITDB_DATABASE=${MONGO_INITDB_DATABASE}

# 기존 mongodb 사용자의 UID/GID 변경
RUN usermod -u 1001 mongodb && \
    groupmod -g 1001 mongodb

# 모든 필요한 디렉토리 생성 및 권한 설정
RUN mkdir -p /data/db /data/configdb /var/log/mongodb /var/lib/mongodb && \
    chown -R mongodb:mongodb /data/db /data/configdb /var/log/mongodb /var/lib/mongodb && \
    chmod -R 755 /data/db /data/configdb /var/log/mongodb /var/lib/mongodb

# MongoDB 홈 디렉토리 권한 설정 (entrypoint 스크립트를 위해)
RUN mkdir -p /home/mongodb && \
    chown -R mongodb:mongodb /home/mongodb && \
    chmod 755 /home/mongodb

# 포트 노출
EXPOSE 27017

# non-root 사용자로 변경
USER mongodb

# 헬스체크
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD mongosh --eval "db.adminCommand('ping')" --quiet || exit 1

# 직접 mongod 실행 (entrypoint 스크립트 우회)
CMD ["mongod", "--bind_ip_all", "--port", "27017", "--dbpath", "/data/db", "--logpath", "/var/log/mongodb/mongod.log", "--logappend"]