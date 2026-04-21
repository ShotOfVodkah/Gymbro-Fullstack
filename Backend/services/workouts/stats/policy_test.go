package stats

import "testing"

func TestConsistencyFromWeekHits(t *testing.T) {
	if g := ConsistencyFromWeekHits(6, 12); g != 50 {
		t.Fatalf("got %d want 50", g)
	}
	if g := ConsistencyFromWeekHits(12, 12); g != 100 {
		t.Fatalf("got %d want 100", g)
	}
	if g := ConsistencyFromWeekHits(0, 12); g != 0 {
		t.Fatalf("got %d want 0", g)
	}
	if g := ConsistencyFromWeekHits(1, 0); g != 0 {
		t.Fatalf("got %d want 0", g)
	}
}

func TestCompletionRateV1(t *testing.T) {
	if CompletionRateV1() != 0 {
		t.Fatal("expected 0")
	}
}
