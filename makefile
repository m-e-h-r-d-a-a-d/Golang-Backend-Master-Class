DB_URL=postgresql://root:123@localhost:5433/simple_bank?sslmode=disable

network:
	docker network create bank-network

postgress:
	docker run --name postgres16  --network bank-network --restart always -p 5433:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=123 -d postgres:16-alpine

mysql:
	docker run --name mysql8 -p 3306:3306  -e MYSQL_ROOT_PASSWORD=123 -d mysql:8

createdb:
	docker exec -it postgres16 createdb --username=root --owner=root simple_bank

dropdb:
	docker exec -it postgres16 dropdb simple_bank

migrateup:
	migrate -path db/migration -database "$(DB_URL)" -verbose up

migrateup1:
	migrate -path db/migration -database "$(DB_URL)" -verbose up 1

migratedown:
	migrate -path db/migration -database "$(DB_URL)" -verbose down

migratedown1:
	migrate -path db/migration -database "$(DB_URL)" -verbose down 1

db_docs:
	dbdocs build doc/db.dbml

db_schema:
	dbml2sql --postgres -o doc/schema.sql doc/db.dbml

sqlc:
	sqlc generate

test:
	go test -v -cover -short ./...

server:
	go run main.go

mock:
	mockgen -package mockdb -destination db/mock/store.go simplebank/db/sqlc Store

proto:
	rm -f pb/*.go
	protoc --proto_path=proto --go_out=pb --go_opt=paths=source_relative \
	--go-grpc_out=pb --go-grpc_opt=paths=source_relative \
	--grpc-gateway_out=pb --grpc-gateway_opt=paths=source_relative \
	proto/*.proto
	
evans:
	evans --host localhost --port 9090 -r repl

.PHONY: network postgres createdb dropdb migrateup migrateup1 migratedown migratedown1 db_docs db_schema sqlc test server mock proto evansmake