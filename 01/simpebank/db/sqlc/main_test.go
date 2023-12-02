package db

import (
	"context"
	"log"
	"os"
	"testing"

	"simplebank/util"

	"github.com/jackc/pgx/v5/pgxpool"
)

// const (
// 	dbDriver = "postgres"
// 	dbSource = "postgresql://root:123@localhost:5433/simple_bank?sslmode=disable"
// )

var (
	testQueries *Queries
	connPool    *pgxpool.Pool
)

func TestMain(m *testing.M) {
	config, err := util.LoadConfig("../..")
	if err != nil {
		log.Fatal("cannot load config:", err)
	}

	connPool, err = pgxpool.New(context.Background(), config.DBSource)
	if err != nil {
		log.Fatal("cannot connect to db:", err)
	}

	testQueries = New(connPool)
	os.Exit(m.Run())
}
