package db

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
)

// Store defines all functions to execute db queries and transactions
type Store interface {
	Querier
	TransferTx(ctx context.Context, arg TransferTxParams) (TransferTxResult, error)
	CreateUserTx(ctx context.Context, arg CreateUserTxParams) (CreateUserTxResult, error)
}

type SQLStore struct {
	connPool *pgxpool.Pool
	*Queries
}

// NewStore creates a new store
func NewStore(cp *pgxpool.Pool) Store {
	return &SQLStore{
		connPool: cp,
		Queries:  New(cp),
	}
}

func (s SQLStore) execTx(ctx context.Context, fn func(*Queries) error) error {
	tx, err := s.connPool.Begin(ctx)
	if err != nil {
		return err
	}
	q := New(tx)
	err = fn(q)
	if err != nil {
		if rbErr := tx.Rollback(ctx); rbErr != nil {
			return fmt.Errorf("tx error: %v, rb Error: %v", err, rbErr)
		}
		return err
	}

	return tx.Commit(ctx)
}
