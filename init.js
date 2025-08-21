// 기본 DB 선택
db = db.getSiblingDB("admin");

// 예시용 컬렉션 하나 생성
db.createCollection("init");

// 샘플 데이터 삽입
db.init.insertOne({ message: "MongoDB initialized!" });
