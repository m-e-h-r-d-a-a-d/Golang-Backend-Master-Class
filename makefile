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

sqlc:
	sqlc generate

test:
	go test -v -cover -short ./...

server:
	go run main.go

mock:
	mockgen -package mockdb -destination db/mock/store.go simplebank/db/sqlc Store

.PHONY: network postgres createdb dropdb migrateup migrateup1 migratedown migratedown1 sqlc test server mock