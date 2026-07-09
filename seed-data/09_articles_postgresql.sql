-- ============================================
-- 09_articles_postgresql.sql
-- 7 articles in the PostgreSQL category (CategoryId = 6)
-- ============================================

INSERT INTO "Articles" ("ArticleId", "Title", "Slug", "Summary", "Content", "AuthorId", "CategoryId", "Status", "ViewCount", "CreatedAt", "UpdatedAt")
VALUES
(
  'a0000001-0000-0000-0000-000000000020',
  'PostgreSQL Advanced Indexing Strategies',
  'postgresql-advanced-indexing-strategies',
  'Explore PostgreSQL indexing strategies beyond B-tree including GiST, GIN, SP-GiST, BRIN, and partial indexes, with real-world examples and performance analysis.',
  $content$
## Introduction

PostgreSQL offers a rich variety of index types far beyond the standard B-tree. Choosing the right index type for your data and query patterns can dramatically improve query performance while reducing storage overhead. This article covers advanced indexing strategies with practical examples.

## B-Tree Indexes

The default B-tree index works well for equality and range queries:

```sql
CREATE INDEX idx_users_email ON users USING btree (email);
CREATE INDEX idx_articles_published_at ON articles USING btree (published_at DESC);
```

B-tree indexes support `=`, `>`, `<`, `>=`, `<=`, `BETWEEN`, `IN`, `LIKE` (with non-wildcard prefix), and `IS NULL` predicates.

## GiST Indexes

Generalized Search Tree (GiST) indexes support geometric data, full-text search, and range types:

```sql
CREATE INDEX idx_articles_search ON articles USING gist (search_vector);

-- Range type exclusion constraint
CREATE TABLE reservations (
  room_id INT,
  during TSRANGE,
  EXCLUDE USING gist (room_id WITH =, during WITH &&)
);
```

GiST indexes are lossy for some operations but support bitmap heap scans for approximate matching.

## GIN Indexes

Generalized Inverted Indexes (GIN) excel at indexing composite values like arrays, JSONB, and full-text search vectors:

```sql
-- JSONB indexing
CREATE INDEX idx_article_metadata ON articles USING gin (metadata jsonb_path_ops);

-- Array indexing
CREATE INDEX idx_article_tags ON articles USING gin (tags);

-- Full-text search
CREATE INDEX idx_article_fts ON articles USING gin (to_tsvector('english', title || ' ' || content));
```

GIN indexes trade slower writes for fast reads. Use `gin_fuzzy_search_limit` to cap result set size during development.

## BRIN Indexes

Block Range INdexes (BRIN) are ideal for large tables with naturally clustered, monotonically increasing columns:

```sql
CREATE INDEX idx_logs_created_at ON access_logs USING brin (created_at)
WITH (pages_per_range = 32);

CREATE INDEX idx_orders_created_at ON orders USING brin (created_at)
WITH (pages_per_range = 16);
```

BRIN indexes are 100-1000x smaller than equivalent B-tree indexes on large tables, making them perfect for append-only tables like audit logs or time-series data.

## Partial Indexes

Partial indexes only include rows matching a WHERE predicate, reducing index size and maintenance overhead:

```sql
CREATE INDEX idx_active_users ON users (email)
WHERE is_active = TRUE;

CREATE INDEX idx_published_articles ON articles (published_at DESC)
WHERE status = 'published';
```

Partial indexes are valuable when queries consistently filter on a static condition.

## Covering Indexes

Include non-key columns to enable index-only scans:

```sql
CREATE INDEX idx_articles_listing ON articles (category_id, published_at DESC)
INCLUDE (title, slug, summary);
```

PostgreSQL 11+ supports the `INCLUDE` clause, allowing the index to satisfy queries without visiting the heap.

## Indexing Strategy Comparison

| Index Type | Best For | Write Overhead | Storage Size |
|---|---|---|---|
| B-tree | Equality, range queries | Low | Moderate |
| GiST | Full-text, geometry, ranges | Moderate | Large |
| GIN | JSONB, arrays, FTS | High | Very Large |
| BRIN | Large clustered tables | Very Low | Tiny |
| Hash | Equality lookups only | Low | Small |
| SP-GiST | Point clouds, network data | Moderate | Moderate |

## Managing Indexes

Monitor index usage to find unused or redundant indexes:

```sql
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan ASC;
```

Rebuild indexes to reclaim space:

```sql
REINDEX INDEX CONCURRENTLY idx_articles_listing;
REINDEX TABLE CONCURRENTLY articles;
```

## References

- [PostgreSQL Index Types Documentation](https://www.postgresql.org/docs/current/indexes-types.html)
- [BRIN Indexes in PostgreSQL](https://www.postgresql.org/docs/current/brin-intro.html)
- [Index Maintenance](https://www.postgresql.org/docs/current/sql-reindex.html)
  $content$,
  '11111111-1111-1111-1111-111111111111',
  6,
  1,
  8930,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000021',
  'Full-Text Search in PostgreSQL',
  'full-text-search-in-postgresql',
  'Master PostgreSQL full-text search with tsvector, tsquery, GIN indexes, ranking, stemming, and dictionary configuration for building search engines.',
  $content$
## Introduction

PostgreSQL provides a built-in full-text search engine that rivals dedicated search tools for many applications. Using tsvector and tsquery types combined with GIN indexes, you can implement fast, linguistically-aware search without external dependencies.

## Understanding tsvector and tsquery

Full-text search in PostgreSQL revolves around two data types:

```sql
-- tsvector: normalized document representation
SELECT to_tsvector('english', 'The quick brown fox jumps over the lazy dog');
-- Result: 'brown':3 'dog':9 'fox':4 'jump':5 'lazi':8 'quick':2

-- tsquery: search query representation
SELECT to_tsquery('english', 'quick & fox');
-- Result: 'quick' & 'fox'
```

The `to_tsvector` function tokenizes text, reduces words to lexemes (stemming), removes stop words, and records positional information.

## Creating a Search Table

Design a table optimized for full-text search:

```sql
CREATE TABLE articles (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  summary TEXT,
  search_vector tsvector GENERATED ALWAYS AS (
    to_tsvector('english', coalesce(title, '') || ' ' || coalesce(content, ''))
  ) STORED
);

CREATE INDEX idx_articles_fts ON articles USING gin (search_vector);
```

Using a generated column ensures the search vector stays synchronized with the source data automatically.

## Querying with Full-Text Search

The `@@` operator matches a tsvector against a tsquery:

```sql
-- Basic search
SELECT id, title
FROM articles
WHERE search_vector @@ to_tsquery('english', 'database & performance');

-- With ranking
SELECT id, title,
  ts_rank(search_vector, to_tsquery('english', 'database & performance')) AS rank
FROM articles
WHERE search_vector @@ to_tsquery('english', 'database & performance')
ORDER BY rank DESC;

-- With headline generation
SELECT id, title,
  ts_headline('english', content, to_tsquery('english', 'database & performance'),
    'StartSel=<mark>, StopSel=</mark>, MaxWords=50, MinWords=20') AS headline
FROM articles
WHERE search_vector @@ to_tsquery('english', 'database & performance')
ORDER BY rank DESC
LIMIT 20;
```

## Search Operators

| Operator | Description | Example |
|---|---|---|
| `&` | AND | `'cat & dog'` matches both |
| `\|` | OR | `'cat \| dog'` matches either |
| `!` | NOT | `'cat & !dog'` matches cat without dog |
| `<->` | Phrase (followed by) | `'quick <-> fox'` exact phrase |
| `<N>` | Distance (within N words) | `'quick <2> fox'` within 2 words |

Phrase search with distance operators:

```sql
-- Find articles where "database" appears within 3 words of "indexing"
SELECT id, title
FROM articles
WHERE search_vector @@ phraseto_tsquery('english', 'database indexing');
```

## Dictionary Configuration

PostgreSQL supports custom text search configurations with different dictionaries:

```sql
-- Create a custom configuration
CREATE TEXT SEARCH CONFIGURATION my_english (COPY = english);

-- Add a synonym dictionary
CREATE TEXT SEARCH DICTIONARY my_synonyms (
  TEMPLATE = synonym,
  SYNONYMS = my_synonyms
);

ALTER TEXT SEARCH CONFIGURATION my_english
  ALTER MAPPING FOR word, asciiword
  WITH my_synonyms, english_stem;
```

Common built-in dictionaries include `english_stem`, `simple`, `ispell`, `synonym`, and `thesaurus`.

## Weighted Search

Assign different weights to different fields:

```sql
ALTER TABLE articles ADD COLUMN search_vector_weighted tsvector;

CREATE OR REPLACE FUNCTION articles_search_update() RETURNS trigger AS $$
BEGIN
  NEW.search_vector_weighted :=
    setweight(to_tsvector('english', coalesce(NEW.title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.summary, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(NEW.content, '')), 'C');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_articles_search
  BEFORE INSERT OR UPDATE ON articles
  FOR EACH ROW EXECUTE FUNCTION articles_search_update();
```

Weights (A, B, C, D) allow ranking to prioritize title matches over body matches.

## Performance Optimization

```sql
-- Analyze search query patterns
SELECT query, calls, total_time / calls AS avg_time_ms
FROM pg_stat_statements
WHERE query ILIKE '%to_tsquery%'
ORDER BY avg_time_ms DESC;

-- Use websearch_to_tsquery for end-user search
SELECT websearch_to_tsquery('english', '"postgresql indexing" performance tips');
-- Handles quoted phrases, OR, and minus operators automatically
```

## References

- [PostgreSQL Full-Text Search Documentation](https://www.postgresql.org/docs/current/textsearch.html)
- [Text Search Dictionary Configuration](https://www.postgresql.org/docs/current/textsearch-dictionaries.html)
- [Controlling Full-Text Search](https://www.postgresql.org/docs/current/textsearch-controls.html)
  $content$,
  '11111111-1111-1111-1111-111111111111',
  6,
  1,
  7620,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000022',
  'PostgreSQL Window Functions',
  'postgresql-window-functions',
  'Learn PostgreSQL window functions including ROW_NUMBER, RANK, LEAD, LAG, NTILE, and aggregate windows with practical analytical query examples.',
  $content$
## Introduction

Window functions perform calculations across a set of rows related to the current row without collapsing them into a single output row. This makes them indispensable for analytical queries, rankings, moving averages, and comparative analysis.

## Window Function Syntax

The basic syntax uses an `OVER` clause to define the window frame:

```sql
SELECT
  id,
  title,
  view_count,
  AVG(view_count) OVER () AS avg_views,
  view_count - AVG(view_count) OVER () AS deviation_from_avg
FROM articles;
```

The `OVER` clause can specify `PARTITION BY`, `ORDER BY`, and frame boundaries.

## Ranking Functions

Ranking functions assign a position to each row within a partition:

```sql
SELECT
  id,
  title,
  category_id,
  view_count,
  ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY view_count DESC) AS row_num,
  RANK() OVER (PARTITION BY category_id ORDER BY view_count DESC) AS rank,
  DENSE_RANK() OVER (PARTITION BY category_id ORDER BY view_count DESC) AS dense_rank,
  NTILE(4) OVER (PARTITION BY category_id ORDER BY view_count DESC) AS quartile
FROM articles;
```

| Function | Ties Handling | Gaps | Use Case |
|---|---|---|---|
| `ROW_NUMBER` | Arbitrary assignment | No | Pagination, deduplication |
| `RANK` | Same value = same rank | Yes | Competition rankings |
| `DENSE_RANK` | Same value = same rank | No | Dense leaderboards |
| `NTILE(n)` | Even bucket distribution | N/A | Percentile analysis |

## Value Window Functions

Access values from other rows within the partition:

```sql
SELECT
  id,
  title,
  published_at,
  view_count,
  LAG(view_count, 1, 0) OVER (ORDER BY published_at) AS prev_article_views,
  LEAD(view_count, 1, 0) OVER (ORDER BY published_at) AS next_article_views,
  FIRST_VALUE(title) OVER (ORDER BY view_count DESC) AS most_viewed_title,
  LAST_VALUE(title) OVER (
    ORDER BY view_count DESC
    RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS least_viewed_title
FROM articles
WHERE status = 'published';
```

`LAG` and `LEAD` accept an offset (default 1) and a default value for out-of-bounds rows.

## Aggregate Window Functions

Use aggregate functions as window functions for running totals and moving averages:

```sql
SELECT
  id,
  title,
  published_at,
  view_count,
  SUM(view_count) OVER (ORDER BY published_at) AS running_total_views,
  AVG(view_count) OVER (
    ORDER BY published_at
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ) AS seven_day_moving_avg,
  MAX(view_count) OVER () AS max_views_ever,
  COUNT(*) OVER (PARTITION BY category_id) AS articles_in_category
FROM articles
WHERE status = 'published';
```

## Frame Specifications

The frame clause defines which rows the window function considers:

| Frame Spec | Description |
|---|---|
| `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` | All rows from partition start to current |
| `ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING` | Current row plus 3 before and after |
| `RANGE BETWEEN INTERVAL '7' DAY PRECEDING AND CURRENT ROW` | Time-based range |
| `ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING` | Current row to partition end |

`RANGE` differs from `ROWS` by treating peers (rows with same ORDER BY value) as a group.

## Practical Examples

Finding the top article per category:

```sql
WITH ranked_articles AS (
  SELECT
    id, title, category_id, view_count,
    ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY view_count DESC) AS rn
  FROM articles
  WHERE status = 'published'
)
SELECT id, title, category_id, view_count
FROM ranked_articles
WHERE rn <= 3
ORDER BY category_id, rn;
```

Calculating month-over-month growth:

```sql
SELECT
  DATE_TRUNC('month', published_at) AS month,
  COUNT(*) AS articles_published,
  LAG(COUNT(*), 1, 0) OVER (ORDER BY DATE_TRUNC('month', published_at)) AS prev_month,
  ROUND(
    (COUNT(*) - LAG(COUNT(*), 1, 0) OVER (ORDER BY DATE_TRUNC('month', published_at)))
    * 100.0 / NULLIF(LAG(COUNT(*), 1, 0) OVER (ORDER BY DATE_TRUNC('month', published_at)), 0),
    2
  ) AS growth_percent
FROM articles
GROUP BY month
ORDER BY month;
```

## References

- [PostgreSQL Window Functions Documentation](https://www.postgresql.org/docs/current/tutorial-window.html)
- [Window Function Syntax](https://www.postgresql.org/docs/current/sql-expressions.html#SYNTAX-WINDOW-FUNCTIONS)
- [Window Function Frame Clause](https://www.postgresql.org/docs/current/sql-expressions.html#SYNTAX-WINDOW-FRAMES)
  $content$,
  '11111111-1111-1111-1111-111111111111',
  6,
  1,
  6780,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000023',
  'PostgreSQL CTEs and Recursive Queries',
  'postgresql-ctes-and-recursive-queries',
  'Explore Common Table Expressions (CTEs) and recursive queries in PostgreSQL for hierarchical data, graph traversal, and readable complex query decomposition.',
  $content$
## Introduction

Common Table Expressions (CTEs) defined with the `WITH` clause provide a way to write auxiliary statements for use in larger queries. Recursive CTEs extend this capability to traverse hierarchical or graph-structured data, making PostgreSQL a powerful tool for tree and graph queries.

## Basic CTEs

CTEs improve query readability and enable result reuse within a single query:

```sql
WITH popular_categories AS (
  SELECT
    category_id,
    COUNT(*) AS article_count,
    AVG(view_count) AS avg_views
  FROM articles
  WHERE status = 'published'
  GROUP BY category_id
  HAVING COUNT(*) > 5
)
SELECT
  c.name AS category,
  pc.article_count,
  ROUND(pc.avg_views, 0) AS avg_views
FROM popular_categories pc
JOIN categories c ON c.id = pc.category_id
ORDER BY pc.article_count DESC;
```

CTEs are materialized by default in PostgreSQL 12 and earlier, acting as optimization fences. PostgreSQL 12+ inlines CTEs when they are referenced only once and have no side effects.

## Chaining CTEs

Multiple CTEs can reference each other sequentially:

```sql
WITH
recent_articles AS (
  SELECT id, title, category_id, view_count, published_at
  FROM articles
  WHERE published_at >= NOW() - INTERVAL '30 days'
),
category_stats AS (
  SELECT
    category_id,
    COUNT(*) AS recent_count,
    SUM(view_count) AS recent_views
  FROM recent_articles
  GROUP BY category_id
),
top_categories AS (
  SELECT category_id, recent_count, recent_views,
    RANK() OVER (ORDER BY recent_views DESC) AS rank
  FROM category_stats
  LIMIT 5
)
SELECT c.name, tc.recent_count, tc.recent_views
FROM top_categories tc
JOIN categories c ON c.id = tc.category_id
ORDER BY tc.rank;
```

## Recursive CTEs

Recursive CTEs consist of a non-recursive base term and a recursive term joined by `UNION ALL`:

```sql
WITH RECURSIVE category_tree AS (
  -- Base case: top-level categories
  SELECT
    id,
    name,
    parent_id,
    1 AS level,
    name::TEXT AS path
  FROM categories
  WHERE parent_id IS NULL

  UNION ALL

  -- Recursive case: child categories
  SELECT
    c.id,
    c.name,
    c.parent_id,
    ct.level + 1,
    ct.path || ' > ' || c.name
  FROM categories c
  JOIN category_tree ct ON c.parent_id = ct.id
)
SELECT id, name, level, path
FROM category_tree
ORDER BY path;
```

## Traversing Hierarchical Data

Employee organizational chart:

```sql
CREATE TABLE employees (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  manager_id INT REFERENCES employees(id),
  role TEXT NOT NULL
);

WITH RECURSIVE org_chart AS (
  SELECT id, name, manager_id, role, 1 AS depth, name::TEXT AS tree_path
  FROM employees
  WHERE manager_id IS NULL

  UNION ALL

  SELECT e.id, e.name, e.manager_id, e.role,
    oc.depth + 1,
    oc.tree_path || ' -> ' || e.name
  FROM employees e
  JOIN org_chart oc ON e.manager_id = oc.id
)
SELECT * FROM org_chart
ORDER BY tree_path;
```

## Graph Traversal with Cycle Detection

Prevent infinite loops from cyclic data using a cycle detection column:

```sql
WITH RECURSIVE related_articles AS (
  SELECT
    a.id AS root_id,
    a.id,
    a.title,
    ARRAY[a.id] AS visited_ids,
    1 AS depth
  FROM articles a
  WHERE a.id = 42

  UNION ALL

  SELECT
    ra.root_id,
    a.id,
    a.title,
    ra.visited_ids || a.id,
    ra.depth + 1
  FROM related_articles ra
  JOIN article_links al ON al.source_id = ra.id
  JOIN articles a ON a.id = al.target_id
  WHERE
    ra.depth < 10 AND
    NOT (a.id = ANY(ra.visited_ids))
)
SELECT DISTINCT ON (id) id, title, depth
FROM related_articles
WHERE id != 42
ORDER BY id, depth;
```

## CTE Modifiers

PostgreSQL supports several CTE modifiers for data modification operations:

```sql
WITH updated_articles AS (
  UPDATE articles
  SET view_count = view_count + 1
  WHERE id = 42
  RETURNING id, title, view_count
)
SELECT * FROM updated_articles;

-- Delete with archive
WITH deleted_articles AS (
  DELETE FROM articles
  WHERE published_at < '2020-01-01'
  RETURNING *
)
INSERT INTO articles_archive
SELECT * FROM deleted_articles;
```

## Performance Considerations

| Aspect | CTE | Subquery | Temporary Table |
|---|---|---|---|
| Readability | High | Moderate | Low |
| Reusability | Single query | Single query | Session scope |
| Materialization | Default (can inline) | Automatic | Explicit |
| Optimization fence | Yes (can be bypassed) | No | No |
| Index usage | Depends on plan | Full | Can be indexed |

Use `WITH` clause with `NOT MATERIALIZED` to force inlining when the CTE is referenced once:

```sql
WITH popular_articles AS NOT MATERIALIZED (
  SELECT * FROM articles WHERE view_count > 10000
)
SELECT * FROM popular_articles
ORDER BY published_at DESC;
```

## References

- [PostgreSQL CTE Documentation](https://www.postgresql.org/docs/current/queries-with.html)
- [Recursive Queries in PostgreSQL](https://www.postgresql.org/docs/current/queries-with.html#QUERIES-WITH-RECURSIVE)
- [CTE Optimization in PostgreSQL](https://www.postgresql.org/docs/current/queries-with.html#QUERIES-WITH-MODIFYING)
  $content$,
  '11111111-1111-1111-1111-111111111111',
  6,
  1,
  5290,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000025',
  'PostgreSQL JSON and JSONB Operations',
  'postgresql-json-and-jsonb-operations',
  'Master PostgreSQL JSON and JSONB data types with operators, indexing, querying, and performance strategies for flexible schema and document storage.',
  $content$
## Introduction

PostgreSQL offers two JSON data types: JSON (stored as text with full whitespace preservation) and JSONB (stored in a decomposed binary format). JSONB supports indexing and is generally preferred for performance-sensitive applications where key ordering and whitespace are not important.

## JSON vs JSONB

| Feature | JSON | JSONB |
|---|---|---|
| Storage | Exact text copy | Decomposed binary |
| Input speed | Fast (no parsing overhead) | Slower (parses and normalizes) |
| Query speed | Slower (re-parses on access) | Fast (direct key lookup) |
| Indexing | No GIN support | Full GIN index support |
| Key order | Preserved | Not preserved |
| Duplicate keys | All kept | Last value wins |
| Whitespace | Preserved | Removed |

## Creating JSONB Data

Insert and build JSONB values:

```sql
CREATE TABLE articles (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);

INSERT INTO articles (title, metadata) VALUES
(
  'PostgreSQL JSON Guide',
  jsonb_build_object(
    'author', 'Jane Doe',
    'tags', jsonb_build_array('postgresql', 'json', 'database'),
    'difficulty', 'intermediate',
    'word_count', 2500,
    'published', true,
    'ratings', jsonb_build_object(
      'average', 4.7,
      'count', 128
    )
  )
);
```

## Querying JSONB with Operators

PostgreSQL provides a rich set of JSONB operators:

```sql
-- Basic access
SELECT
  title,
  metadata->>'author' AS author,
  metadata->'tags' AS tags,
  metadata->'ratings'->>'average' AS avg_rating
FROM articles;

-- Existence check (? operator)
SELECT title FROM articles
WHERE metadata ? 'difficulty';

-- Key/value match
SELECT title FROM articles
WHERE metadata->>'author' = 'Jane Doe';

-- Path existence
SELECT title FROM articles
WHERE metadata @> '{"published": true}';
```

## JSONB Operator Reference

| Operator | Description | Example |
|---|---|---|
| `->` | Access JSON field (returns JSON) | `data->'name'` |
| `->>` | Access JSON field as text | `data->>'name'` |
| `#>` | Path access (returns JSON) | `data#>'{a,b}'` |
| `#>>` | Path access (returns text) | `data#>>'{a,b}'` |
| `@>` | Contains (left contains right) | `data @> '{"x":1}'` |
| `<@` | Is contained by | `'{"x":1}' <@ data` |
| `?` | Key exists | `data ? 'name'` |
| `?\|` | Any key exists | `data ?\| ARRAY['a','b']` |
| `?&` | All keys exist | `data ?& ARRAY['a','b']` |
| `\|\|` | Concatenate | `data1 \|\| data2` |
| `-` | Remove key | `data - 'key'` |

## Indexing JSONB

GIN indexes make JSONB queries fast:

```sql
-- Default GIN index (supports ?, ?|, ?&, @>)
CREATE INDEX idx_metadata_gin ON articles USING gin (metadata);

-- jsonb_path_ops (smaller, faster for @> but slower for ?)
CREATE INDEX idx_metadata_ops ON articles USING gin (metadata jsonb_path_ops);

-- B-tree index on extracted value
CREATE INDEX idx_metadata_author ON articles USING btree ((metadata->>'author'));
```

The `jsonb_path_ops` operator class creates a smaller index (about 40% less) and performs better for `@>` queries at the cost of reduced operator support.

## Advanced JSONB Queries

Filtering and transforming JSONB data:

```sql
-- Find articles with specific tag
SELECT title, metadata->>'difficulty' AS difficulty
FROM articles
WHERE metadata @> '{"tags": ["postgresql"]}';

-- Update nested value
UPDATE articles
SET metadata = jsonb_set(
  metadata,
  '{ratings,average}',
  '4.8'::jsonb
)
WHERE id = 1;

-- Remove a key
UPDATE articles
SET metadata = metadata - 'temporary_field';

-- Aggregate JSONB
SELECT
  jsonb_object_agg(
    metadata->>'difficulty',
    COUNT(*)
  ) AS difficulty_distribution
FROM articles;
```

## JSONB Path Queries (PostgreSQL 12+)

SQL/JSON path expressions enable complex query patterns:

```sql
-- Articles with average rating >= 4.5
SELECT title, metadata
FROM articles
WHERE metadata @? '$.ratings.average ? (@ >= 4.5)';

-- Articles with at least 2 tags
SELECT title
FROM articles
WHERE metadata @@ '$.tags.size() >= 2';

-- Transform and extract
SELECT
  title,
  jsonb_path_query(metadata, '$.tags[*]')::TEXT AS individual_tags
FROM articles;
```

## Performance Tips

- Prefer JSONB over JSON for all new development
- Use `jsonb_path_ops` for GIN indexes when queries primarily use `@>`
- Create B-tree indexes on frequently filtered extracted fields
- Avoid storing large JSONB blobs — extract frequently accessed fields into regular columns
- Use `jsonb_strip_nulls` to reduce storage before inserts

## References

- [PostgreSQL JSON Functions and Operators](https://www.postgresql.org/docs/current/functions-json.html)
- [JSON Indexing in PostgreSQL](https://www.postgresql.org/docs/current/datatype-json.html#INDEXES-JSONB)
- [SQL/JSON Path Expressions](https://www.postgresql.org/docs/current/functions-json.html#FUNCTIONS-SQLJSON-PATH)
  $content$,
  '11111111-1111-1111-1111-111111111111',
  6,
  1,
  7150,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000026',
  'PostgreSQL Table Partitioning Strategies',
  'postgresql-table-partitioning-strategies',
  'Learn PostgreSQL table partitioning with range, list, and hash partitioning strategies, including partition pruning, maintenance, and performance optimization for large datasets.',
  $content$
## Introduction

Table partitioning divides large tables into smaller, more manageable pieces while maintaining a single logical view. PostgreSQL supports declarative partitioning (introduced in PostgreSQL 10) with range, list, and hash strategies. Proper partitioning improves query performance through partition pruning and simplifies data lifecycle management.

## Partitioning Strategies

PostgreSQL offers three built-in partitioning methods:

| Method | Description | Best For |
|---|---|---|
| Range | Partition by contiguous key ranges | Time-series, sequential IDs |
| List | Partition by discrete key values | Regional data, categories |
| Hash | Partition by hash of key values | Even distribution, sharding |

## Range Partitioning

Range partitioning is the most common strategy, ideal for time-based data:

```sql
CREATE TABLE article_views (
  article_id INT NOT NULL,
  viewed_at TIMESTAMPTZ NOT NULL,
  viewer_ip INET NOT NULL,
  user_agent TEXT
) PARTITION BY RANGE (viewed_at);

CREATE TABLE article_views_2024_q1 PARTITION OF article_views
  FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

CREATE TABLE article_views_2024_q2 PARTITION OF article_views
  FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');

CREATE TABLE article_views_2024_q3 PARTITION OF article_views
  FOR VALUES FROM ('2024-07-01') TO ('2024-10-01');

CREATE TABLE article_views_2024_q4 PARTITION OF article_views
  FOR VALUES FROM ('2024-10-01') TO ('2025-01-01');

CREATE TABLE article_views_future PARTITION OF article_views
  FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
```

## List Partitioning

List partitioning groups rows by discrete values:

```sql
CREATE TABLE user_data (
  user_id SERIAL,
  username TEXT NOT NULL,
  region TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
) PARTITION BY LIST (region);

CREATE TABLE user_data_na PARTITION OF user_data
  FOR VALUES IN ('US', 'CA', 'MX');

CREATE TABLE user_data_eu PARTITION OF user_data
  FOR VALUES IN ('GB', 'DE', 'FR', 'IT', 'ES');

CREATE TABLE user_data_apac PARTITION OF user_data
  FOR VALUES IN ('JP', 'KR', 'AU', 'SG', 'IN');

CREATE TABLE user_data_other PARTITION OF user_data
  DEFAULT;
```

The `DEFAULT` partition captures values not explicitly mapped to a list partition.

## Hash Partitioning

Hash partitioning distributes rows evenly across partitions:

```sql
CREATE TABLE audit_logs (
  id SERIAL,
  entity_type TEXT NOT NULL,
  entity_id INT NOT NULL,
  action TEXT NOT NULL,
  performed_at TIMESTAMPTZ DEFAULT NOW()
) PARTITION BY HASH (entity_id);

CREATE TABLE audit_logs_p0 PARTITION OF audit_logs
  FOR VALUES WITH (MODULUS 4, REMAINDER 0);

CREATE TABLE audit_logs_p1 PARTITION OF audit_logs
  FOR VALUES WITH (MODULUS 4, REMAINDER 1);

CREATE TABLE audit_logs_p2 PARTITION OF audit_logs
  FOR VALUES WITH (MODULUS 4, REMAINDER 2);

CREATE TABLE audit_logs_p3 PARTITION OF audit_logs
  FOR VALUES WITH (MODULUS 4, REMAINDER 3);
```

Choose the modulus based on your expected data volume and server capacity.

## Partition Pruning

PostgreSQL automatically excludes partitions that do not match the query's WHERE clause:

```sql
-- This query only scans article_views_2024_q2 and article_views_2024_q3
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*), DATE_TRUNC('day', viewed_at) AS day
FROM article_views
WHERE viewed_at >= '2024-05-01' AND viewed_at < '2024-08-01'
GROUP BY day
ORDER BY day;

-- Verify partition pruning with
EXPLAIN (ANALYZE, TIMING)
SELECT * FROM article_views
WHERE viewed_at = '2024-06-15';
```

Enable `enable_partition_pruning = on` (default) in postgresql.conf.

## Partition Maintenance

Add new partitions and detach old ones without downtime:

```sql
-- Add a new partition for the upcoming quarter
CREATE TABLE article_views_2025_q1 PARTITION OF article_views
  FOR VALUES FROM ('2025-01-01') TO ('2025-04-01');

-- Detach an old partition for archiving
ALTER TABLE article_views DETACH PARTITION article_views_2024_q1;

-- The detached table remains accessible as a standalone table
-- Archive it or move to a different tablespace
ALTER TABLE article_views_2024_q1 SET TABLESPACE archive_tablespace;

-- Attach a pre-existing table as a partition
ALTER TABLE article_views ATTACH PARTITION article_views_2025_q2
  FOR VALUES FROM ('2025-04-01') TO ('2025-07-01');
```

## Sub-partitioning

Create partitions of partitions for multi-dimensional splitting:

```sql
CREATE TABLE metrics (
  metric_id INT,
  recorded_at TIMESTAMPTZ,
  value NUMERIC
) PARTITION BY RANGE (recorded_at);

CREATE TABLE metrics_2024 PARTITION OF metrics
  FOR VALUES FROM ('2024-01-01') TO ('2025-01-01')
  PARTITION BY LIST (metric_id);

CREATE TABLE metrics_2024_cpu PARTITION OF metrics_2024
  FOR VALUES IN (1, 2, 3);

CREATE TABLE metrics_2024_memory PARTITION OF metrics_2024
  FOR VALUES IN (4, 5, 6);
```

## Best Practices

| Practice | Reason |
|---|---|
| Partition by natural query filter columns | Maximize partition pruning |
| Keep partitions roughly equal in size | Balanced query performance |
| Limit partition count to a few hundred | Catalog lookups overhead |
| Index each partition individually | Partition-level indexes |
| Use default partition guard | Prevent unmapped data errors |
| Schedule partition maintenance | Automate lifecycle management |
| Monitor partition sizes | Detect imbalance early |

## References

- [PostgreSQL Table Partitioning Documentation](https://www.postgresql.org/docs/current/ddl-partitioning.html)
- [Partition Pruning](https://www.postgresql.org/docs/current/ddl-partitioning.html#DDL-PARTITION-PRUNING)
- [Partition Maintenance Best Practices](https://www.postgresql.org/docs/current/ddl-partitioning.html#DDL-PARTITION-MAINTENANCE)
  $content$,
  '11111111-1111-1111-1111-111111111111',
  6,
  1,
  3860,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000024',
  'PostgreSQL Performance Tuning',
  'postgresql-performance-tuning',
  'A comprehensive guide to PostgreSQL performance tuning covering configuration, query optimization, vacuuming, connection pooling, and monitoring for production workloads.',
  $content$
## Introduction

PostgreSQL performance tuning involves optimizing database configuration, query execution, indexing, and maintenance routines. This guide covers the essential knobs and practices for achieving optimal performance in production environments.

## PostgreSQL Configuration

The `postgresql.conf` file contains parameters that significantly impact performance. Start with these critical settings:

```ini
# Memory settings
shared_buffers = '4GB'          # 25% of RAM
effective_cache_size = '12GB'   # 75% of RAM
work_mem = '64MB'               # Per-operation sort memory
maintenance_work_mem = '1GB'    # VACUUM, CREATE INDEX

# Write-ahead log
wal_buffers = '16MB'
wal_writer_delay = '200ms'
wal_writer_flush_after = '1MB'

# Query planner
random_page_cost = 1.1          # SSD setting (4.0 for HDD)
effective_io_concurrency = 200  # SSD setting
default_statistics_target = 500 # More accurate query plans
```

Use `pg_config` to check current values:

```sql
SELECT name, setting, unit, source
FROM pg_settings
WHERE category LIKE '%Resource Usage%'
ORDER BY name;
```

## Query Analysis with EXPLAIN

The `EXPLAIN` command reveals how PostgreSQL executes queries:

```sql
-- Basic plan
EXPLAIN SELECT * FROM articles WHERE view_count > 10000;

-- Detailed with timing and buffers
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT a.title, a.view_count, c.name AS category
FROM articles a
JOIN categories c ON c.id = a.category_id
WHERE a.status = 'published'
ORDER BY a.view_count DESC
LIMIT 20;

-- Plan with actual rows and loops
EXPLAIN (ANALYZE, COSTS, VERBOSE, BUFFERS, FORMAT JSON)
SELECT * FROM articles WHERE title ILIKE '%indexing%';
```

Look for sequential scans on large tables, high buffer counts, and large row estimate deviations.

## Identifying Slow Queries

Track slow queries using the `pg_stat_statements` extension:

```bash
# Enable in postgresql.conf
shared_preload_libraries = 'pg_stat_statements'
pg_stat_statements.max = 10000
pg_stat_statements.track = all
```

```sql
-- Top 10 queries by total time
SELECT
  query,
  calls,
  total_exec_time / 1000 AS total_seconds,
  mean_exec_time AS avg_ms,
  rows,
  shared_blks_hit,
  shared_blks_read
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;

-- Reset statistics for fresh analysis
SELECT pg_stat_statements_reset();
```

## Vacuuming and Autovacuum

PostgreSQL uses MVCC and relies on VACUUM to reclaim dead tuples:

```sql
-- Check table bloat
SELECT
  schemaname,
  tablename,
  n_dead_tup,
  n_live_tup,
  ROUND(n_dead_tup * 100.0 / NULLIF(n_live_tup + n_dead_tup, 0), 2) AS dead_pct,
  last_autovacuum,
  last_autoanalyze
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY dead_pct DESC;
```

Configure autovacuum for aggressive cleanup on write-heavy tables:

```ini
autovacuum_max_workers = 4
autovacuum_vacuum_scale_factor = 0.01
autovacuum_vacuum_threshold = 100
autovacuum_analyze_scale_factor = 0.005
autovacuum_vacuum_cost_limit = 2000
```

## Connection Pooling

Each connection consumes memory and CPU. Use PgBouncer for connection pooling:

```ini
# pgbouncer.ini
[databases]
devwiki = host=localhost port=5432 dbname=devwiki

[pgbouncer]
pool_mode = transaction
max_client_conn = 200
default_pool_size = 20
max_db_connections = 50
```

Configure your application to use a pool of 10-20 persistent connections rather than creating new connections per request:

```csharp
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString, npgsqlOptions =>
    {
        npgsqlOptions.MaxPoolSize(20);
        npgsqlOptions.ConnectionIdleLifetime(300);
    }));
```

## Monitoring and Diagnostics

Essential monitoring queries for production systems:

```sql
-- Current active queries
SELECT pid, state, query_start, wait_event_type, wait_event, query
FROM pg_stat_activity
WHERE state = 'active' AND pid != pg_backend_pid()
ORDER BY query_start;

-- Table size and bloat
SELECT
  relname,
  n_live_tup,
  n_dead_tup,
  pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC
LIMIT 10;

-- Index usage statistics
SELECT
  indexrelname::TEXT AS index_name,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch,
  pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC
LIMIT 10;
```

## Tuning Checklist

| Area | Check | Action |
|---|---|---|
| Memory | shared_buffers at 25% of RAM | Increase if low |
| I/O | random_page_cost = 1.1 for SSD | Adjust for storage type |
| Queries | Sequential scans on large tables | Add indexes |
| Bloat | Dead tuple percentage | Tune autovacuum |
| Connections | Active connection count | Use PgBouncer |
| Caching | Cache hit ratio > 99% | Increase shared_buffers |
| Maintenance | Last vacuum timestamp | Schedule regular maintenance |

## References

- [PostgreSQL Performance Tuning Documentation](https://www.postgresql.org/docs/current/performance-tips.html)
- [PostgreSQL Configuration Reference](https://www.postgresql.org/docs/current/runtime-config.html)
- [pg_stat_statements Documentation](https://www.postgresql.org/docs/current/pgstatstatements.html)
  $content$,
  '11111111-1111-1111-1111-111111111111',
  6,
  1,
  9240,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
);

-- Refresh the sequence for generating future article IDs

-- ============================================
-- TAG MAPPINGS
-- ============================================
-- TAG_MAPPINGS_START
-- [
--   {"articleGuid": "a0000001-0000-0000-0000-000000000020", "tagIds": [15, 16, 9]},
--   {"articleGuid": "a0000001-0000-0000-0000-000000000021", "tagIds": [15, 16, 9]},
--   {"articleGuid": "a0000001-0000-0000-0000-000000000022", "tagIds": [16, 17, 9]},
--   {"articleGuid": "a0000001-0000-0000-0000-000000000023", "tagIds": [16, 17, 9]},
--   {"articleGuid": "a0000001-0000-0000-0000-000000000025", "tagIds": [15, 16, 9]},
--   {"articleGuid": "a0000001-0000-0000-0000-000000000026", "tagIds": [15, 9, 16]},
--   {"articleGuid": "a0000001-0000-0000-0000-000000000024", "tagIds": [9, 16, 15]}
-- ]
-- TAG_MAPPINGS_END




