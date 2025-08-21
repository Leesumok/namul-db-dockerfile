FROM mongo:7.0

# 환경변수 설정
ENV MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME}
ENV MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
ENV MONGO_INITDB_DATABASE=${MONGO_INITDB_DATABASE}

# 간단한 권한 설정
RUN chown -R 999:999 /data/db
USER 999

# 포트 노출
EXPOSE 27017

# 헬스체크
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD mongosh --eval "db.adminCommand('ping')" --quiet || exit 1

# MongoDB 직접 시작 (복잡한 초기화 스크립트 없이)
CMD ["mongod", "--bind_ip_all", "--port", "27017"]