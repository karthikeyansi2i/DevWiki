-- ============================================
-- 10_articles_sqlperformance.sql
-- 5 articles in the SQL Performance category (CategoryId = 7)
-- ============================================

INSERT INTO "Articles" ("ArticleId", "Title", "Slug", "Summary", "Content", "AuthorId", "CategoryId", "Status", "ViewCount", "CreatedAt", "UpdatedAt")
VALUES
(
  'a0000001-0000-0000-0000-000000000027',
  'Understanding Query Execution Plans',
  'understanding-query-execution-plans',
  'Learn how to read and interpret PostgreSQL query execution plans using EXPLAIN and EXPLAIN ANALYZE, understand node types, cost estimation, and identify performance bottlenecks.',
  $$
## Introduction

Every SQL query executed by PostgreSQL goes through a planner that determines the most efficient way to retrieve the requested data. The query execution plan is the planner's roadmap, detailing every step from scanning tables to joining results. Understanding these plans is the foundational skill for database performance tuning.

## Running EXPLAIN

The `EXPLAIN` command shows the plan without executing the query:

```sql
EXPLAIN SELECT * FROM articles WHERE view_count > 10000;
```

Output shows a tree of plan nodes. For actual execution statistics, use `EXPLAIN ANALYZE`:

```sql
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT a.title, a.view_count, c.name AS category
FROM articles a
JOIN categories c ON c.id = a.category_id
WHERE a.status = 'published'
ORDER BY a.view_count DESC
LIMIT 20;
```

The `BUFFERS` flag shows shared buffer hits, reads, and dirtied pages. `TIMING` adds millisecond durations for each node.

## Reading a Plan

Plans are read from the inside out, bottom to top. Each node shows:

```sql
Limit  (cost=142.50..145.20 rows=20 width=68)
  ->  Sort  (cost=142.50..147.30 rows=1920 width=68)
        Sort Key: a.view_count DESC
        ->  Hash Join  (cost=62.10..102.30 rows=1920 width=68)
              Hash Cond: (a.category_id = c.id)
              ->  Seq Scan on articles a  (cost=0.00..35.40 rows=1920 width=72)
                    Filter: (status = 'published'::text)
              ->  Hash  (cost=35.10..35.10 rows=1910 width=68)
                    ->  Seq Scan on categories c  (cost=0.00..35.10 rows=1910 width=68)
```

Key fields in each node:

| Field | Description |
|---|---|
| `cost` | Start-up cost..total cost in arbitrary units |
| `rows` | Estimated rows returned by this node |
| `width` | Estimated average row width in bytes |
| `actual time` | (ANALYZE only) Real execution time per row |

## Understanding Costs

PostgreSQL's cost model uses arbitrary units based on `seq_page_cost`, `random_page_cost`, `cpu_tuple_cost`, `cpu_index_tuple_cost`, and `cpu_operator_cost`. Default values assume HDD spinning disks. For SSD storage, reduce `random_page_cost`:

```sql
ALTER SYSTEM SET random_page_cost = 1.1;
SELECT pg_reload_conf();
```

The planner picks the plan with the lowest total cost. If actual and estimated rows diverge significantly, stale statistics are the usual culprit.

## Scan Types

PostgreSQL uses several scan strategies:

```sql
-- Sequential scan (full table scan)
EXPLAIN SELECT * FROM articles WHERE title LIKE '%execution%';

-- Index scan (accesses index then heap)
EXPLAIN SELECT * FROM articles WHERE slug = 'understanding-query-execution-plans';

-- Index-only scan (all needed columns in index)
EXPLAIN SELECT slug FROM articles WHERE slug = 'understanding-query-execution-plans';

-- Bitmap scan (combines multiple index results)
EXPLAIN SELECT * FROM articles
WHERE view_count > 1000 AND status = 'published';
```

Comparison of scan types:

| Scan Type | When Used | Performance |
|---|---|---|
| Seq Scan | Large portion of table, no index | Slow on big tables |
| Index Scan | Small row subset, index exists | Fast selective queries |
| Index Only Scan | All columns in index | Fastest, no heap visit |
| Bitmap Heap Scan | Multiple index conditions | Good for moderate selectivity |
| Parallel Seq Scan | Large tables, many CPUs | Best for full-table aggregations |

## Join Strategies

```sql
-- Nested Loop: for small driving relations
EXPLAIN (ANALYZE, BUFFERS)
SELECT a.title, t.name AS tag_name
FROM articles a
JOIN article_tags at ON at.article_id = a.id
JOIN tags t ON t.id = at.tag_id
WHERE a.id = 42;

-- Hash Join: for medium-sized tables
EXPLAIN (ANALYZE, BUFFERS)
SELECT c.name, COUNT(a.id) AS article_count
FROM categories c
LEFT JOIN articles a ON a.category_id = c.id
GROUP BY c.name;

-- Merge Join: for sorted inputs
EXPLAIN (ANALYZE, BUFFERS)
SELECT a.*, c.name
FROM articles a
JOIN categories c ON c.id = a.category_id
ORDER BY a.id, c.id;
```

## Identifying Performance Issues

Common red flags in execution plans:

- **Seq Scan on large tables**: Missing index or query not selective enough
- **High actual vs estimated row mismatch**: Stale statistics, run `ANALYZE`
- **Sort on large result sets**: Missing index on ORDER BY column
- **Filter after scan**: Better to include condition in index
- **Large shared_blks_read**: Data not cached, increase `shared_buffers`

Use this diagnostic query to find recently executed slow queries:

```sql
SELECT query, calls, mean_exec_time, rows, shared_blks_hit,
       shared_blks_read, temp_blks_written
FROM pg_stat_statements
WHERE mean_exec_time > 100
ORDER BY mean_exec_time DESC
LIMIT 10;
```

## Using JSON Format for Machine Parsing

```sql
EXPLAIN (ANALYZE, FORMAT JSON)
SELECT * FROM articles WHERE view_count > 5000;
```

The JSON output is useful for automated plan analysis tools like `pgbadger` or custom monitoring dashboards.

## References

- [PostgreSQL EXPLAIN Documentation](https://www.postgresql.org/docs/current/using-explain.html)
- [Reading Query Plans](https://www.postgresql.org/docs/current/planner-optimizer.html)
- [Cost-Based Optimizer](https://www.postgresql.org/docs/current/runtime-config-query.html)
  $$,
  '11111111-1111-1111-1111-111111111111',
  7,
  1,
  6120,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000028',
  'Indexing Strategies for Performance',
  'indexing-strategies-for-performance',
  'Master PostgreSQL indexing strategies including composite indexes, partial indexes, covering indexes, and index maintenance for optimizing query performance.',
  $$
## Introduction

Indexes are the most powerful tool for improving query performance, but they come with trade-offs. Every index slows down writes, consumes disk space, and adds maintenance overhead. This article covers practical indexing strategies that maximize read performance while minimizing the downsides.

## B-Tree Index Basics

The default B-tree index is suitable for most workloads:

```sql
CREATE INDEX idx_articles_view_count ON articles (view_count DESC);
CREATE INDEX idx_articles_slug ON articles (slug);
```

PostgreSQL automatically uses indexes for equality conditions (`=`), range conditions (`<`, `>`, `BETWEEN`), `IN` clauses, and `ORDER BY`. It can also use them for `LIKE` with a non-wildcard prefix.

## Composite Indexes

A composite index on multiple columns can satisfy complex query patterns:

```sql
CREATE INDEX idx_articles_category_status ON articles (category_id, status, published_at DESC);
```

### Column Order Matters

Place the most selective column first:

```sql
-- Good: category_id is highly selective
CREATE INDEX idx_category_status ON articles (category_id, status);

-- This query uses the index efficiently
SELECT title, published_at
FROM articles
WHERE category_id = 3 AND status = 'published'
ORDER BY published_at DESC;
```

Column order guidelines:

| Position | Column Characteristic | Example |
|---|---|---|
| First | Equality conditions | `category_id`, `status` |
| Second | Range conditions | `published_at`, `view_count` |
| Last | ORDER BY columns | `title`, `slug` |
| INCLUDE | Non-filtered columns | `summary`, `author_id` |

## Partial Indexes

Partial indexes include only rows matching a WHERE predicate, making them smaller and faster:

```sql
-- Index only published articles
CREATE INDEX idx_published_articles
ON articles (category_id, published_at DESC)
WHERE status = 'published';

-- Index only high-view articles
CREATE INDEX idx_popular_articles
ON articles (view_count DESC)
WHERE view_count > 10000;
```

The index size savings can be 50-80% when a large portion of rows are excluded. The query must include the same WHERE condition for the partial index to be used.

## Covering Indexes with INCLUDE

PostgreSQL 11+ supports including non-key columns to enable index-only scans:

```sql
CREATE INDEX idx_articles_listing
ON articles (category_id, status, published_at DESC)
INCLUDE (title, slug, summary);
```

An index-only scan occurs when all required columns exist in the index, avoiding heap visits. Verify with EXPLAIN:

```sql
EXPLAIN SELECT title, slug FROM articles
WHERE category_id = 3 AND status = 'published'
ORDER BY published_at DESC;
-- Look for "Index Only Scan" in the plan
```

## Index Maintenance

Monitor index usage to find unused indexes:

```sql
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch,
  pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan ASC;
```

Rebuild indexes that have become bloated:

```sql
-- Rebuild a single index concurrently
REINDEX INDEX CONCURRENTLY idx_published_articles;

-- Rebuild all indexes on a table
REINDEX TABLE CONCURRENTLY articles;
```

The `CONCURRENTLY` option prevents blocking writes during the rebuild, at the cost of slightly longer execution time.

## Avoiding Common Index Pitfalls

| Pitfall | Impact | Solution |
|---|---|---|
| Over-indexing | Slow writes, bloat | Drop unused indexes |
| Wide indexes | Large storage | Use partial or INCLUDE indexes |
| Functions on indexed columns | Index not used | Use expression indexes |
| VARCHAR(255) on all columns | Index bloat | Use appropriate types |
| Not indexing foreign keys | Slow joins | Index all FK columns |

Indexes on expressions can help when queries use functions:

```sql
CREATE INDEX idx_articles_search ON articles
USING gin (to_tsvector('english', title || ' ' || content));
```

## Measuring Index Impact

Compare query performance with and without an index:

```sql
-- Without index (temporarily)
SET enable_indexscan = off;
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM articles WHERE view_count BETWEEN 5000 AND 10000;

-- With index (reset)
SET enable_indexscan = on;
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM articles WHERE view_count BETWEEN 5000 AND 10000;
```

Compare buffer hits and execution time to quantify the index benefit.

## References

- [PostgreSQL Index Documentation](https://www.postgresql.org/docs/current/indexes.html)
- [Index Maintenance](https://www.postgresql.org/docs/current/sql-reindex.html)
- [Index-Only Scans](https://www.postgresql.org/docs/current/indexes-index-only-scans.html)
  $$,
  '11111111-1111-1111-1111-111111111111',
  7,
  1,
  7450,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000029',
  'Query Optimization Techniques',
  'query-optimization-techniques',
  'Advanced PostgreSQL query optimization techniques including subquery refactoring, join ordering, aggregate optimization, and practical before-and-after performance comparisons.',
  $$
## Introduction

Writing correct SQL is straightforward. Writing fast SQL requires understanding how the planner processes your queries. Small syntactic changes can produce dramatically different execution plans. This article covers proven optimization techniques with measurable performance improvements.

## Rewrite Subqueries with JOINs

Subqueries in WHERE clauses often perform worse than equivalent JOINs:

```sql
-- Slow: correlated subquery
SELECT id, title, view_count
FROM articles a
WHERE view_count > (
  SELECT AVG(view_count) FROM articles WHERE category_id = a.category_id
);

-- Fast: derived table with JOIN
SELECT a.id, a.title, a.view_count
FROM articles a
JOIN (
  SELECT category_id, AVG(view_count) AS avg_views
  FROM articles
  GROUP BY category_id
) cat_avg ON cat_avg.category_id = a.category_id
WHERE a.view_count > cat_avg.avg_views;
```

The JOIN version computes the average once per category instead of once per row.

## Use EXISTS Instead of IN

When checking for existence, `EXISTS` can stop early after finding the first match:

```sql
-- Slower on large datasets
SELECT id, title
FROM articles
WHERE id IN (
  SELECT article_id FROM article_tags WHERE tag_id = 5
);

-- Faster for existence checks
SELECT a.id, a.title
FROM articles a
WHERE EXISTS (
  SELECT 1 FROM article_tags at
  WHERE at.article_id = a.id AND at.tag_id = 5
);
```

Compare performance with a benchmark:

```sql
\timing on
-- Run both queries and compare execution time
```

## Optimize Aggregations

Use indexes to speed up GROUP BY queries:

```sql
-- Create a covering index for aggregation
CREATE INDEX idx_articles_category_views
ON articles (category_id, view_count);

-- Now this aggregation is an index-only scan
SELECT category_id, COUNT(*) AS article_count,
       AVG(view_count) AS avg_views,
       MAX(view_count) AS max_views
FROM articles
WHERE status = 'published'
GROUP BY category_id;
```

Filter rows before aggregation with WHERE instead of HAVING:

```sql
-- Good: filters before aggregation
SELECT category_id, COUNT(*)
FROM articles
WHERE view_count > 0
GROUP BY category_id;

-- Bad: aggregates all rows then filters
SELECT category_id, COUNT(*)
FROM articles
GROUP BY category_id
HAVING COUNT(*) > 0;
```

## Use LATERAL for Complex Operations

LATERAL JOINs allow subqueries to reference columns from preceding tables:

```sql
-- Top 5 articles per category using LATERAL
SELECT c.name AS category, a.title, a.view_count
FROM categories c
CROSS JOIN LATERAL (
  SELECT title, view_count
  FROM articles
  WHERE category_id = c.id AND status = 'published'
  ORDER BY view_count DESC
  LIMIT 5
) a
ORDER BY category, a.view_count DESC;
```

This is more efficient than using ROW_NUMBER and filtering, especially with an index on `(category_id, view_count DESC)`.

## Optimize Pagination

Offset-based pagination degrades as offset increases:

```sql
-- Degrades with large offsets
SELECT id, title, view_count
FROM articles
ORDER BY id
LIMIT 20 OFFSET 100000;

-- Keyset pagination stays fast
SELECT id, title, view_count
FROM articles
WHERE id > 100000
ORDER BY id
LIMIT 20;
```

Keyset pagination requires a unique sort column and is not suitable for arbitrary page jumps, but it performs consistently regardless of page depth.

## Query Rewrite Before-and-After

| Pattern | Before | After | Improvement |
|---|---|---|---|
| Existence | `WHERE id IN (SELECT ...)` | `WHERE EXISTS (SELECT 1 ...)` | Early termination |
| Top-N per group | ROW_NUMBER + filter | LATERAL + LIMIT | Index-driven |
| Aggregation | HAVING filter | WHERE pre-filter | Less data processed |
| Pagination | `LIMIT/OFFSET` | Keyset `WHERE > last` | Constant time |
| Count | `SELECT COUNT(*) FROM table` | Use estimated row count from `pg_class` | Instant |

## Avoid Common Mistakes

```sql
-- Mistake: Wrapping columns in functions prevents index usage
SELECT * FROM articles
WHERE LOWER(title) = 'indexing strategies'; -- Seq Scan

-- Fix: Use an expression index or compare directly
SELECT * FROM articles
WHERE title = 'Indexing Strategies';

-- Mistake: Implicit type conversion
SELECT * FROM articles
WHERE view_count = '5000'; -- Text to int conversion

-- Fix: Explicit type matching
SELECT * FROM articles
WHERE view_count = 5000;
```

## Using Planner Hints (PostgreSQL 16+)

PostgreSQL 16 introduced limited planner hint support via `pg_hint_plan`:

```sql
/*+
HashJoin(a c)
SeqScan(a)
*/
EXPLAIN ANALYZE
SELECT a.title, c.name
FROM articles a
JOIN categories c ON c.id = a.category_id
WHERE a.view_count > 1000;
```

Use hints sparingly — updating statistics and rewriting queries is usually the better approach.

## References

- [PostgreSQL Query Planning](https://www.postgresql.org/docs/current/planner-optimizer.html)
- [PostgreSQL Performance Tips](https://www.postgresql.org/docs/current/performance-tips.html)
- [LATERAL Subqueries](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-LATERAL)
  $$,
  '11111111-1111-1111-1111-111111111111',
  7,
  1,
  5830,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-00000000002a',
  'PostgreSQL Vacuum and Statistics',
  'postgresql-vacuum-and-statistics',
  'A deep dive into PostgreSQL MVCC, vacuum, autovacuum, statistics collection, and bloat management for maintaining production database health and query performance.',
  $$
## Introduction

PostgreSQL's MVCC (Multi-Version Concurrency Control) architecture means that updated or deleted rows are not physically removed immediately. Instead, they leave behind dead tuples that must be reclaimed by the VACUUM process. Without proper vacuuming, databases suffer from bloat, degraded performance, and eventual transaction ID wraparound failures.

## MVCC and Dead Tuples

Every UPDATE in PostgreSQL creates a new tuple version. The old version remains visible to concurrent transactions until they complete:

```sql
-- Check dead tuple statistics
SELECT
  relname,
  n_live_tup,
  n_dead_tup,
  ROUND(n_dead_tup * 100.0 / NULLIF(n_live_tup + n_dead_tup, 0), 2) AS dead_pct,
  last_vacuum,
  last_autovacuum,
  last_analyze,
  last_autoanalyze
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY dead_pct DESC;
```

A dead tuple percentage above 20% indicates that autovacuum is not keeping up with write volume.

## VACUUM vs VACUUM FULL

```sql
-- Standard VACUUM: reclaims space for reuse, does not shrink table
VACUUM articles;

-- VACUUM FULL: reclaims space and returns it to OS (locks table)
VACUUM FULL articles;

-- VACUUM with verbose logging
VACUUM (VERBOSE, ANALYZE) articles;
```

| Operation | Locks | Space Reclamation | Speed | Frequency |
|---|---|---|---|---|
| VACUUM | No blocking | Internal reuse only | Fast | Continuous |
| VACUUM FULL | Exclusive lock | Returns to OS | Very slow | Rare |
| VACUUM FREEZE | No blocking | Marks tuples frozen | Moderate | Periodic |
| VACUUM ANALYZE | No blocking | Reclaims + updates stats | Moderate | Regular |

## Configuring Autovacuum

Autovacuum runs in the background based on thresholds:

```ini
# postgresql.conf
autovacuum = on
autovacuum_max_workers = 4
autovacuum_naptime = 60s
autovacuum_vacuum_threshold = 50
autovacuum_vacuum_scale_factor = 0.2
autovacuum_vacuum_cost_limit = 200
autovacuum_vacuum_cost_delay = 20ms
```

For write-heavy tables, override the per-table settings:

```sql
ALTER TABLE articles SET (
  autovacuum_vacuum_scale_factor = 0.01,
  autovacuum_vacuum_threshold = 100,
  autovacuum_vacuum_cost_limit = 1000
);
```

More aggressive vacuuming reduces bloat at the cost of more I/O and CPU.

## Transaction ID Wraparound

PostgreSQL's transaction IDs are 32-bit. After 2 billion transactions, the ID wraps around. Old tuple versions with frozen XIDs prevent data corruption:

```sql
-- Check wraparound risk
SELECT
  datname,
  age(datfrozenxid) AS age,
  ROUND(100 * age(datfrozenxid) / 2000000000.0, 2) AS wraparound_pct
FROM pg_database
ORDER BY age DESC;

-- Force freeze old tuples
VACUUM (FREEZE, VERBOSE) articles;
```

Set `vacuum_freeze_min_age` and `autovacuum_freeze_max_age` to control freeze frequency. If the database reaches 2 billion transactions, it shuts down and requires single-user mode repair.

## Statistics and ANALYZE

The query planner relies on table statistics to estimate row counts. Stale statistics cause poor plans:

```sql
-- Update statistics for a table
ANALYZE articles;

-- Update with detailed sample size
ALTER TABLE articles SET (n_distinct = 500);

-- Check column statistics
SELECT
  attname,
  n_distinct,
  correlation,
  most_common_vals,
  most_common_freqs,
  histogram_bounds
FROM pg_stats
WHERE tablename = 'articles'
ORDER BY attname;
```

Configure `default_statistics_target` for more detailed statistics:

```sql
ALTER SYSTEM SET default_statistics_target = 500;
SELECT pg_reload_conf();
```

Larger values produce better plans for columns with non-uniform distributions but increase ANALYZE duration.

## Monitoring Bloat

Finding bloated tables and indexes:

```sql
-- Table bloat estimation
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
  pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)
    - pg_relation_size(schemaname||'.'||tablename)) AS index_size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

Use the `pgstattuple` extension for accurate bloat measurement:

```sql
CREATE EXTENSION pgstattuple;

SELECT * FROM pgstattuple('articles');
```

The `dead_tuple_percent` and `free_percent` columns show exact bloat.

## Scheduled Maintenance

Set up a cron job for regular maintenance:

```bash
#!/bin/bash
# Weekly vacuum and analyze
psql -d devwiki -c "
  VACUUM (VERBOSE, ANALYZE) articles;
  VACUUM (VERBOSE, ANALYZE) categories;
  VACUUM (VERBOSE, ANALYZE) tags;
  REINDEX TABLE CONCURRENTLY articles;
"
```

For zero-downtime environments, use `pg_repack` to remove bloat without locks:

```bash
pg_repack --table articles --dbname devwiki
```

## References

- [PostgreSQL VACUUM Documentation](https://www.postgresql.org/docs/current/sql-vacuum.html)
- [Autovacuum Tuning](https://www.postgresql.org/docs/current/routine-vacuuming.html)
- [Transaction ID Wraparound](https://www.postgresql.org/docs/current/routine-vacuuming.html#VACUUM-FOR-WRAPAROUND)
  $$,
  '11111111-1111-1111-1111-111111111111',
  7,
  1,
  5270,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-00000000002b',
  'Common SQL Performance Anti-Patterns',
  'common-sql-performance-anti-patterns',
  'Identify and fix the most common SQL performance anti-patterns including N+1 queries, SELECT *, implicit type conversion, over-indexing, and missing join predicates.',
  $$
## Introduction

Many performance problems in PostgreSQL applications stem from recurring SQL anti-patterns. These mistakes are easy to make, especially when using ORMs like Entity Framework Core or writing quick ad-hoc queries. Recognizing and fixing these patterns is essential for building fast, scalable database applications.

## Anti-Pattern 1: The N+1 Query Problem

The N+1 problem occurs when a query fetches a collection, then loops through each item to fetch related data:

```csharp
// Bad: N+1 queries
var articles = context.Articles.ToList();
foreach (var article in articles)
{
    var category = context.Categories.Find(article.CategoryId);
    Console.WriteLine($"{article.Title} - {category.Name}");
}
```

The fix is eager loading with JOIN:

```csharp
// Good: single query with JOIN
var articles = context.Articles
    .Include(a => a.Category)
    .ToList();
```

In raw SQL:

```sql
-- Bad: individual queries per article
SELECT * FROM categories WHERE id = 1;
SELECT * FROM categories WHERE id = 2;
-- ... repeated N times

-- Good: single query
SELECT a.title, c.name AS category_name
FROM articles a
JOIN categories c ON c.id = a.category_id
WHERE a.status = 'published';
```

## Anti-Pattern 2: SELECT * in Production

Fetching all columns wastes bandwidth, memory, and prevents index-only scans:

```sql
SELECT * FROM articles WHERE category_id = 3;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM articles WHERE category_id = 3;
-- Always heap access required
```

```sql
SELECT id, title, slug FROM articles WHERE category_id = 3;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id, title, slug FROM articles WHERE category_id = 3;
-- Index-only scan possible with covering index
```

The performance impact grows with large TEXT/JSONB columns that store hundreds of kilobytes per row.

## Anti-Pattern 3: Missing WHERE Clauses

Unintentional full table scans:

```sql
-- Dangerous: updates every row
UPDATE articles SET updated_at = NOW();

-- Safe: targeted update
UPDATE articles SET updated_at = NOW()
WHERE id = 42;

-- Accidental full scan
SELECT * FROM articles ORDER BY created_at DESC;

-- Intentional with LIMIT
SELECT * FROM articles ORDER BY created_at DESC LIMIT 20;
```

Always verify that DELETE and UPDATE statements include a WHERE clause, especially in production scripts.

## Anti-Pattern 4: Implicit Type Conversion

PostgreSQL converts types implicitly, but this prevents index usage:

```sql
-- Index on articles.view_count is INT
CREATE INDEX idx_view_count ON articles (view_count);

-- Causes seq scan: comparing INT to TEXT
SELECT * FROM articles WHERE view_count = '5000';

-- Uses index: matching types
SELECT * FROM articles WHERE view_count = 5000;
```

The same issue occurs with date strings:

```sql
-- No index usage
SELECT * FROM articles
WHERE created_at = '2026-07-08';

-- Uses index
SELECT * FROM articles
WHERE created_at = '2026-07-08'::timestamp;
```

## Anti-Pattern 5: Over-Indexing

Too many indexes slow down INSERT, UPDATE, and DELETE operations:

```sql
-- Anti-pattern: 8 separate indexes
CREATE INDEX idx_a1 ON articles (title);
CREATE INDEX idx_a2 ON articles (slug);
CREATE INDEX idx_a3 ON articles (status);
CREATE INDEX idx_a4 ON articles (category_id);
CREATE INDEX idx_a5 ON articles (author_id);
CREATE INDEX idx_a6 ON articles (created_at);
CREATE INDEX idx_a7 ON articles (updated_at);
CREATE INDEX idx_a8 ON articles (view_count);

-- Better: 3 composite indexes covering all access patterns
CREATE INDEX idx_articles_listing
  ON articles (category_id, status, published_at DESC)
  INCLUDE (title, slug);

CREATE INDEX idx_articles_author
  ON articles (author_id, created_at DESC);

CREATE INDEX idx_articles_search
  ON articles USING gin (to_tsvector('english', title || ' ' || content));
```

Audit existing indexes:

```sql
SELECT
  indexrelname AS index_name,
  idx_scan AS times_used,
  pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan ASC;
```

| Index Scans | Verdict | Action |
|---|---|---|
| 0 in 30 days | Unused | Drop |
| 1-100 | Rarely used | Evaluate cost |
| 100-10000 | Active | Keep |
| 10000+ | Hot | Optimize |

## Anti-Pattern 6: Non-SARGable Queries

Search ARGument Able (SARGable) predicates can use indexes. Non-SARGable ones cannot:

```sql
-- Non-SARGable: function on column
SELECT * FROM articles
WHERE EXTRACT(YEAR FROM created_at) = 2026;

-- SARGable: range comparison
SELECT * FROM articles
WHERE created_at >= '2026-01-01' AND created_at < '2027-01-01';

-- Non-SARGable: leading wildcard
SELECT * FROM articles WHERE title LIKE '%indexing%';

-- SARGable: prefix match (if that's what you need)
SELECT * FROM articles WHERE title LIKE 'indexing%';

-- For arbitrary substring search, use full-text search or pg_trgm
CREATE EXTENSION pg_trgm;
CREATE INDEX idx_articles_title_trgm ON articles
  USING gin (title gin_trgm_ops);
```

## Anti-Pattern 7: Not Using EXPLAIN

Deploying queries without understanding their execution plan is guessing:

```bash
# Always check before deploying
EXPLAIN (ANALYZE, BUFFERS) your_query_here;
```

Common findings and fixes:

| EXPLAIN Finding | Root Cause | Fix |
|---|---|---|
| Seq Scan on 1M+ rows | Missing index | Add appropriate index |
| Actual rows >> Estimated rows | Stale statistics | Run ANALYZE |
| Large shared_blks_read | Cold cache / insufficient memory | Increase shared_buffers |
| Temp file writes | work_mem too low | Increase work_mem |
| Filter: expensive_function(col) | Non-SARGable predicate | Use expression index |

## Summary Checklist

Before deploying any query in production, verify:
- No SELECT * usage
- WHERE clause is intentional and correct
- All JOIN predicates use indexed columns
- No implicit type conversions
- EXPLAIN (ANALYZE, BUFFERS) shows acceptable plan
- N+1 queries are eliminated with eager loading
- Index count is appropriate for write volume

## References

- [PostgreSQL Performance Anti-Patterns](https://wiki.postgresql.org/wiki/Performance_anti-patterns)
- [Using EXPLAIN](https://www.postgresql.org/docs/current/using-explain.html)
- [Index Maintenance](https://www.postgresql.org/docs/current/sql-reindex.html)
  $$,
  '11111111-1111-1111-1111-111111111111',
  7,
  1,
  8990,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
);

-- Refresh the sequence for generating future article IDs

-- ============================================
-- TAG MAPPINGS
-- ============================================
-- TAG_MAPPINGS_START
-- [
--   {"articleGuid": "a0000001-0000-0000-0000-000000000027", "tagIds": [9, 16, 15]},
--   {"articleGuid": "a0000001-0000-0000-0000-000000000028", "tagIds": [15, 9, 16]},
--   {"articleGuid": "a0000001-0000-0000-0000-000000000029", "tagIds": [16, 9, 17]},
--   {"articleGuid": "a0000001-0000-0000-0000-00000000002a", "tagIds": [9, 16, 15]},
--   {"articleGuid": "a0000001-0000-0000-0000-00000000002b", "tagIds": [9, 16, 15]}
-- ]
-- TAG_MAPPINGS_END




