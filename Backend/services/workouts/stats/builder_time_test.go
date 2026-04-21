package stats

import (
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

func TestStartOfUTCWeekMonday(t *testing.T) {
	tue := time.Date(2026, 4, 21, 15, 30, 0, 0, time.UTC)
	got := startOfUTCWeekMonday(tue)
	want := time.Date(2026, 4, 20, 0, 0, 0, 0, time.UTC)
	require.Equal(t, want, got)
}

func TestWeeklyPointsFromCounts(t *testing.T) {
	counts := [7]int{2, 1, 0, 3, 0, 1, 0}
	pts := weeklyPointsFromCounts(counts)
	require.Len(t, pts, 7)
	require.Equal(t, "M", pts[0].Label)
	require.Equal(t, 3, pts[3].Value)
}

func TestPickMostActiveDayName(t *testing.T) {
	var z [7]int
	require.Equal(t, "", pickMostActiveDayName(z))

	c := [7]int{0, 0, 5, 4, 0, 0, 0}
	require.Equal(t, "Wednesday", pickMostActiveDayName(c))
}
