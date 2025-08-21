FROM mongo:7.0

# 환경변수 설정
ENV MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME:-admin}
ENV MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD:-password}
ENV MONGO_INITDB_DATABASE=${MONGO_INITDB_DATABASE:-namul}

# 데이터 디렉토리 설정
RUN mkdir -p /data/db && chown -R mongodb:mongodb /data/db

# 포트 노출
EXPOSE 27017

# MongoDB 설정 파일 생성 (옵션)
RUN echo "net:" > /etc/mongod.conf && \
    echo "  port: 27017" >> /etc/mongod.conf && \
    echo "  bindIp: 0.0.0.0" >> /etc/mongod.conf

# 헬스체크 추가 (MongoDB Shell 7.x 문법 사용)
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=5 \
    CMD mongosh --quiet --eval "db.adminCommand('ping').ok" || exit 1

# MongoDB 시작 명령어 명시적 지정
CMD ["mongod", "--config", "/etc/mongod.conf"]