CREATE TABLE rngfunc2 (rngfuncid int, f2 int);

INSERT INTO
    rngfunc2
VALUES
    (1, 11);

INSERT INTO
    rngfunc2
VALUES
    (2, 22);

INSERT INTO
    rngfunc2
VALUES
    (1, 111);

CREATE FUNCTION rngfunct (int) returns setof rngfunc2 AS 'SELECT * FROM rngfunc2 WHERE rngfuncid = $1 ORDER BY f2;' LANGUAGE SQL;

-- function with ORDINALITY
SELECT
    *
FROM
    rngfunct (1) WITH ORDINALITY AS z (a, b, ord);

SELECT
    *
FROM
    rngfunct (1) WITH ORDINALITY AS z (a, b, ord)
WHERE
    b > 100;

-- ordinal 2, not 1
-- ordinality vs. column names and types
SELECT
    a,
    b,
    ord
FROM
    rngfunct (1) WITH ORDINALITY AS z (a, b, ord);

SELECT
    a,
    ord
FROM
    unnest(ARRAY['a', 'b']) WITH ORDINALITY AS z (a, ord);

SELECT
    *
FROM
    unnest(ARRAY['a', 'b']) WITH ORDINALITY AS z (a, ord);

SELECT
    a,
    ord
FROM
    unnest(ARRAY[1.0::float8]) WITH ORDINALITY AS z (a, ord);

SELECT
    *
FROM
    unnest(ARRAY[1.0::float8]) WITH ORDINALITY AS z (a, ord);

SELECT
    row_to_json(s.*)
FROM
    generate_series(11, 14) WITH ORDINALITY s;

-- ordinality vs. views
CREATE TEMPORARY VIEW vw_ord AS
SELECT
    *
FROM (
        VALUES
            (1)) v (n)
    JOIN rngfunct (1) WITH ORDINALITY AS z (a, b, ord) ON (n = ord);

SELECT
    *
FROM
    vw_ord;

SELECT
    definition
FROM
    pg_views
WHERE
    viewname = 'vw_ord';

DROP VIEW vw_ord;

-- multiple functions
SELECT
    *
FROM
    rows
FROM
    (rngfunct (1), rngfunct (2)) WITH ORDINALITY AS z (a, b, c, d, ord);

CREATE TEMPORARY VIEW vw_ord AS
SELECT
    *
FROM (
        VALUES
            (1)) v (n)
    JOIN rows
FROM
    (rngfunct (1), rngfunct (2)) WITH ORDINALITY AS z (a, b, c, d, ord) ON (n = ord);

SELECT
    *
FROM
    vw_ord;

SELECT
    definition
FROM
    pg_views
WHERE
    viewname = 'vw_ord';

DROP VIEW vw_ord;

-- expansions of unnest()
SELECT
    *
FROM
    unnest(ARRAY[10, 20], ARRAY['foo', 'bar'], ARRAY[1.0]);

SELECT
    *
FROM
    unnest(ARRAY[10, 20], ARRAY['foo', 'bar'], ARRAY[1.0]) WITH ORDINALITY AS z (a, b, c, ord);

SELECT
    *
FROM
    rows
FROM (
        unnest(ARRAY[10, 20], ARRAY['foo', 'bar'], ARRAY[1.0])) WITH ORDINALITY AS z (a, b, c, ord);

SELECT
    *
FROM
    rows
FROM (
        unnest(ARRAY[10, 20], ARRAY['foo', 'bar']),
        generate_series(101, 102)) WITH ORDINALITY AS z (a, b, c, ord);

CREATE TEMPORARY VIEW vw_ord AS
SELECT
    *
FROM
    unnest(ARRAY[10, 20], ARRAY['foo', 'bar'], ARRAY[1.0]) AS z (a, b, c);

SELECT
    *
FROM
    vw_ord;

SELECT
    definition
FROM
    pg_views
WHERE
    viewname = 'vw_ord';

DROP VIEW vw_ord;

CREATE TEMPORARY VIEW vw_ord AS
SELECT
    *
FROM
    rows
FROM (
        unnest(ARRAY[10, 20], ARRAY['foo', 'bar'], ARRAY[1.0])) AS z (a, b, c);

SELECT
    *
FROM
    vw_ord;

SELECT
    definition
FROM
    pg_views
WHERE
    viewname = 'vw_ord';

DROP VIEW vw_ord;

CREATE TEMPORARY VIEW vw_ord AS
SELECT
    *
FROM
    rows
FROM (
        unnest(ARRAY[10, 20], ARRAY['foo', 'bar']),
        generate_series(1, 2)) AS z (a, b, c);

SELECT
    *
FROM
    vw_ord;

SELECT
    definition
FROM
    pg_views
WHERE
    viewname = 'vw_ord';

DROP VIEW vw_ord;

-- ordinality and multiple functions vs. rewind and reverse scan
BEGIN;

DECLARE rf_cur scroll cursor FOR
SELECT
    *
FROM
    rows
FROM
    (generate_series(1, 5), generate_series(1, 2)) WITH ORDINALITY AS g (i, j, o);

FETCH ALL
FROM
    rf_cur;

FETCH backward ALL
FROM
    rf_cur;

FETCH ALL
FROM
    rf_cur;

FETCH NEXT
FROM
    rf_cur;

FETCH NEXT
FROM
    rf_cur;

FETCH prior
FROM
    rf_cur;

FETCH absolute 1
FROM
    rf_cur;

FETCH NEXT
FROM
    rf_cur;

FETCH NEXT
FROM
    rf_cur;

FETCH NEXT
FROM
    rf_cur;

FETCH prior
FROM
    rf_cur;

FETCH prior
FROM
    rf_cur;

FETCH prior
FROM
    rf_cur;

COMMIT;

-- function with implicit LATERAL
SELECT
    *
FROM
    rngfunc2,
    rngfunct (rngfunc2.rngfuncid) z
WHERE
    rngfunc2.f2 = z.f2;

-- function with implicit LATERAL and explicit ORDINALITY
SELECT
    *
FROM
    rngfunc2,
    rngfunct (rngfunc2.rngfuncid) WITH ORDINALITY AS z (rngfuncid, f2, ord)
WHERE
    rngfunc2.f2 = z.f2;

-- function in subselect
SELECT
    *
FROM
    rngfunc2
WHERE
    f2 IN (
        SELECT
            f2
        FROM
            rngfunct (rngfunc2.rngfuncid) z
        WHERE
            z.rngfuncid = rngfunc2.rngfuncid)
ORDER BY
    1,
    2;

-- function in subselect
SELECT
    *
FROM
    rngfunc2
WHERE
    f2 IN (
        SELECT
            f2
        FROM
            rngfunct (1) z
        WHERE
            z.rngfuncid = rngfunc2.rngfuncid)
ORDER BY
    1,
    2;

-- function in subselect
SELECT
    *
FROM
    rngfunc2
WHERE
    f2 IN (
        SELECT
            f2
        FROM
            rngfunct (rngfunc2.rngfuncid) z
        WHERE
            z.rngfuncid = 1)
ORDER BY
    1,
    2;

-- nested functions
SELECT
    rngfunct.rngfuncid,
    rngfunct.f2
FROM
    rngfunct (sin(pi() / 2)::int)
ORDER BY
    1,
    2;

CREATE TABLE rngfunc (
    rngfuncid int,
    rngfuncsubid int,
    rngfuncname text,
    PRIMARY KEY (rngfuncid, rngfuncsubid));

INSERT INTO
    rngfunc
VALUES
    (1, 1, 'Joe');

INSERT INTO
    rngfunc
VALUES
    (1, 2, 'Ed');

INSERT INTO
    rngfunc
VALUES
    (2, 1, 'Mary');

-- sql, proretset = f, prorettype = b
CREATE FUNCTION getrngfunc1 (int) RETURNS int AS 'SELECT $1;' LANGUAGE SQL;

SELECT
    *
FROM
    getrngfunc1 (1) AS t1;

SELECT
    *
FROM
    getrngfunc1 (1) WITH ORDINALITY AS t1 (v, o);

CREATE VIEW vw_getrngfunc AS
SELECT
    *
FROM
    getrngfunc1 (1);

SELECT
    *
FROM
    vw_getrngfunc;

DROP VIEW vw_getrngfunc;

CREATE VIEW vw_getrngfunc AS
SELECT
    *
FROM
    getrngfunc1 (1) WITH ORDINALITY AS t1 (v, o);

SELECT
    *
FROM
    vw_getrngfunc;

DROP VIEW vw_getrngfunc;

-- sql, proretset = t, prorettype = b
CREATE FUNCTION getrngfunc2 (int) RETURNS setof int AS 'SELECT rngfuncid FROM rngfunc WHERE rngfuncid = $1;' LANGUAGE SQL;

SELECT
    *
FROM
    getrngfunc2 (1) AS t1;

SELECT
    *
FROM
    getrngfunc2 (1) WITH ORDINALITY AS t1 (v, o);

CREATE VIEW vw_getrngfunc AS
SELECT
    *
FROM
    getrngfunc2 (1);

SELECT
    *
FROM
    vw_getrngfunc;

DROP VIEW vw_getrngfunc;

CREATE VIEW vw_getrngfunc AS
SELECT
    *
FROM
    getrngfunc2 (1) WITH ORDINALITY AS t1 (v, o);

SELECT
    *
FROM
    vw_getrngfunc;

DROP VIEW vw_getrngfunc;

-- sql, proretset = t, prorettype = b
CREATE FUNCTION getrngfunc3 (int) RETURNS setof text AS 'SELECT rngfuncname FROM rngfunc WHERE rngfuncid = $1;' LANGUAGE SQL;

SELECT
    *
FROM
    getrngfunc3 (1) AS t1;

SELECT
    *
FROM
    getrngfunc3 (1) WITH ORDINALITY AS t1 (v, o);

CREATE VIEW vw_getrngfunc AS
SELECT
    *
FROM
    getrngfunc3 (1);

SELECT
    *
FROM
    vw_getrngfunc;

DROP VIEW vw_getrngfunc;

CREATE VIEW vw_getrngfunc AS
SELECT
    *
FROM
    getrngfunc3 (1) WITH ORDINALITY AS t1 (v, o);

SELECT
    *
FROM
    vw_getrngfunc;

DROP VIEW vw_getrngfunc;

-- sql, proretset = f, prorettype = c
CREATE FUNCTION getrngfunc4 (int) RETURNS rngfunc AS 'SELECT * FROM rngfunc WHERE rngfuncid = $1;' LANGUAGE SQL;

SELECT
    *
FROM
    getrngfunc4 (1) AS t1;

SELECT
    *
FROM
    getrngfunc4 (1) WITH ORDINALITY AS t1 (a, b, c, o);

CREATE VIEW vw_getrngfunc AS
SELECT
    *
FROM
    getrngfunc4 (1);

SELECT
    *
FROM
    vw_getrngfunc;

DROP VIEW vw_getrngfunc;

CREATE VIEW vw_getrngfunc AS
SELECT
    *
FROM
    getrngfunc4 (1) WITH ORDINALITY AS t1 (a, b, c, o);

SELECT
    *
FROM
    vw_getrngfunc;

DROP VIEW vw_getrngfunc;

-- sql, proretset = t, prorettype = c
CREATE FUNCTION getrngfunc5 (int) RETURNS setof rngfunc AS 'SELECT * FROM rngfunc WHERE rngfuncid = $1;' LANGUAGE SQL;

SELECT
    *
FROM
    getrngfunc5 (1) AS t1;

SELECT
    *
FROM
    getrngfunc5 (1) WITH ORDINALITY AS t1 (a, b, c, o);

CREATE VIEW vw_getrngfunc AS
SELECT
    *
FROM
    getrngfunc5 (1);

SELECT
    *
FROM
    vw_getrngfunc;

DROP VIEW vw_getrngfunc;

CREATE VIEW vw_getrngfunc AS
SELECT
    *
FROM
    getrngfunc5 (1) WITH ORDINALITY AS t1 (a, b, c, o);

SELECT
    *
FROM
    vw_getrngfunc;

DROP VIEW vw_getrngfunc;

-- sql, proretset = f, prorettype = record
CREATE FUNCTION getrngfunc6 (int) RETURNS RECORD AS 'SELECT * FROM rngfunc WHERE rngfuncid = $1;' LANGUAGE SQL;

SELECT
    *
FROM
    getrngfunc6 (1) AS t1 (rngfuncid int, rngfuncsubid int, rngfuncname text);

SELECT
    *
FROM
    ROWS
FROM (
        getrngfunc6 (1) AS (rngfuncid int, rngfuncsubid int, rngfuncname text)) WITH ORDINALITY;

CREATE VIEW vw_getrngfunc AS
SELECT
    *
FROM
    getrngfunc6 (1) AS (rngfuncid int, rngfuncsubid int, rngfuncname text);

SELECT
    *
FROM
    vw_getrngfunc;

DROP VIEW vw_getrngfunc;

CREATE VIEW vw_getrngfunc AS
SELECT
    *
FROM
    ROWS
FROM (
        getrngfunc6 (1) AS (rngfuncid int, rngfuncsubid int, rngfuncname text)) WITH ORDINALITY;

SELECT
    *
FROM
    vw_getrngfunc;

DROP VIEW vw_getrngfunc;

-- sql, proretset = t, prorettype = record
CREATE FUNCTION getrngfunc7 (int) RETURNS setof record AS 'SELECT * FROM rngfunc WHERE rngfuncid = $1;' LANGUAGE SQL;

SELECT
    *
FROM
    getrngfunc7 (1) AS t1 (rngfuncid int, rngfuncsubid int, rngfuncname text);

SELECT
    *
FROM
    ROWS
FROM (
        getrngfunc7 (1) AS (rngfuncid int, rngfuncsubid int, rngfuncname text)) WITH ORDINALITY;

CREATE VIEW vw_getrngfunc AS
SELECT
    *
FROM
    getrngfunc7 (1) AS (rngfuncid int, rngfuncsubid int, rngfuncname text);

SELECT
    *
FROM
    vw_getrngfunc;

DROP VIEW vw_getrngfunc;

CREATE VIEW vw_getrngfunc AS
SELECT
    *
FROM
    ROWS
FROM (
        getrngfunc7 (1) AS (rngfuncid int, rngfuncsubid int, rngfuncname text)) WITH ORDINALITY;

SELECT
    *
FROM
    vw_getrngfunc;

DROP VIEW vw_getrngfunc;

-- plpgsql, proretset = f, prorettype = b
CREATE FUNCTION getrngfunc8 (int) RETURNS int AS 'DECLARE rngfuncint int; BEGIN SELECT rngfuncid into rngfuncint FROM rngfunc WHERE rngfuncid = $1; RETURN rngfuncint; END;' LANGUAGE plpgsql;

SELECT
    *
FROM
    getrngfunc8 (1) AS t1;

SELECT
    *
FROM
    getrngfunc8 (1) WITH ORDINALITY AS t1 (v, o);

CREATE VIEW vw_getrngfunc AS
SELECT
    *
FROM
    getrngfunc8 (1);

SELECT
    *
FROM
    vw_getrngfunc;

DROP VIEW vw_getrngfunc;

CREATE VIEW vw_getrngfunc AS
SELECT
    *
FROM
    getrngfunc8 (1) WITH ORDINALITY AS t1 (v, o);

SELECT
    *
FROM
    vw_getrngfunc;

DROP VIEW vw_getrngfunc;

-- plpgsql, proretset = f, prorettype = c
CREATE FUNCTION getrngfunc9 (int) RETURNS rngfunc AS 'DECLARE rngfunctup rngfunc%ROWTYPE; BEGIN SELECT * into rngfunctup FROM rngfunc WHERE rngfuncid = $1; RETURN rngfunctup; END;' LANGUAGE plpgsql;

SELECT
    *
FROM
    getrngfunc9 (1) AS t1;

SELECT
    *
FROM
    getrngfunc9 (1) WITH ORDINALITY AS t1 (a, b, c, o);

CREATE VIEW vw_getrngfunc AS
SELECT
    *
FROM
    getrngfunc9 (1);

SELECT
    *
FROM
    vw_getrngfunc;

DROP VIEW vw_getrngfunc;

CREATE VIEW vw_getrngfunc AS
SELECT
    *
FROM
    getrngfunc9 (1) WITH ORDINALITY AS t1 (a, b, c, o);

SELECT
    *
FROM
    vw_getrngfunc;

DROP VIEW vw_getrngfunc;

-- mix 'n match kinds, to exercise expandRTE and related logic
SELECT
    *
FROM
    rows
FROM (
        getrngfunc1 (1),
        getrngfunc2 (1),
        getrngfunc3 (1),
        getrngfunc4 (1),
        getrngfunc5 (1),
        getrngfunc6 (1) AS (rngfuncid int, rngfuncsubid int, rngfuncname text),
        getrngfunc7 (1) AS (rngfuncid int, rngfuncsubid int, rngfuncname text),
        getrngfunc8 (1),
        getrngfunc9 (1)) WITH ORDINALITY AS t1 (
        a,
        b,
        c,
        d,
        e,
        f,
        g,
        h,
        i,
        j,
        k,
        l,
        m,
        o,
        p,
        q,
        r,
        s,
        t,
        u);

SELECT
    *
FROM
    rows
FROM (
        getrngfunc9 (1),
        getrngfunc8 (1),
        getrngfunc7 (1) AS (rngfuncid int, rngfuncsubid int, rngfuncname text),
        getrngfunc6 (1) AS (rngfuncid int, rngfuncsubid int, rngfuncname text),
        getrngfunc5 (1),
        getrngfunc4 (1),
        getrngfunc3 (1),
        getrngfunc2 (1),
        getrngfunc1 (1)) WITH ORDINALITY AS t1 (
        a,
        b,
        c,
        d,
        e,
        f,
        g,
        h,
        i,
        j,
        k,
        l,
        m,
        o,
        p,
        q,
        r,
        s,
        t,
        u);

CREATE TEMPORARY VIEW vw_rngfunc AS
SELECT
    *
FROM
    rows
FROM (
        getrngfunc9 (1),
        getrngfunc7 (1) AS (rngfuncid int, rngfuncsubid int, rngfuncname text),
        getrngfunc1 (1)) WITH ORDINALITY AS t1 (a, b, c, d, e, f, g, n);

SELECT
    *
FROM
    vw_rngfunc;

SELECT
    pg_get_viewdef('vw_rngfunc');

DROP VIEW vw_rngfunc;

DROP FUNCTION getrngfunc1 (int);

DROP FUNCTION getrngfunc2 (int);

DROP FUNCTION getrngfunc3 (int);

DROP FUNCTION getrngfunc4 (int);

DROP FUNCTION getrngfunc5 (int);

DROP FUNCTION getrngfunc6 (int);

DROP FUNCTION getrngfunc7 (int);

DROP FUNCTION getrngfunc8 (int);

DROP FUNCTION getrngfunc9 (int);

DROP FUNCTION rngfunct (int);

DROP TABLE rngfunc2;

DROP TABLE rngfunc;

-- Rescan tests --
CREATE TEMPORARY SEQUENCE rngfunc_rescan_seq1;

CREATE TEMPORARY SEQUENCE rngfunc_rescan_seq2;

CREATE TYPE rngfunc_rescan_t AS (i integer, s bigint);

CREATE FUNCTION rngfunc_sql (int, int) RETURNS setof rngfunc_rescan_t AS 'SELECT i, nextval(''rngfunc_rescan_seq1'') FROM generate_series($1,$2) i;' LANGUAGE SQL;

-- plpgsql functions use materialize mode
CREATE FUNCTION rngfunc_mat (int, int) RETURNS setof rngfunc_rescan_t AS 'begin for i in $1..$2 loop return next (i, nextval(''rngfunc_rescan_seq2'')); end loop; end;' LANGUAGE plpgsql;

--invokes ExecReScanFunctionScan - all these cases should materialize the function only once
-- LEFT JOIN on a condition that the planner can't prove to be true is used to ensure the function
-- is on the inner path of a nestloop join
SELECT
    setval('rngfunc_rescan_seq1', 1, FALSE),
    setval('rngfunc_rescan_seq2', 1, FALSE);

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r)
    LEFT JOIN rngfunc_sql (11, 13) ON (r + i) < 100;

SELECT
    setval('rngfunc_rescan_seq1', 1, FALSE),
    setval('rngfunc_rescan_seq2', 1, FALSE);

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r)
    LEFT JOIN rngfunc_sql (11, 13) WITH ORDINALITY AS f (i, s, o) ON (r + i) < 100;

SELECT
    setval('rngfunc_rescan_seq1', 1, FALSE),
    setval('rngfunc_rescan_seq2', 1, FALSE);

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r)
    LEFT JOIN rngfunc_mat (11, 13) ON (r + i) < 100;

SELECT
    setval('rngfunc_rescan_seq1', 1, FALSE),
    setval('rngfunc_rescan_seq2', 1, FALSE);

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r)
    LEFT JOIN rngfunc_mat (11, 13) WITH ORDINALITY AS f (i, s, o) ON (r + i) < 100;

SELECT
    setval('rngfunc_rescan_seq1', 1, FALSE),
    setval('rngfunc_rescan_seq2', 1, FALSE);

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r)
    LEFT JOIN ROWS
FROM
    (rngfunc_sql (11, 13), rngfunc_mat (11, 13)) WITH ORDINALITY AS f (i1, s1, i2, s2, o) ON (r + i1 + i2) < 100;

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r)
    LEFT JOIN generate_series(11, 13) f (i) ON (r + i) < 100;

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r)
    LEFT JOIN generate_series(11, 13) WITH ORDINALITY AS f (i, o) ON (r + i) < 100;

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r)
    LEFT JOIN unnest(ARRAY[10, 20, 30]) f (i) ON (r + i) < 100;

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r)
    LEFT JOIN unnest(ARRAY[10, 20, 30]) WITH ORDINALITY AS f (i, o) ON (r + i) < 100;

--invokes ExecReScanFunctionScan with chgParam != NULL (using implied LATERAL)
SELECT
    setval('rngfunc_rescan_seq1', 1, FALSE),
    setval('rngfunc_rescan_seq2', 1, FALSE);

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r),
    rngfunc_sql (10 + r, 13);

SELECT
    setval('rngfunc_rescan_seq1', 1, FALSE),
    setval('rngfunc_rescan_seq2', 1, FALSE);

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r),
    rngfunc_sql (10 + r, 13) WITH ORDINALITY AS f (i, s, o);

SELECT
    setval('rngfunc_rescan_seq1', 1, FALSE),
    setval('rngfunc_rescan_seq2', 1, FALSE);

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r),
    rngfunc_sql (11, 10 + r);

SELECT
    setval('rngfunc_rescan_seq1', 1, FALSE),
    setval('rngfunc_rescan_seq2', 1, FALSE);

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r),
    rngfunc_sql (11, 10 + r) WITH ORDINALITY AS f (i, s, o);

SELECT
    setval('rngfunc_rescan_seq1', 1, FALSE),
    setval('rngfunc_rescan_seq2', 1, FALSE);

SELECT
    *
FROM (
        VALUES
            (11, 12),
            (13, 15),
            (16, 20)) v (r1, r2),
    rngfunc_sql (r1, r2);

SELECT
    setval('rngfunc_rescan_seq1', 1, FALSE),
    setval('rngfunc_rescan_seq2', 1, FALSE);

SELECT
    *
FROM (
        VALUES
            (11, 12),
            (13, 15),
            (16, 20)) v (r1, r2),
    rngfunc_sql (r1, r2) WITH ORDINALITY AS f (i, s, o);

SELECT
    setval('rngfunc_rescan_seq1', 1, FALSE),
    setval('rngfunc_rescan_seq2', 1, FALSE);

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r),
    rngfunc_mat (10 + r, 13);

SELECT
    setval('rngfunc_rescan_seq1', 1, FALSE),
    setval('rngfunc_rescan_seq2', 1, FALSE);

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r),
    rngfunc_mat (10 + r, 13) WITH ORDINALITY AS f (i, s, o);

SELECT
    setval('rngfunc_rescan_seq1', 1, FALSE),
    setval('rngfunc_rescan_seq2', 1, FALSE);

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r),
    rngfunc_mat (11, 10 + r);

SELECT
    setval('rngfunc_rescan_seq1', 1, FALSE),
    setval('rngfunc_rescan_seq2', 1, FALSE);

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r),
    rngfunc_mat (11, 10 + r) WITH ORDINALITY AS f (i, s, o);

SELECT
    setval('rngfunc_rescan_seq1', 1, FALSE),
    setval('rngfunc_rescan_seq2', 1, FALSE);

SELECT
    *
FROM (
        VALUES
            (11, 12),
            (13, 15),
            (16, 20)) v (r1, r2),
    rngfunc_mat (r1, r2);

SELECT
    setval('rngfunc_rescan_seq1', 1, FALSE),
    setval('rngfunc_rescan_seq2', 1, FALSE);

SELECT
    *
FROM (
        VALUES
            (11, 12),
            (13, 15),
            (16, 20)) v (r1, r2),
    rngfunc_mat (r1, r2) WITH ORDINALITY AS f (i, s, o);

-- selective rescan of multiple functions:
SELECT
    setval('rngfunc_rescan_seq1', 1, FALSE),
    setval('rngfunc_rescan_seq2', 1, FALSE);

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r),
    ROWS
FROM
    (rngfunc_sql (11, 11), rngfunc_mat (10 + r, 13));

SELECT
    setval('rngfunc_rescan_seq1', 1, FALSE),
    setval('rngfunc_rescan_seq2', 1, FALSE);

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r),
    ROWS
FROM
    (rngfunc_sql (10 + r, 13), rngfunc_mat (11, 11));

SELECT
    setval('rngfunc_rescan_seq1', 1, FALSE),
    setval('rngfunc_rescan_seq2', 1, FALSE);

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r),
    ROWS
FROM (
        rngfunc_sql (10 + r, 13),
        rngfunc_mat (10 + r, 13));

SELECT
    setval('rngfunc_rescan_seq1', 1, FALSE),
    setval('rngfunc_rescan_seq2', 1, FALSE);

SELECT
    *
FROM
    generate_series(1, 2) r1,
    generate_series(r1, 3) r2,
    ROWS
FROM (
        rngfunc_sql (10 + r1, 13),
        rngfunc_mat (10 + r2, 13));

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r),
    generate_series(10 + r, 20 - r) f (i);

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r),
    generate_series(10 + r, 20 - r) WITH ORDINALITY AS f (i, o);

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r),
    unnest(ARRAY[r * 10, r * 20, r * 30]) f (i);

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v (r),
    unnest(ARRAY[r * 10, r * 20, r * 30]) WITH ORDINALITY AS f (i, o);

-- deep nesting
SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v1 (r1),
    LATERAL (
        SELECT
            r1,
            *
        FROM (
                VALUES
                    (10),
                    (20),
                    (30)) v2 (r2)
            LEFT JOIN generate_series(21, 23) f (i) ON ((r2 + i) < 100)
        OFFSET
            0) s1;

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v1 (r1),
    LATERAL (
        SELECT
            r1,
            *
        FROM (
                VALUES
                    (10),
                    (20),
                    (30)) v2 (r2)
            LEFT JOIN generate_series(20 + r1, 23) f (i) ON ((r2 + i) < 100)
        OFFSET
            0) s1;

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v1 (r1),
    LATERAL (
        SELECT
            r1,
            *
        FROM (
                VALUES
                    (10),
                    (20),
                    (30)) v2 (r2)
            LEFT JOIN generate_series(r2, r2 + 3) f (i) ON ((r2 + i) < 100)
        OFFSET
            0) s1;

SELECT
    *
FROM (
        VALUES
            (1),
            (2),
            (3)) v1 (r1),
    LATERAL (
        SELECT
            r1,
            *
        FROM (
                VALUES
                    (10),
                    (20),
                    (30)) v2 (r2)
            LEFT JOIN generate_series(r1, 2 + r2 / 5) f (i) ON ((r2 + i) < 100)
        OFFSET
            0) s1;

-- check handling of FULL JOIN with multiple lateral references (bug #15741)
SELECT
    *
FROM (
        VALUES
            (1),
            (2)) v1 (r1)
    LEFT JOIN LATERAL (
        SELECT
            *
        FROM
            generate_series(1, v1.r1) AS gs1
            LEFT JOIN LATERAL (
                SELECT
                    *
                FROM
                    generate_series(1, gs1) AS gs2
                    LEFT JOIN generate_series(1, gs2) AS gs3 ON TRUE) AS ss1 ON TRUE
            FULL JOIN generate_series(1, v1.r1) AS gs4 ON FALSE) AS ss0 ON TRUE;

DROP FUNCTION rngfunc_sql (int, int);

DROP FUNCTION rngfunc_mat (int, int);

DROP SEQUENCE rngfunc_rescan_seq1;

DROP SEQUENCE rngfunc_rescan_seq2;

--
-- Test cases involving OUT parameters
--
CREATE FUNCTION rngfunc (IN f1 int, OUT f2 int) AS 'select $1+1' LANGUAGE sql;

SELECT
    rngfunc (42);

SELECT
    *
FROM
    rngfunc (42);

SELECT
    *
FROM
    rngfunc (42) AS p (x);

-- explicit spec of return type is OK
CREATE OR REPLACE FUNCTION rngfunc (IN f1 int, OUT f2 int) RETURNS int AS 'select $1+1' LANGUAGE sql;

-- error, wrong result type
CREATE OR REPLACE FUNCTION rngfunc (IN f1 int, OUT f2 int) RETURNS float AS 'select $1+1' LANGUAGE sql;

-- with multiple OUT params you must get a RECORD result
CREATE OR REPLACE FUNCTION rngfunc (IN f1 int, OUT f2 int, OUT f3 text) RETURNS int AS 'select $1+1' LANGUAGE sql;

CREATE OR REPLACE FUNCTION rngfunc (IN f1 int, OUT f2 int, OUT f3 text) RETURNS record AS 'select $1+1' LANGUAGE sql;

CREATE OR REPLACE FUNCTION rngfuncr (IN f1 int, OUT f2 int, OUT text) AS $$select $1-1, $1::text || 'z'$$ LANGUAGE sql;

SELECT
    f1,
    rngfuncr (f1)
FROM
    int4_tbl;

SELECT
    *
FROM
    rngfuncr (42);

SELECT
    *
FROM
    rngfuncr (42) AS p (a, b);

CREATE OR REPLACE FUNCTION rngfuncb (IN f1 int, INOUT f2 int, OUT text) AS $$select $2-1, $1::text || 'z'$$ LANGUAGE sql;

SELECT
    f1,
    rngfuncb (f1, f1 / 2)
FROM
    int4_tbl;

SELECT
    *
FROM
    rngfuncb (42, 99);

SELECT
    *
FROM
    rngfuncb (42, 99) AS p (a, b);

-- Can reference function with or without OUT params for DROP, etc
DROP FUNCTION rngfunc (int);

DROP FUNCTION rngfuncr (IN f2 int, OUT f1 int, OUT text);

DROP FUNCTION rngfuncb (IN f1 int, INOUT f2 int);

--
-- For my next trick, polymorphic OUT parameters
--
CREATE FUNCTION dup (f1 anyelement, f2 OUT anyelement, f3 OUT anyarray) AS 'select $1, array[$1,$1]' LANGUAGE sql;

SELECT
    dup (22);

SELECT
    dup ('xyz');

-- fails
SELECT
    dup ('xyz'::text);

SELECT
    *
FROM
    dup ('xyz'::text);

-- fails, as we are attempting to rename first argument
CREATE OR REPLACE FUNCTION dup (INOUT f2 anyelement, OUT f3 anyarray) AS 'select $1, array[$1,$1]' LANGUAGE sql;

DROP FUNCTION dup (anyelement);

-- equivalent behavior, though different name exposed for input arg
CREATE OR REPLACE FUNCTION dup (INOUT f2 anyelement, OUT f3 anyarray) AS 'select $1, array[$1,$1]' LANGUAGE sql;

SELECT
    dup (22);

DROP FUNCTION dup (anyelement);

-- fails, no way to deduce outputs
CREATE FUNCTION bad (f1 int, OUT f2 anyelement, OUT f3 anyarray) AS 'select $1, array[$1,$1]' LANGUAGE sql;

--
-- table functions
--
CREATE OR REPLACE FUNCTION rngfunc () RETURNS TABLE (a int) AS $$ SELECT a FROM generate_series(1,5) a(a) $$ LANGUAGE sql;

SELECT
    *
FROM
    rngfunc ();

DROP FUNCTION rngfunc ();

CREATE OR REPLACE FUNCTION rngfunc (int) RETURNS TABLE (a int, b int) AS $$ SELECT a, b
         FROM generate_series(1,$1) a(a),
              generate_series(1,$1) b(b) $$ LANGUAGE sql;

SELECT
    *
FROM
    rngfunc (3);

DROP FUNCTION rngfunc (int);

-- case that causes change of typmod knowledge during inlining
CREATE OR REPLACE FUNCTION rngfunc () RETURNS TABLE (a varchar(5)) AS $$ SELECT 'hello'::varchar(5) $$ LANGUAGE sql STABLE;

SELECT
    *
FROM
    rngfunc ()
GROUP BY
    1;

DROP FUNCTION rngfunc ();

--
-- some tests on SQL functions with RETURNING
--
CREATE TEMP TABLE tt (f1 serial, data text);

CREATE FUNCTION insert_tt (text) returns int AS $$ insert into tt(data) values($1) returning f1 $$ language sql;

SELECT
    insert_tt ('foo');

SELECT
    insert_tt ('bar');

SELECT
    *
FROM
    tt;

-- insert will execute to completion even if function needs just 1 row
CREATE OR REPLACE FUNCTION insert_tt (text) returns int AS $$ insert into tt(data) values($1),($1||$1) returning f1 $$ language sql;

SELECT
    insert_tt ('fool');

SELECT
    *
FROM
    tt;

-- setof does what's expected
CREATE OR REPLACE FUNCTION insert_tt2 (text, text) returns setof int AS $$ insert into tt(data) values($1),($2) returning f1 $$ language sql;

SELECT
    insert_tt2 ('foolish', 'barrish');

SELECT
    *
FROM
    insert_tt2 ('baz', 'quux');

SELECT
    *
FROM
    tt;

-- limit doesn't prevent execution to completion
SELECT
    insert_tt2 ('foolish', 'barrish')
LIMIT
    1;

SELECT
    *
FROM
    tt;

-- triggers will fire, too
CREATE FUNCTION noticetrigger () returns trigger AS $$
begin
  raise notice 'noticetrigger % %', new.f1, new.data;
  return null;
end $$ language plpgsql;

CREATE TRIGGER tnoticetrigger
AFTER insert ON tt FOR each ROW
EXECUTE procedure noticetrigger ();

SELECT
    insert_tt2 ('foolme', 'barme')
LIMIT
    1;

SELECT
    *
FROM
    tt;

-- and rules work
CREATE TEMP TABLE tt_log (f1 int, data text);

CREATE RULE insert_tt_rule AS ON insert TO tt DO also
INSERT INTO
    tt_log
VALUES
    (new.*);

SELECT
    insert_tt2 ('foollog', 'barlog')
LIMIT
    1;

SELECT
    *
FROM
    tt;

-- note that nextval() gets executed a second time in the rule expansion,
-- which is expected.
SELECT
    *
FROM
    tt_log;

-- test case for a whole-row-variable bug
CREATE FUNCTION rngfunc1 (n integer, OUT a text, OUT b text) returns setof record language sql AS $$ select 'foo ' || i, 'bar ' || i from generate_series(1,$1) i $$;

SET
    work_mem = '64kB';

SELECT
    t.a,
    t,
    t.a
FROM
    rngfunc1 (10000) t
LIMIT
    1;

RESET work_mem;

SELECT
    t.a,
    t,
    t.a
FROM
    rngfunc1 (10000) t
LIMIT
    1;

DROP FUNCTION rngfunc1 (n integer);

-- test use of SQL functions returning record
-- this is supported in some cases where the query doesn't specify
-- the actual record type ...
CREATE FUNCTION array_to_set (anyarray) returns setof record AS $$
  select i AS "index", $1[i] AS "value" from generate_subscripts($1, 1) i
$$ language sql strict immutable;

SELECT
    array_to_set (ARRAY['one', 'two']);

SELECT
    *
FROM
    array_to_set (ARRAY['one', 'two']) AS t (f1 int, f2 text);

SELECT
    *
FROM
    array_to_set (ARRAY['one', 'two']);

-- fail
CREATE TEMP TABLE rngfunc (f1 int8, f2 int8);

CREATE FUNCTION testrngfunc () returns record AS $$
  insert into rngfunc values (1,2) returning *;
$$ language sql;

SELECT
    testrngfunc ();

SELECT
    *
FROM
    testrngfunc () AS t (f1 int8, f2 int8);

SELECT
    *
FROM
    testrngfunc ();

-- fail
DROP FUNCTION testrngfunc ();

CREATE FUNCTION testrngfunc () returns setof record AS $$
  insert into rngfunc values (1,2), (3,4) returning *;
$$ language sql;

SELECT
    testrngfunc ();

SELECT
    *
FROM
    testrngfunc () AS t (f1 int8, f2 int8);

SELECT
    *
FROM
    testrngfunc ();

-- fail
DROP FUNCTION testrngfunc ();

--
-- Check some cases involving added/dropped columns in a rowtype result
--
CREATE TEMP TABLE users (
    userid text,
    seq int,
    email text,
    todrop bool,
    moredrop int,
    enabled bool);

INSERT INTO
    users
VALUES
    ('id', 1, 'email', TRUE, 11, TRUE);

INSERT INTO
    users
VALUES
    ('id2', 2, 'email2', TRUE, 12, TRUE);

ALTER TABLE users
DROP COLUMN todrop;

CREATE OR REPLACE FUNCTION get_first_user () returns users AS $$ SELECT * FROM users ORDER BY userid LIMIT 1; $$ language sql stable;

SELECT
    get_first_user ();

SELECT
    *
FROM
    get_first_user ();

CREATE OR REPLACE FUNCTION get_users () returns setof users AS $$ SELECT * FROM users ORDER BY userid; $$ language sql stable;

SELECT
    get_users ();

SELECT
    *
FROM
    get_users ();

SELECT
    *
FROM
    get_users () WITH ORDINALITY;

-- make sure ordinality copes
-- multiple functions vs. dropped columns
SELECT
    *
FROM
    ROWS
FROM
    (generate_series(10, 11), get_users ()) WITH ORDINALITY;

SELECT
    *
FROM
    ROWS
FROM
    (get_users (), generate_series(10, 11)) WITH ORDINALITY;

-- check that we can cope with post-parsing changes in rowtypes
CREATE TEMP VIEW usersview AS
SELECT
    *
FROM
    ROWS
FROM
    (get_users (), generate_series(10, 11)) WITH ORDINALITY;

SELECT
    *
FROM
    usersview;

ALTER TABLE users
ADD COLUMN junk text;

SELECT
    *
FROM
    usersview;

BEGIN;

ALTER TABLE users
DROP COLUMN moredrop;

SELECT
    *
FROM
    usersview;

-- expect clean failure
ROLLBACK;

ALTER TABLE users
ALTER COLUMN seq type numeric;

SELECT
    *
FROM
    usersview;

-- expect clean failure
DROP VIEW usersview;

DROP FUNCTION get_first_user ();

DROP FUNCTION get_users ();

DROP TABLE users;

-- this won't get inlined because of type coercion, but it shouldn't fail
CREATE OR REPLACE FUNCTION rngfuncbar () returns setof text AS $$ select 'foo'::varchar union all select 'bar'::varchar ; $$ language sql stable;

SELECT
    rngfuncbar ();

SELECT
    *
FROM
    rngfuncbar ();

DROP FUNCTION rngfuncbar ();

-- check handling of a SQL function with multiple OUT params (bug #5777)
CREATE OR REPLACE FUNCTION rngfuncbar (OUT integer, OUT numeric) AS $$ select (1, 2.1) $$ language sql;

SELECT
    *
FROM
    rngfuncbar ();

CREATE OR REPLACE FUNCTION rngfuncbar (OUT integer, OUT numeric) AS $$ select (1, 2) $$ language sql;

SELECT
    *
FROM
    rngfuncbar ();

-- fail
CREATE OR REPLACE FUNCTION rngfuncbar (OUT integer, OUT numeric) AS $$ select (1, 2.1, 3) $$ language sql;

SELECT
    *
FROM
    rngfuncbar ();

-- fail
DROP FUNCTION rngfuncbar ();

-- check whole-row-Var handling in nested lateral functions (bug #11703)
CREATE FUNCTION extractq2 (t int8_tbl) returns int8 AS $$
  select t.q2
$$ language sql immutable;

EXPLAIN (VERBOSE, costs off)
SELECT
    x
FROM
    int8_tbl,
    extractq2 (int8_tbl) f (x);

SELECT
    x
FROM
    int8_tbl,
    extractq2 (int8_tbl) f (x);

CREATE FUNCTION extractq2_2 (t int8_tbl) returns TABLE (ret1 int8) AS $$
  select extractq2(t) offset 0
$$ language sql immutable;

EXPLAIN (VERBOSE, costs off)
SELECT
    x
FROM
    int8_tbl,
    extractq2_2 (int8_tbl) f (x);

SELECT
    x
FROM
    int8_tbl,
    extractq2_2 (int8_tbl) f (x);

-- without the "offset 0", this function gets optimized quite differently
CREATE FUNCTION extractq2_2_opt (t int8_tbl) returns TABLE (ret1 int8) AS $$
  select extractq2(t)
$$ language sql immutable;

EXPLAIN (VERBOSE, costs off)
SELECT
    x
FROM
    int8_tbl,
    extractq2_2_opt (int8_tbl) f (x);

SELECT
    x
FROM
    int8_tbl,
    extractq2_2_opt (int8_tbl) f (x);

-- check handling of nulls in SRF results (bug #7808)
CREATE TYPE rngfunc2 AS (a integer, b text);

SELECT
    *,
    row_to_json(u)
FROM
    unnest(ARRAY[(1, 'foo')::rngfunc2, NULL::rngfunc2]) u;

SELECT
    *,
    row_to_json(u)
FROM
    unnest(ARRAY[NULL::rngfunc2, NULL::rngfunc2]) u;

SELECT
    *,
    row_to_json(u)
FROM
    unnest (
        ARRAY [
            NULL::rngfunc2,
            (1, 'foo')::rngfunc2,
            NULL::rngfunc2]) u;

SELECT
    *,
    row_to_json(u)
FROM
    unnest(ARRAY[]::rngfunc2[]) u;

DROP TYPE rngfunc2;