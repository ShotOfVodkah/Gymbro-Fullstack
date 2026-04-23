# Analytics Service Scaling Design

## Current logical layers

The analytics service is already split by responsibility into three logical layers:

1. **Ingestion layer**
   - receives event batches over HTTP
   - validates and normalizes payloads
   - stores raw, invalid, and accepted events
   - remains lightweight and stateless apart from database writes

2. **Processing layer**
   - claims pending normalized events
   - builds analytical aggregates and rollups
   - updates sessions, funnels, retention, app-version analytics, user summaries, pipeline metrics
   - runs asynchronously in the background

3. **Query layer**
   - serves product analytics endpoints
   - serves admin/debug endpoints
   - should read aggregated tables and materialized views instead of raw event streams whenever possible

---

## Horizontal scaling path

### Ingestion scaling
The ingestion layer is designed to be horizontally scalable:
- HTTP handlers are stateless
- identity is derived from JWT
- deduplication is protected by database constraints and fingerprints

This allows multiple ingestion instances behind a load balancer.

### Processing scaling
The processor is logically independent from ingestion.
Future scaling path:
- run processing as a separate worker deployment
- scale processing workers independently from HTTP ingestion instances
- keep claiming work from the database or move to a queue later

### Query scaling
Query endpoints are separated from the write path.
Future scaling path:
- move read endpoints to dedicated read replicas
- increase use of materialized views and precomputed rollups
- isolate expensive reporting workloads from ingestion and processing

---

## Future async pipeline evolution

Current implementation:
- accepted events are stored in PostgreSQL
- processor claims pending events from the database

Future evolution path:
- replace DB polling with a message broker / async queue
- ingestion publishes normalized accepted events
- processing workers consume asynchronously
- rollup jobs and materialized view refresh jobs remain independent

This design keeps the current code simple while preserving a clear path to production-grade scaling.

---

## Partitioning plan

The main candidate for future partitioning is `analytics_events`.

Recommended future strategy:
- range partition by `event_date`
- monthly partitions
- keep hot recent partitions small and fast
- retain aggregate tables and materialized views as primary query sources

The current query design already supports this direction because most analytical queries are date-bounded and prefer aggregate tables over raw event scans.