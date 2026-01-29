--
-- exercises for the hash join code
--
BEGIN;

SET
    local min_parallel_table_scan_size = 0;

SET
    local parallel_setup_cost = 0;

-- Extract bucket and batch counts from an explain analyze plan.  In
-- general we can't make assertions about how many batches (or
-- buckets) will be required because it can vary, but we can in some
-- special cases and we can check for growth.
CREATE OR REPLACE FUNCTION find_hash (node json) returns json language plpgsql AS $$
declare
  x json;
  child json;
begin
  if node->>'Node Type' = 'Hash' then
    return node;
  else
    for child in select json_array_elements(node->'Plans')
    loop
      x := find_hash(child);
      if x is not null then
        return x;
      end if;
    end loop;
    return null;
  end if;
end;
$$;

CREATE OR REPLACE FUNCTION hash_join_batches (query text) returns TABLE (original int, final int) language plpgsql AS $$
declare
  whole_plan json;
  hash_node json;
begin
  for whole_plan in
    execute 'explain (analyze, format ''json'') ' || query
  loop
    hash_node := find_hash(json_extract_path(whole_plan, '0', 'Plan'));
    original := hash_node->>'Original Hash Batches';
    final := hash_node->>'Hash Batches';
    return next;
  end loop;
end;
$$;

-- Make a simple relation with well distributed keys and correctly
-- estimated size.
CREATE TABLE simple AS
SELECT
    generate_series(1, 20000) AS id,
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

ALTER TABLE simple
SET
    (parallel_workers = 2);

ANALYZE simple;

-- Make a relation whose size we will under-estimate.  We want stats
-- to say 1000 rows, but actually there are 20,000 rows.
CREATE TABLE bigger_than_it_looks AS
SELECT
    generate_series(1, 20000) AS id,
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

ALTER TABLE bigger_than_it_looks
SET
    (autovacuum_enabled = 'false');

ALTER TABLE bigger_than_it_looks
SET
    (parallel_workers = 2);

ANALYZE bigger_than_it_looks;

UPDATE pg_class
SET
    reltuples = 1000
WHERE
    relname = 'bigger_than_it_looks';

-- Make a relation whose size we underestimate and that also has a
-- kind of skew that breaks our batching scheme.  We want stats to say
-- 2 rows, but actually there are 20,000 rows with the same key.
CREATE TABLE extremely_skewed (id int, t text);

ALTER TABLE extremely_skewed
SET
    (autovacuum_enabled = 'false');

ALTER TABLE extremely_skewed
SET
    (parallel_workers = 2);

ANALYZE extremely_skewed;

INSERT INTO
    extremely_skewed
SELECT
    42 AS id,
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
FROM
    generate_series(1, 20000);

UPDATE pg_class
SET
    reltuples = 2,
    relpages = pg_relation_size('extremely_skewed') / 8192
WHERE
    relname = 'extremely_skewed';

-- Make a relation with a couple of enormous tuples.
CREATE TABLE wide AS
SELECT
    generate_series(1, 2) AS id,
    rpad('', 320000, 'x') AS t;

ALTER TABLE wide
SET
    (parallel_workers = 2);

-- The "optimal" case: the hash table fits in memory; we plan for 1
-- batch, we stick to that number, and peak memory usage stays within
-- our work_mem budget
-- non-parallel
SAVEPOINT settings;

SET
    local max_parallel_workers_per_gather = 0;

SET
    local work_mem = '4MB';

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    simple r
    JOIN simple s USING (id);

SELECT
    count(*)
FROM
    simple r
    JOIN simple s USING (id);

SELECT
    original > 1 AS initially_multibatch,
    final > original AS increased_batches
FROM
    hash_join_batches (
        $$
  select count(*) from simple r join simple s using (id);
$$);

ROLLBACK TO settings;

-- parallel with parallel-oblivious hash join
SAVEPOINT settings;

SET
    local max_parallel_workers_per_gather = 2;

SET
    local work_mem = '4MB';

SET
    local enable_parallel_hash = off;

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    simple r
    JOIN simple s USING (id);

SELECT
    count(*)
FROM
    simple r
    JOIN simple s USING (id);

SELECT
    original > 1 AS initially_multibatch,
    final > original AS increased_batches
FROM
    hash_join_batches (
        $$
  select count(*) from simple r join simple s using (id);
$$);

ROLLBACK TO settings;

-- parallel with parallel-aware hash join
SAVEPOINT settings;

SET
    local max_parallel_workers_per_gather = 2;

SET
    local work_mem = '4MB';

SET
    local enable_parallel_hash = ON;

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    simple r
    JOIN simple s USING (id);

SELECT
    count(*)
FROM
    simple r
    JOIN simple s USING (id);

SELECT
    original > 1 AS initially_multibatch,
    final > original AS increased_batches
FROM
    hash_join_batches (
        $$
  select count(*) from simple r join simple s using (id);
$$);

ROLLBACK TO settings;

-- The "good" case: batches required, but we plan the right number; we
-- plan for some number of batches, and we stick to that number, and
-- peak memory usage says within our work_mem budget
-- non-parallel
SAVEPOINT settings;

SET
    local max_parallel_workers_per_gather = 0;

SET
    local work_mem = '128kB';

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    simple r
    JOIN simple s USING (id);

SELECT
    count(*)
FROM
    simple r
    JOIN simple s USING (id);

SELECT
    original > 1 AS initially_multibatch,
    final > original AS increased_batches
FROM
    hash_join_batches (
        $$
  select count(*) from simple r join simple s using (id);
$$);

ROLLBACK TO settings;

-- parallel with parallel-oblivious hash join
SAVEPOINT settings;

SET
    local max_parallel_workers_per_gather = 2;

SET
    local work_mem = '128kB';

SET
    local enable_parallel_hash = off;

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    simple r
    JOIN simple s USING (id);

SELECT
    count(*)
FROM
    simple r
    JOIN simple s USING (id);

SELECT
    original > 1 AS initially_multibatch,
    final > original AS increased_batches
FROM
    hash_join_batches (
        $$
  select count(*) from simple r join simple s using (id);
$$);

ROLLBACK TO settings;

-- parallel with parallel-aware hash join
SAVEPOINT settings;

SET
    local max_parallel_workers_per_gather = 2;

SET
    local work_mem = '192kB';

SET
    local enable_parallel_hash = ON;

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    simple r
    JOIN simple s USING (id);

SELECT
    count(*)
FROM
    simple r
    JOIN simple s USING (id);

SELECT
    original > 1 AS initially_multibatch,
    final > original AS increased_batches
FROM
    hash_join_batches (
        $$
  select count(*) from simple r join simple s using (id);
$$);

ROLLBACK TO settings;

-- The "bad" case: during execution we need to increase number of
-- batches; in this case we plan for 1 batch, and increase at least a
-- couple of times, and peak memory usage stays within our work_mem
-- budget
-- non-parallel
SAVEPOINT settings;

SET
    local max_parallel_workers_per_gather = 0;

SET
    local work_mem = '128kB';

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    simple r
    JOIN bigger_than_it_looks s USING (id);

SELECT
    count(*)
FROM
    simple r
    JOIN bigger_than_it_looks s USING (id);

SELECT
    original > 1 AS initially_multibatch,
    final > original AS increased_batches
FROM
    hash_join_batches (
        $$
  select count(*) FROM simple r JOIN bigger_than_it_looks s USING (id);
$$);

ROLLBACK TO settings;

-- parallel with parallel-oblivious hash join
SAVEPOINT settings;

SET
    local max_parallel_workers_per_gather = 2;

SET
    local work_mem = '128kB';

SET
    local enable_parallel_hash = off;

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    simple r
    JOIN bigger_than_it_looks s USING (id);

SELECT
    count(*)
FROM
    simple r
    JOIN bigger_than_it_looks s USING (id);

SELECT
    original > 1 AS initially_multibatch,
    final > original AS increased_batches
FROM
    hash_join_batches (
        $$
  select count(*) from simple r join bigger_than_it_looks s using (id);
$$);

ROLLBACK TO settings;

-- parallel with parallel-aware hash join
SAVEPOINT settings;

SET
    local max_parallel_workers_per_gather = 1;

SET
    local work_mem = '192kB';

SET
    local enable_parallel_hash = ON;

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    simple r
    JOIN bigger_than_it_looks s USING (id);

SELECT
    count(*)
FROM
    simple r
    JOIN bigger_than_it_looks s USING (id);

SELECT
    original > 1 AS initially_multibatch,
    final > original AS increased_batches
FROM
    hash_join_batches (
        $$
  select count(*) from simple r join bigger_than_it_looks s using (id);
$$);

ROLLBACK TO settings;

-- The "ugly" case: increasing the number of batches during execution
-- doesn't help, so stop trying to fit in work_mem and hope for the
-- best; in this case we plan for 1 batch, increases just once and
-- then stop increasing because that didn't help at all, so we blow
-- right through the work_mem budget and hope for the best...
-- non-parallel
SAVEPOINT settings;

SET
    local max_parallel_workers_per_gather = 0;

SET
    local work_mem = '128kB';

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    simple r
    JOIN extremely_skewed s USING (id);

SELECT
    count(*)
FROM
    simple r
    JOIN extremely_skewed s USING (id);

SELECT
    *
FROM
    hash_join_batches (
        $$
  select count(*) from simple r join extremely_skewed s using (id);
$$);

ROLLBACK TO settings;

-- parallel with parallel-oblivious hash join
SAVEPOINT settings;

SET
    local max_parallel_workers_per_gather = 2;

SET
    local work_mem = '128kB';

SET
    local enable_parallel_hash = off;

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    simple r
    JOIN extremely_skewed s USING (id);

SELECT
    count(*)
FROM
    simple r
    JOIN extremely_skewed s USING (id);

SELECT
    *
FROM
    hash_join_batches (
        $$
  select count(*) from simple r join extremely_skewed s using (id);
$$);

ROLLBACK TO settings;

-- parallel with parallel-aware hash join
SAVEPOINT settings;

SET
    local max_parallel_workers_per_gather = 1;

SET
    local work_mem = '128kB';

SET
    local enable_parallel_hash = ON;

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    simple r
    JOIN extremely_skewed s USING (id);

SELECT
    count(*)
FROM
    simple r
    JOIN extremely_skewed s USING (id);

SELECT
    *
FROM
    hash_join_batches (
        $$
  select count(*) from simple r join extremely_skewed s using (id);
$$);

ROLLBACK TO settings;

-- A couple of other hash join tests unrelated to work_mem management.
-- Check that EXPLAIN ANALYZE has data even if the leader doesn't participate
SAVEPOINT settings;

SET
    local max_parallel_workers_per_gather = 2;

SET
    local work_mem = '4MB';

SET
    local parallel_leader_participation = off;

SELECT
    *
FROM
    hash_join_batches (
        $$
  select count(*) from simple r join simple s using (id);
$$);

ROLLBACK TO settings;

-- Exercise rescans.  We'll turn off parallel_leader_participation so
-- that we can check that instrumentation comes back correctly.
CREATE TABLE join_foo AS
SELECT
    generate_series(1, 3) AS id,
    'xxxxx'::text AS t;

ALTER TABLE join_foo
SET
    (parallel_workers = 0);

CREATE TABLE join_bar AS
SELECT
    generate_series(1, 10000) AS id,
    'xxxxx'::text AS t;

ALTER TABLE join_bar
SET
    (parallel_workers = 2);

-- multi-batch with rescan, parallel-oblivious
SAVEPOINT settings;

SET
    enable_parallel_hash = off;

SET
    parallel_leader_participation = off;

SET
    min_parallel_table_scan_size = 0;

SET
    parallel_setup_cost = 0;

SET
    parallel_tuple_cost = 0;

SET
    max_parallel_workers_per_gather = 2;

SET
    enable_material = off;

SET
    enable_mergejoin = off;

SET
    work_mem = '64kB';

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    join_foo
    LEFT JOIN (
        SELECT
            b1.id,
            b1.t
        FROM
            join_bar b1
            JOIN join_bar b2 USING (id)) ss ON join_foo.id < ss.id + 1
    AND join_foo.id > ss.id - 1;

SELECT
    count(*)
FROM
    join_foo
    LEFT JOIN (
        SELECT
            b1.id,
            b1.t
        FROM
            join_bar b1
            JOIN join_bar b2 USING (id)) ss ON join_foo.id < ss.id + 1
    AND join_foo.id > ss.id - 1;

SELECT
    final > 1 AS multibatch
FROM
    hash_join_batches (
        $$
  select count(*) from join_foo
    left join (select b1.id, b1.t from join_bar b1 join join_bar b2 using (id)) ss
    on join_foo.id < ss.id + 1 and join_foo.id > ss.id - 1;
$$);

ROLLBACK TO settings;

-- single-batch with rescan, parallel-oblivious
SAVEPOINT settings;

SET
    enable_parallel_hash = off;

SET
    parallel_leader_participation = off;

SET
    min_parallel_table_scan_size = 0;

SET
    parallel_setup_cost = 0;

SET
    parallel_tuple_cost = 0;

SET
    max_parallel_workers_per_gather = 2;

SET
    enable_material = off;

SET
    enable_mergejoin = off;

SET
    work_mem = '4MB';

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    join_foo
    LEFT JOIN (
        SELECT
            b1.id,
            b1.t
        FROM
            join_bar b1
            JOIN join_bar b2 USING (id)) ss ON join_foo.id < ss.id + 1
    AND join_foo.id > ss.id - 1;

SELECT
    count(*)
FROM
    join_foo
    LEFT JOIN (
        SELECT
            b1.id,
            b1.t
        FROM
            join_bar b1
            JOIN join_bar b2 USING (id)) ss ON join_foo.id < ss.id + 1
    AND join_foo.id > ss.id - 1;

SELECT
    final > 1 AS multibatch
FROM
    hash_join_batches (
        $$
  select count(*) from join_foo
    left join (select b1.id, b1.t from join_bar b1 join join_bar b2 using (id)) ss
    on join_foo.id < ss.id + 1 and join_foo.id > ss.id - 1;
$$);

ROLLBACK TO settings;

-- multi-batch with rescan, parallel-aware
SAVEPOINT settings;

SET
    enable_parallel_hash = ON;

SET
    parallel_leader_participation = off;

SET
    min_parallel_table_scan_size = 0;

SET
    parallel_setup_cost = 0;

SET
    parallel_tuple_cost = 0;

SET
    max_parallel_workers_per_gather = 2;

SET
    enable_material = off;

SET
    enable_mergejoin = off;

SET
    work_mem = '64kB';

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    join_foo
    LEFT JOIN (
        SELECT
            b1.id,
            b1.t
        FROM
            join_bar b1
            JOIN join_bar b2 USING (id)) ss ON join_foo.id < ss.id + 1
    AND join_foo.id > ss.id - 1;

SELECT
    count(*)
FROM
    join_foo
    LEFT JOIN (
        SELECT
            b1.id,
            b1.t
        FROM
            join_bar b1
            JOIN join_bar b2 USING (id)) ss ON join_foo.id < ss.id + 1
    AND join_foo.id > ss.id - 1;

SELECT
    final > 1 AS multibatch
FROM
    hash_join_batches (
        $$
  select count(*) from join_foo
    left join (select b1.id, b1.t from join_bar b1 join join_bar b2 using (id)) ss
    on join_foo.id < ss.id + 1 and join_foo.id > ss.id - 1;
$$);

ROLLBACK TO settings;

-- single-batch with rescan, parallel-aware
SAVEPOINT settings;

SET
    enable_parallel_hash = ON;

SET
    parallel_leader_participation = off;

SET
    min_parallel_table_scan_size = 0;

SET
    parallel_setup_cost = 0;

SET
    parallel_tuple_cost = 0;

SET
    max_parallel_workers_per_gather = 2;

SET
    enable_material = off;

SET
    enable_mergejoin = off;

SET
    work_mem = '4MB';

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    join_foo
    LEFT JOIN (
        SELECT
            b1.id,
            b1.t
        FROM
            join_bar b1
            JOIN join_bar b2 USING (id)) ss ON join_foo.id < ss.id + 1
    AND join_foo.id > ss.id - 1;

SELECT
    count(*)
FROM
    join_foo
    LEFT JOIN (
        SELECT
            b1.id,
            b1.t
        FROM
            join_bar b1
            JOIN join_bar b2 USING (id)) ss ON join_foo.id < ss.id + 1
    AND join_foo.id > ss.id - 1;

SELECT
    final > 1 AS multibatch
FROM
    hash_join_batches (
        $$
  select count(*) from join_foo
    left join (select b1.id, b1.t from join_bar b1 join join_bar b2 using (id)) ss
    on join_foo.id < ss.id + 1 and join_foo.id > ss.id - 1;
$$);

ROLLBACK TO settings;

-- A full outer join where every record is matched.
-- non-parallel
SAVEPOINT settings;

SET
    local max_parallel_workers_per_gather = 0;

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    simple r
    FULL OUTER JOIN simple s USING (id);

SELECT
    count(*)
FROM
    simple r
    FULL OUTER JOIN simple s USING (id);

ROLLBACK TO settings;

-- parallelism not possible with parallel-oblivious outer hash join
SAVEPOINT settings;

SET
    local max_parallel_workers_per_gather = 2;

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    simple r
    FULL OUTER JOIN simple s USING (id);

SELECT
    count(*)
FROM
    simple r
    FULL OUTER JOIN simple s USING (id);

ROLLBACK TO settings;

-- An full outer join where every record is not matched.
-- non-parallel
SAVEPOINT settings;

SET
    local max_parallel_workers_per_gather = 0;

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    simple r
    FULL OUTER JOIN simple s ON (r.id = 0 - s.id);

SELECT
    count(*)
FROM
    simple r
    FULL OUTER JOIN simple s ON (r.id = 0 - s.id);

ROLLBACK TO settings;

-- parallelism not possible with parallel-oblivious outer hash join
SAVEPOINT settings;

SET
    local max_parallel_workers_per_gather = 2;

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    simple r
    FULL OUTER JOIN simple s ON (r.id = 0 - s.id);

SELECT
    count(*)
FROM
    simple r
    FULL OUTER JOIN simple s ON (r.id = 0 - s.id);

ROLLBACK TO settings;

-- exercise special code paths for huge tuples (note use of non-strict
-- expression and left join required to get the detoasted tuple into
-- the hash table)
-- parallel with parallel-aware hash join (hits ExecParallelHashLoadTuple and
-- sts_puttuple oversized tuple cases because it's multi-batch)
SAVEPOINT settings;

SET
    max_parallel_workers_per_gather = 2;

SET
    enable_parallel_hash = ON;

SET
    work_mem = '128kB';

EXPLAIN (costs off)
SELECT
    length(max(s.t))
FROM
    wide
    LEFT JOIN (
        SELECT
            id,
            coalesce(t, '') || '' AS t
        FROM
            wide) s USING (id);

SELECT
    length(max(s.t))
FROM
    wide
    LEFT JOIN (
        SELECT
            id,
            coalesce(t, '') || '' AS t
        FROM
            wide) s USING (id);

SELECT
    final > 1 AS multibatch
FROM
    hash_join_batches (
        $$
  select length(max(s.t))
  from wide left join (select id, coalesce(t, '') || '' as t from wide) s using (id);
$$);

ROLLBACK TO settings;

ROLLBACK;