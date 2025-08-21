FROM mongo:7.0

# 환경변수 설정 (CloudType에서 주입됨)
ENV MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME}
ENV MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
ENV MONGO_INITDB_DATABASE=${MONGO_INITDB_DATABASE}

# 기존 mongodb 사용자의 UID/GID 변경
RUN usermod -u 1001 mongodb && \
    groupmod -g 1001 mongodb

# 설정 파일과 초기화 스크립트 복사
COPY mongod.conf /etc/mongod.conf
COPY init-mongo.sh /usr/local/bin/init-mongo.sh

# 필요한 디렉토리 생성 및 권한 설정
RUN mkdir -p /data/db /data/configdb /var/log/mongodb /var/run/mongodb && \
    chown -R mongodb:mongodb /data/db /data/configdb /var/log/mongodb /var/run/mongodb && \
    chmod -R 755 /data/db /data/configdb /var/log/mongodb /var/run/mongodb && \
    chown mongodb:mongodb /etc/mongod.conf /usr/local/bin/init-mongo.sh && \
    chmod +x /usr/local/bin/init-mongo.sh

# 포트 노출
EXPOSE 27017

# non-root 사용자로 변경
USER mongodb

# 헬스체크
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD mongosh --eval "db.adminCommand('ping')" --quiet || exit 1

# 초기화 스크립트 실행
CMD ["/usr/local/bin/init-mongo.sh"]