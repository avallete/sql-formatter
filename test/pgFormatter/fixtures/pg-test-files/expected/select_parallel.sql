--
-- PARALLEL
--
CREATE FUNCTION sp_parallel_restricted (int) returns int AS $$begin return $1; end$$ language plpgsql parallel restricted;

-- Serializable isolation would disable parallel query, so explicitly use an
-- arbitrary other level.
BEGIN isolation level repeatable read;

-- encourage use of parallel plans
SET
    parallel_setup_cost = 0;

SET
    parallel_tuple_cost = 0;

SET
    min_parallel_table_scan_size = 0;

SET
    max_parallel_workers_per_gather = 4;

-- Parallel Append with partial-subplans
EXPLAIN (costs off)
SELECT
    round(avg(aa)),
    sum(aa)
FROM
    a_star;

SELECT
    round(avg(aa)),
    sum(aa)
FROM
    a_star a1;

-- Parallel Append with both partial and non-partial subplans
ALTER TABLE c_star
SET
    (parallel_workers = 0);

ALTER TABLE d_star
SET
    (parallel_workers = 0);

EXPLAIN (costs off)
SELECT
    round(avg(aa)),
    sum(aa)
FROM
    a_star;

SELECT
    round(avg(aa)),
    sum(aa)
FROM
    a_star a2;

-- Parallel Append with only non-partial subplans
ALTER TABLE a_star
SET
    (parallel_workers = 0);

ALTER TABLE b_star
SET
    (parallel_workers = 0);

ALTER TABLE e_star
SET
    (parallel_workers = 0);

ALTER TABLE f_star
SET
    (parallel_workers = 0);

EXPLAIN (costs off)
SELECT
    round(avg(aa)),
    sum(aa)
FROM
    a_star;

SELECT
    round(avg(aa)),
    sum(aa)
FROM
    a_star a3;

-- Disable Parallel Append
ALTER TABLE a_star
RESET (parallel_workers);

ALTER TABLE b_star
RESET (parallel_workers);

ALTER TABLE c_star
RESET (parallel_workers);

ALTER TABLE d_star
RESET (parallel_workers);

ALTER TABLE e_star
RESET (parallel_workers);

ALTER TABLE f_star
RESET (parallel_workers);

SET
    enable_parallel_append TO off;

EXPLAIN (costs off)
SELECT
    round(avg(aa)),
    sum(aa)
FROM
    a_star;

SELECT
    round(avg(aa)),
    sum(aa)
FROM
    a_star a4;

RESET enable_parallel_append;

-- Parallel Append that runs serially
CREATE FUNCTION sp_test_func () returns setof text AS $$ select 'foo'::varchar union all select 'bar'::varchar $$ language sql stable;

SELECT
    sp_test_func ()
ORDER BY
    1;

-- Parallel Append is not to be used when the subpath depends on the outer param
CREATE TABLE part_pa_test (a int, b int)
PARTITION BY
    range (a);

CREATE TABLE part_pa_test_p1 partition of part_pa_test FOR
VALUES
FROM
    (minvalue) TO (0);

CREATE TABLE part_pa_test_p2 partition of part_pa_test FOR
VALUES
FROM
    (0) TO (maxvalue);

EXPLAIN (costs off)
SELECT (
        SELECT
            max ( (
                    SELECT
                        pa1.b
                    FROM
                        part_pa_test pa1
                    WHERE
                        pa1.a = pa2.a)))
FROM
    part_pa_test pa2;

DROP TABLE part_pa_test;

-- test with leader participation disabled
SET
    parallel_leader_participation = off;

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    tenk1
WHERE
    stringu1 = 'GRAAAA';

SELECT
    count(*)
FROM
    tenk1
WHERE
    stringu1 = 'GRAAAA';

-- test with leader participation disabled, but no workers available (so
-- the leader will have to run the plan despite the setting)
SET
    max_parallel_workers = 0;

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    tenk1
WHERE
    stringu1 = 'GRAAAA';

SELECT
    count(*)
FROM
    tenk1
WHERE
    stringu1 = 'GRAAAA';

RESET max_parallel_workers;

RESET parallel_leader_participation;

-- test that parallel_restricted function doesn't run in worker
ALTER TABLE tenk1
SET
    (parallel_workers = 4);

EXPLAIN (VERBOSE, costs off)
SELECT
    sp_parallel_restricted (unique1)
FROM
    tenk1
WHERE
    stringu1 = 'GRAAAA'
ORDER BY
    1;

-- test parallel plan when group by expression is in target list.
EXPLAIN (costs off)
SELECT
    length(stringu1)
FROM
    tenk1
GROUP BY
    length(stringu1);

SELECT
    length(stringu1)
FROM
    tenk1
GROUP BY
    length(stringu1);

EXPLAIN (costs off)
SELECT
    stringu1,
    count(*)
FROM
    tenk1
GROUP BY
    stringu1
ORDER BY
    stringu1;

-- test that parallel plan for aggregates is not selected when
-- target list contains parallel restricted clause.
EXPLAIN (costs off)
SELECT
    sum(sp_parallel_restricted (unique1))
FROM
    tenk1
GROUP BY
    (sp_parallel_restricted (unique1));

-- test prepared statement
PREPARE tenk1_count (integer) AS
SELECT
    count((unique1))
FROM
    tenk1
WHERE
    hundred > $1;

EXPLAIN (costs off)
EXECUTE tenk1_count (1);

EXECUTE tenk1_count (1);

DEALLOCATE tenk1_count;

-- test parallel plans for queries containing un-correlated subplans.
ALTER TABLE tenk2
SET
    (parallel_workers = 0);

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    tenk1
WHERE
    (two, four) NOT IN (
        SELECT
            hundred,
            thousand
        FROM
            tenk2
        WHERE
            thousand > 100);

SELECT
    count(*)
FROM
    tenk1
WHERE
    (two, four) NOT IN (
        SELECT
            hundred,
            thousand
        FROM
            tenk2
        WHERE
            thousand > 100);

-- this is not parallel-safe due to use of random() within SubLink's testexpr:
EXPLAIN (costs off)
SELECT
    *
FROM
    tenk1
WHERE
    (unique1 + random())::integer NOT IN (
        SELECT
            ten
        FROM
            tenk2);

ALTER TABLE tenk2
RESET (parallel_workers);

-- test parallel plan for a query containing initplan.
SET
    enable_indexscan = off;

SET
    enable_indexonlyscan = off;

SET
    enable_bitmapscan = off;

ALTER TABLE tenk2
SET
    (parallel_workers = 2);

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    tenk1
WHERE
    tenk1.unique1 = (
        SELECT
            max(tenk2.unique1)
        FROM
            tenk2);

SELECT
    count(*)
FROM
    tenk1
WHERE
    tenk1.unique1 = (
        SELECT
            max(tenk2.unique1)
        FROM
            tenk2);

RESET enable_indexscan;

RESET enable_indexonlyscan;

RESET enable_bitmapscan;

ALTER TABLE tenk2
RESET (parallel_workers);

-- test parallel index scans.
SET
    enable_seqscan TO off;

SET
    enable_bitmapscan TO off;

EXPLAIN (costs off)
SELECT
    count((unique1))
FROM
    tenk1
WHERE
    hundred > 1;

SELECT
    count((unique1))
FROM
    tenk1
WHERE
    hundred > 1;

-- test parallel index-only scans.
EXPLAIN (costs off)
SELECT
    count(*)
FROM
    tenk1
WHERE
    thousand > 95;

SELECT
    count(*)
FROM
    tenk1
WHERE
    thousand > 95;

-- test rescan cases too
SET
    enable_material = FALSE;

EXPLAIN (costs off)
SELECT
    *
FROM (
        SELECT
            count(unique1)
        FROM
            tenk1
        WHERE
            hundred > 10) ss
    RIGHT JOIN (
        VALUES
            (1),
            (2),
            (3)) v (x) ON TRUE;

SELECT
    *
FROM (
        SELECT
            count(unique1)
        FROM
            tenk1
        WHERE
            hundred > 10) ss
    RIGHT JOIN (
        VALUES
            (1),
            (2),
            (3)) v (x) ON TRUE;

EXPLAIN (costs off)
SELECT
    *
FROM (
        SELECT
            count(*)
        FROM
            tenk1
        WHERE
            thousand > 99) ss
    RIGHT JOIN (
        VALUES
            (1),
            (2),
            (3)) v (x) ON TRUE;

SELECT
    *
FROM (
        SELECT
            count(*)
        FROM
            tenk1
        WHERE
            thousand > 99) ss
    RIGHT JOIN (
        VALUES
            (1),
            (2),
            (3)) v (x) ON TRUE;

RESET enable_material;

RESET enable_seqscan;

RESET enable_bitmapscan;

-- test parallel bitmap heap scan.
SET
    enable_seqscan TO off;

SET
    enable_indexscan TO off;

SET
    enable_hashjoin TO off;

SET
    enable_mergejoin TO off;

SET
    enable_material TO off;

-- test prefetching, if the platform allows it
DO $$
BEGIN
 SET effective_io_concurrency = 50;
EXCEPTION WHEN invalid_parameter_value THEN
END $$;

SET
    work_mem = '64kB';

--set small work mem to force lossy pages
EXPLAIN (costs off)
SELECT
    count(*)
FROM
    tenk1,
    tenk2
WHERE
    tenk1.hundred > 1
    AND tenk2.thousand = 0;

SELECT
    count(*)
FROM
    tenk1,
    tenk2
WHERE
    tenk1.hundred > 1
    AND tenk2.thousand = 0;

CREATE TABLE bmscantest (a int, t text);

INSERT INTO
    bmscantest
SELECT
    r,
    'fooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo'
FROM
    generate_series(1, 100000) r;

CREATE INDEX i_bmtest ON bmscantest (a);

SELECT
    count(*)
FROM
    bmscantest
WHERE
    a > 1;

-- test accumulation of stats for parallel nodes
RESET enable_seqscan;

ALTER TABLE tenk2
SET
    (parallel_workers = 0);

EXPLAIN (
    ANALYZE,
    timing off,
    summary off,
    costs off)
SELECT
    count(*)
FROM
    tenk1,
    tenk2
WHERE
    tenk1.hundred > 1
    AND tenk2.thousand = 0;

ALTER TABLE tenk2
RESET (parallel_workers);

RESET work_mem;

CREATE FUNCTION explain_parallel_sort_stats () returns setof text language plpgsql AS $$
declare ln text;
begin
    for ln in
        explain (analyze, timing off, summary off, costs off)
          select * from
          (select ten from tenk1 where ten < 100 order by ten) ss
          right join (values (1),(2),(3)) v(x) on true
    loop
        ln := regexp_replace(ln, 'Memory: \S*',  'Memory: xxx');
        return next ln;
    end loop;
end;
$$;

SELECT
    *
FROM
    explain_parallel_sort_stats ();

RESET enable_indexscan;

RESET enable_hashjoin;

RESET enable_mergejoin;

RESET enable_material;

RESET effective_io_concurrency;

DROP TABLE bmscantest;

DROP FUNCTION explain_parallel_sort_stats ();

-- test parallel merge join path.
SET
    enable_hashjoin TO off;

SET
    enable_nestloop TO off;

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    tenk1,
    tenk2
WHERE
    tenk1.unique1 = tenk2.unique1;

SELECT
    count(*)
FROM
    tenk1,
    tenk2
WHERE
    tenk1.unique1 = tenk2.unique1;

RESET enable_hashjoin;

RESET enable_nestloop;

-- test gather merge
SET
    enable_hashagg = FALSE;

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    tenk1
GROUP BY
    twenty;

SELECT
    count(*)
FROM
    tenk1
GROUP BY
    twenty;

--test expressions in targetlist are pushed down for gather merge
CREATE FUNCTION sp_simple_func (var1 integer) returns integer AS $$
begin
        return var1 + 10;
end;
$$ language plpgsql PARALLEL SAFE;

EXPLAIN (costs off, VERBOSE)
SELECT
    ten,
    sp_simple_func (ten)
FROM
    tenk1
WHERE
    ten < 100
ORDER BY
    ten;

DROP FUNCTION sp_simple_func (integer);

-- test handling of SRFs in targetlist (bug in 10.0)
EXPLAIN (costs off)
SELECT
    count(*),
    generate_series(1, 2)
FROM
    tenk1
GROUP BY
    twenty;

SELECT
    count(*),
    generate_series(1, 2)
FROM
    tenk1
GROUP BY
    twenty;

-- test gather merge with parallel leader participation disabled
SET
    parallel_leader_participation = off;

EXPLAIN (costs off)
SELECT
    count(*)
FROM
    tenk1
GROUP BY
    twenty;

SELECT
    count(*)
FROM
    tenk1
GROUP BY
    twenty;

RESET parallel_leader_participation;

--test rescan behavior of gather merge
SET
    enable_material = FALSE;

EXPLAIN (costs off)
SELECT
    *
FROM (
        SELECT
            string4,
            count(unique2)
        FROM
            tenk1
        GROUP BY
            string4
        ORDER BY
            string4) ss
    RIGHT JOIN (
        VALUES
            (1),
            (2),
            (3)) v (x) ON TRUE;

SELECT
    *
FROM (
        SELECT
            string4,
            count(unique2)
        FROM
            tenk1
        GROUP BY
            string4
        ORDER BY
            string4) ss
    RIGHT JOIN (
        VALUES
            (1),
            (2),
            (3)) v (x) ON TRUE;

RESET enable_material;

RESET enable_hashagg;

-- check parallelized int8 aggregate (bug #14897)
EXPLAIN (costs off)
SELECT
    avg(unique1::int8)
FROM
    tenk1;

SELECT
    avg(unique1::int8)
FROM
    tenk1;

-- gather merge test with a LIMIT
EXPLAIN (costs off)
SELECT
    fivethous
FROM
    tenk1
ORDER BY
    fivethous
LIMIT
    4;

SELECT
    fivethous
FROM
    tenk1
ORDER BY
    fivethous
LIMIT
    4;

-- gather merge test with 0 worker
SET
    max_parallel_workers = 0;

EXPLAIN (costs off)
SELECT
    string4
FROM
    tenk1
ORDER BY
    string4
LIMIT
    5;

SELECT
    string4
FROM
    tenk1
ORDER BY
    string4
LIMIT
    5;

-- gather merge test with 0 workers, with parallel leader
-- participation disabled (the leader will have to run the plan
-- despite the setting)
SET
    parallel_leader_participation = off;

EXPLAIN (costs off)
SELECT
    string4
FROM
    tenk1
ORDER BY
    string4
LIMIT
    5;

SELECT
    string4
FROM
    tenk1
ORDER BY
    string4
LIMIT
    5;

RESET parallel_leader_participation;

RESET max_parallel_workers;

SAVEPOINT settings;

SET
    LOCAL force_parallel_mode = 1;

EXPLAIN (costs off)
SELECT
    stringu1::int2
FROM
    tenk1
WHERE
    unique1 = 1;

ROLLBACK TO SAVEPOINT settings;

-- exercise record typmod remapping between backends
CREATE FUNCTION make_record (n int) RETURNS RECORD LANGUAGE plpgsql PARALLEL SAFE AS $$
BEGIN
  RETURN CASE n
           WHEN 1 THEN ROW(1)
           WHEN 2 THEN ROW(1, 2)
           WHEN 3 THEN ROW(1, 2, 3)
           WHEN 4 THEN ROW(1, 2, 3, 4)
           ELSE ROW(1, 2, 3, 4, 5)
         END;
END;
$$;

SAVEPOINT settings;

SET
    LOCAL force_parallel_mode = 1;

SELECT
    make_record (x)
FROM (
        SELECT
            generate_series(1, 5) x) ss
ORDER BY
    x;

ROLLBACK TO SAVEPOINT settings;

DROP FUNCTION make_record (n int);

-- test the sanity of parallel query after the active role is dropped.
DROP ROLE if EXISTS regress_parallel_worker;

CREATE ROLE regress_parallel_worker;

SET ROLE regress_parallel_worker;

RESET SESSION AUTHORIZATION;

DROP ROLE regress_parallel_worker;

SET
    force_parallel_mode = 1;

SELECT
    count(*)
FROM
    tenk1;

RESET force_parallel_mode;

RESET ROLE;

-- Window function calculation can't be pushed to workers.
EXPLAIN (costs off, VERBOSE)
SELECT
    count(*)
FROM
    tenk1 a
WHERE
    (unique1, two) IN (
        SELECT
            unique1,
            row_number() OVER ()
        FROM
            tenk1 b);

-- LIMIT/OFFSET within sub-selects can't be pushed to workers.
EXPLAIN (costs off)
SELECT
    *
FROM
    tenk1 a
WHERE
    two IN (
        SELECT
            two
        FROM
            tenk1 b
        WHERE
            stringu1 LIKE '%AAAA'
        LIMIT
            3);

-- to increase the parallel query test coverage
SAVEPOINT settings;

SET
    LOCAL force_parallel_mode = 1;

EXPLAIN (
    ANALYZE,
    timing off,
    summary off,
    costs off)
SELECT
    *
FROM
    tenk1;

ROLLBACK TO SAVEPOINT settings;

-- provoke error in worker
SAVEPOINT settings;

SET
    LOCAL force_parallel_mode = 1;

SELECT
    stringu1::int2
FROM
    tenk1
WHERE
    unique1 = 1;

ROLLBACK TO SAVEPOINT settings;

-- test interaction with set-returning functions
SAVEPOINT settings;

-- multiple subqueries under a single Gather node
-- must set parallel_setup_cost > 0 to discourage multiple Gather nodes
SET
    LOCAL parallel_setup_cost = 10;

EXPLAIN (COSTS OFF)
SELECT
    unique1
FROM
    tenk1
WHERE
    fivethous = tenthous + 1
UNION ALL
SELECT
    unique1
FROM
    tenk1
WHERE
    fivethous = tenthous + 1;

ROLLBACK TO SAVEPOINT settings;

-- can't use multiple subqueries under a single Gather node due to initPlans
EXPLAIN (COSTS OFF)
SELECT
    unique1
FROM
    tenk1
WHERE
    fivethous = (
        SELECT
            unique1
        FROM
            tenk1
        WHERE
            fivethous = 1
        LIMIT
            1)
UNION ALL
SELECT
    unique1
FROM
    tenk1
WHERE
    fivethous = (
        SELECT
            unique2
        FROM
            tenk1
        WHERE
            fivethous = 1
        LIMIT
            1)
ORDER BY
    1;

-- test interaction with SRFs
SELECT
    *
FROM
    information_schema.foreign_data_wrapper_options
ORDER BY
    1,
    2,
    3;

-- test passing expanded-value representations to workers
CREATE FUNCTION make_some_array (int, int) returns INT[] AS $$declare x int[];
  begin
    x[1] := $1;
    x[2] := $2;
    return x;
  end$$ language plpgsql parallel safe;

CREATE TABLE fooarr (f1 text, f2 INT[], f3 text);

INSERT INTO
    fooarr
VALUES
    ('1', ARRAY[1, 2], 'one');

PREPARE pstmt (text, INT[]) AS
SELECT
    *
FROM
    fooarr
WHERE
    f1 = $1
    AND f2 = $2;

EXPLAIN (COSTS OFF)
EXECUTE pstmt ('1', make_some_array (1, 2));

EXECUTE pstmt ('1', make_some_array (1, 2));

DEALLOCATE pstmt;

-- test interaction between subquery and partial_paths
CREATE VIEW tenk1_vw_sec
WITH
    (security_barrier) AS
SELECT
    *
FROM
    tenk1;

EXPLAIN (COSTS OFF)
SELECT
    1
FROM
    tenk1_vw_sec
WHERE (
        SELECT
            sum(f1)
        FROM
            int4_tbl
        WHERE
            f1 < unique1) < 100;

ROLLBACK;