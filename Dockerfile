FROM mongo:7.0

# 환경변수 설정 (기본값 제공, 런타임에 오버라이드 가능)
ENV MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME:-admin}
ENV MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD:-password}
ENV MONGO_INITDB_DATABASE=${MONGO_INITDB_DATABASE:-namul}

# 데이터 디렉토리 볼륨 설정
VOLUME ["/data/db"]
# 헬스체크 추가 (MongoDB Shell 7.x 문법 사용)
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=5 \
    CMD mongosh --quiet --eval "db.adminCommand('ping').ok" || exit 1
# 포트 노출
EXPOSE 27017