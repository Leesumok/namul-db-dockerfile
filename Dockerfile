FROM mongo:7.0

# 환경 변수 (CloudType에서 env로 세팅 가능)
ENV MONGO_INITDB_ROOT_USERNAME=admin
ENV MONGO_INITDB_ROOT_PASSWORD=secret
ENV MONGO_INITDB_DATABASE=testdb

# init 스크립트 (여기에 넣으면 자동 실행됨)
COPY init.js /docker-entrypoint-initdb.d/

# non-root 권한 맞추기
RUN chown -R 999:999 /data/db
USER 999

EXPOSE 27017
