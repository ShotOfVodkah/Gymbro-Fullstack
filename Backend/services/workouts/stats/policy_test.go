package stats

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestConsistencyFromWeekHits(t *testing.T) {
	require.Equal(t, 50, ConsistencyFromWeekHits(6, 12))
	require.Equal(t, 100, ConsistencyFromWeekHits(12, 12))
	require.Equal(t, 0, ConsistencyFromWeekHits(0, 12))
	require.Equal(t, 0, ConsistencyFromWeekHits(1, 0))
}

func TestCompletionRateV1(t *testing.T) {
	require.Equal(t, 0, CompletionRateV1())
}
