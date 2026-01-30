-- Currently this tests polymorphic aggregates and indirectly does some
-- testing of polymorphic SQL functions.  It ought to be extended.
-- Tests for other features related to function-calling have snuck in, too.
-- Legend:
-----------
-- A = type is ANY
-- P = type is polymorphic
-- N = type is non-polymorphic
-- B = aggregate base type
-- S = aggregate state type
-- R = aggregate return type
-- 1 = arg1 of a function
-- 2 = arg2 of a function
-- ag = aggregate
-- tf = trans (state) function
-- ff = final function
-- rt = return type of a function
-- -> = implies
-- => = allowed
-- !> = not allowed
-- E  = exists
-- NE = not-exists
--
-- Possible states:
-- ----------------
-- B = (A || P || N)
--   when (B = A) -> (tf2 = NE)
-- S = (P || N)
-- ff = (E || NE)
-- tf1 = (P || N)
-- tf2 = (NE || P || N)
-- R = (P || N)
-- create functions for use as tf and ff with the needed combinations of
-- argument polymorphism, but within the constraints of valid aggregate
-- functions, i.e. tf arg1 and tf return type must match
-- polymorphic single arg transfn
CREATE FUNCTION stfp (anyarray) RETURNS anyarray AS 'select $1' LANGUAGE SQL;

-- non-polymorphic single arg transfn
CREATE FUNCTION stfnp (INT[]) RETURNS INT[] AS 'select $1' LANGUAGE SQL;

-- dual polymorphic transfn
CREATE FUNCTION tfp (anyarray, anyelement) RETURNS anyarray AS 'select $1 || $2' LANGUAGE SQL;

-- dual non-polymorphic transfn
CREATE FUNCTION tfnp (INT[], int) RETURNS INT[] AS 'select $1 || $2' LANGUAGE SQL;

-- arg1 only polymorphic transfn
CREATE FUNCTION tf1p (anyarray, int) RETURNS anyarray AS 'select $1' LANGUAGE SQL;

-- arg2 only polymorphic transfn
CREATE FUNCTION tf2p (INT[], anyelement) RETURNS INT[] AS 'select $1' LANGUAGE SQL;

-- multi-arg polymorphic
CREATE FUNCTION sum3 (anyelement, anyelement, anyelement) returns anyelement AS 'select $1+$2+$3' language sql strict;

-- finalfn polymorphic
CREATE FUNCTION ffp (anyarray) RETURNS anyarray AS 'select $1' LANGUAGE SQL;

-- finalfn non-polymorphic
CREATE FUNCTION ffnp (INT[]) returns INT[] AS 'select $1' LANGUAGE SQL;

-- Try to cover all the possible states:
--
-- Note: in Cases 1 & 2, we are trying to return P. Therefore, if the transfn
-- is stfnp, tfnp, or tf2p, we must use ffp as finalfn, because stfnp, tfnp,
-- and tf2p do not return P. Conversely, in Cases 3 & 4, we are trying to
-- return N. Therefore, if the transfn is stfp, tfp, or tf1p, we must use ffnp
-- as finalfn, because stfp, tfp, and tf1p do not return N.
--
--     Case1 (R = P) && (B = A)
--     ------------------------
--     S    tf1
--     -------
--     N    N
-- should CREATE
CREATE AGGREGATE myaggp01a (*) (
    SFUNC = stfnp,
    STYPE = int4[],
    FINALFUNC = ffp,
    INITCOND = '{}');

--     P    N
-- should ERROR: stfnp(anyarray) not matched by stfnp(int[])
CREATE AGGREGATE myaggp02a (*) (
    SFUNC = stfnp,
    STYPE = anyarray,
    FINALFUNC = ffp,
    INITCOND = '{}');

--     N    P
-- should CREATE
CREATE AGGREGATE myaggp03a (*) (
    SFUNC = stfp,
    STYPE = int4[],
    FINALFUNC = ffp,
    INITCOND = '{}');

CREATE AGGREGATE myaggp03b (*) (SFUNC = stfp, STYPE = int4[], INITCOND = '{}');

--     P    P
-- should ERROR: we have no way to resolve S
CREATE AGGREGATE myaggp04a (*) (
    SFUNC = stfp,
    STYPE = anyarray,
    FINALFUNC = ffp,
    INITCOND = '{}');

CREATE AGGREGATE myaggp04b (*) (SFUNC = stfp, STYPE = anyarray, INITCOND = '{}');

--    Case2 (R = P) && ((B = P) || (B = N))
--    -------------------------------------
--    S    tf1      B    tf2
--    -----------------------
--    N    N        N    N
-- should CREATE
CREATE AGGREGATE myaggp05a (
    BASETYPE = int,
    SFUNC = tfnp,
    STYPE = INT[],
    FINALFUNC = ffp,
    INITCOND = '{}');

--    N    N        N    P
-- should CREATE
CREATE AGGREGATE myaggp06a (
    BASETYPE = int,
    SFUNC = tf2p,
    STYPE = INT[],
    FINALFUNC = ffp,
    INITCOND = '{}');

--    N    N        P    N
-- should ERROR: tfnp(int[], anyelement) not matched by tfnp(int[], int)
CREATE AGGREGATE myaggp07a (
    BASETYPE = anyelement,
    SFUNC = tfnp,
    STYPE = INT[],
    FINALFUNC = ffp,
    INITCOND = '{}');

--    N    N        P    P
-- should CREATE
CREATE AGGREGATE myaggp08a (
    BASETYPE = anyelement,
    SFUNC = tf2p,
    STYPE = INT[],
    FINALFUNC = ffp,
    INITCOND = '{}');

--    N    P        N    N
-- should CREATE
CREATE AGGREGATE myaggp09a (
    BASETYPE = int,
    SFUNC = tf1p,
    STYPE = INT[],
    FINALFUNC = ffp,
    INITCOND = '{}');

CREATE AGGREGATE myaggp09b (
    BASETYPE = int,
    SFUNC = tf1p,
    STYPE = INT[],
    INITCOND = '{}');

--    N    P        N    P
-- should CREATE
CREATE AGGREGATE myaggp10a (
    BASETYPE = int,
    SFUNC = tfp,
    STYPE = INT[],
    FINALFUNC = ffp,
    INITCOND = '{}');

CREATE AGGREGATE myaggp10b (
    BASETYPE = int,
    SFUNC = tfp,
    STYPE = INT[],
    INITCOND = '{}');

--    N    P        P    N
-- should ERROR: tf1p(int[],anyelement) not matched by tf1p(anyarray,int)
CREATE AGGREGATE myaggp11a (
    BASETYPE = anyelement,
    SFUNC = tf1p,
    STYPE = INT[],
    FINALFUNC = ffp,
    INITCOND = '{}');

CREATE AGGREGATE myaggp11b (
    BASETYPE = anyelement,
    SFUNC = tf1p,
    STYPE = INT[],
    INITCOND = '{}');

--    N    P        P    P
-- should ERROR: tfp(int[],anyelement) not matched by tfp(anyarray,anyelement)
CREATE AGGREGATE myaggp12a (
    BASETYPE = anyelement,
    SFUNC = tfp,
    STYPE = INT[],
    FINALFUNC = ffp,
    INITCOND = '{}');

CREATE AGGREGATE myaggp12b (
    BASETYPE = anyelement,
    SFUNC = tfp,
    STYPE = INT[],
    INITCOND = '{}');

--    P    N        N    N
-- should ERROR: tfnp(anyarray, int) not matched by tfnp(int[],int)
CREATE AGGREGATE myaggp13a (
    BASETYPE = int,
    SFUNC = tfnp,
    STYPE = anyarray,
    FINALFUNC = ffp,
    INITCOND = '{}');

--    P    N        N    P
-- should ERROR: tf2p(anyarray, int) not matched by tf2p(int[],anyelement)
CREATE AGGREGATE myaggp14a (
    BASETYPE = int,
    SFUNC = tf2p,
    STYPE = anyarray,
    FINALFUNC = ffp,
    INITCOND = '{}');

--    P    N        P    N
-- should ERROR: tfnp(anyarray, anyelement) not matched by tfnp(int[],int)
CREATE AGGREGATE myaggp15a (
    BASETYPE = anyelement,
    SFUNC = tfnp,
    STYPE = anyarray,
    FINALFUNC = ffp,
    INITCOND = '{}');

--    P    N        P    P
-- should ERROR: tf2p(anyarray, anyelement) not matched by tf2p(int[],anyelement)
CREATE AGGREGATE myaggp16a (
    BASETYPE = anyelement,
    SFUNC = tf2p,
    STYPE = anyarray,
    FINALFUNC = ffp,
    INITCOND = '{}');

--    P    P        N    N
-- should ERROR: we have no way to resolve S
CREATE AGGREGATE myaggp17a (
    BASETYPE = int,
    SFUNC = tf1p,
    STYPE = anyarray,
    FINALFUNC = ffp,
    INITCOND = '{}');

CREATE AGGREGATE myaggp17b (
    BASETYPE = int,
    SFUNC = tf1p,
    STYPE = anyarray,
    INITCOND = '{}');

--    P    P        N    P
-- should ERROR: tfp(anyarray, int) not matched by tfp(anyarray, anyelement)
CREATE AGGREGATE myaggp18a (
    BASETYPE = int,
    SFUNC = tfp,
    STYPE = anyarray,
    FINALFUNC = ffp,
    INITCOND = '{}');

CREATE AGGREGATE myaggp18b (
    BASETYPE = int,
    SFUNC = tfp,
    STYPE = anyarray,
    INITCOND = '{}');

--    P    P        P    N
-- should ERROR: tf1p(anyarray, anyelement) not matched by tf1p(anyarray, int)
CREATE AGGREGATE myaggp19a (
    BASETYPE = anyelement,
    SFUNC = tf1p,
    STYPE = anyarray,
    FINALFUNC = ffp,
    INITCOND = '{}');

CREATE AGGREGATE myaggp19b (
    BASETYPE = anyelement,
    SFUNC = tf1p,
    STYPE = anyarray,
    INITCOND = '{}');

--    P    P        P    P
-- should CREATE
CREATE AGGREGATE myaggp20a (
    BASETYPE = anyelement,
    SFUNC = tfp,
    STYPE = anyarray,
    FINALFUNC = ffp,
    INITCOND = '{}');

CREATE AGGREGATE myaggp20b (
    BASETYPE = anyelement,
    SFUNC = tfp,
    STYPE = anyarray,
    INITCOND = '{}');

--     Case3 (R = N) && (B = A)
--     ------------------------
--     S    tf1
--     -------
--     N    N
-- should CREATE
CREATE AGGREGATE myaggn01a (*) (
    SFUNC = stfnp,
    STYPE = int4[],
    FINALFUNC = ffnp,
    INITCOND = '{}');

CREATE AGGREGATE myaggn01b (*) (SFUNC = stfnp, STYPE = int4[], INITCOND = '{}');

--     P    N
-- should ERROR: stfnp(anyarray) not matched by stfnp(int[])
CREATE AGGREGATE myaggn02a (*) (
    SFUNC = stfnp,
    STYPE = anyarray,
    FINALFUNC = ffnp,
    INITCOND = '{}');

CREATE AGGREGATE myaggn02b (*) (SFUNC = stfnp, STYPE = anyarray, INITCOND = '{}');

--     N    P
-- should CREATE
CREATE AGGREGATE myaggn03a (*) (
    SFUNC = stfp,
    STYPE = int4[],
    FINALFUNC = ffnp,
    INITCOND = '{}');

--     P    P
-- should ERROR: ffnp(anyarray) not matched by ffnp(int[])
CREATE AGGREGATE myaggn04a (*) (
    SFUNC = stfp,
    STYPE = anyarray,
    FINALFUNC = ffnp,
    INITCOND = '{}');

--    Case4 (R = N) && ((B = P) || (B = N))
--    -------------------------------------
--    S    tf1      B    tf2
--    -----------------------
--    N    N        N    N
-- should CREATE
CREATE AGGREGATE myaggn05a (
    BASETYPE = int,
    SFUNC = tfnp,
    STYPE = INT[],
    FINALFUNC = ffnp,
    INITCOND = '{}');

CREATE AGGREGATE myaggn05b (
    BASETYPE = int,
    SFUNC = tfnp,
    STYPE = INT[],
    INITCOND = '{}');

--    N    N        N    P
-- should CREATE
CREATE AGGREGATE myaggn06a (
    BASETYPE = int,
    SFUNC = tf2p,
    STYPE = INT[],
    FINALFUNC = ffnp,
    INITCOND = '{}');

CREATE AGGREGATE myaggn06b (
    BASETYPE = int,
    SFUNC = tf2p,
    STYPE = INT[],
    INITCOND = '{}');

--    N    N        P    N
-- should ERROR: tfnp(int[], anyelement) not matched by tfnp(int[], int)
CREATE AGGREGATE myaggn07a (
    BASETYPE = anyelement,
    SFUNC = tfnp,
    STYPE = INT[],
    FINALFUNC = ffnp,
    INITCOND = '{}');

CREATE AGGREGATE myaggn07b (
    BASETYPE = anyelement,
    SFUNC = tfnp,
    STYPE = INT[],
    INITCOND = '{}');

--    N    N        P    P
-- should CREATE
CREATE AGGREGATE myaggn08a (
    BASETYPE = anyelement,
    SFUNC = tf2p,
    STYPE = INT[],
    FINALFUNC = ffnp,
    INITCOND = '{}');

CREATE AGGREGATE myaggn08b (
    BASETYPE = anyelement,
    SFUNC = tf2p,
    STYPE = INT[],
    INITCOND = '{}');

--    N    P        N    N
-- should CREATE
CREATE AGGREGATE myaggn09a (
    BASETYPE = int,
    SFUNC = tf1p,
    STYPE = INT[],
    FINALFUNC = ffnp,
    INITCOND = '{}');

--    N    P        N    P
-- should CREATE
CREATE AGGREGATE myaggn10a (
    BASETYPE = int,
    SFUNC = tfp,
    STYPE = INT[],
    FINALFUNC = ffnp,
    INITCOND = '{}');

--    N    P        P    N
-- should ERROR: tf1p(int[],anyelement) not matched by tf1p(anyarray,int)
CREATE AGGREGATE myaggn11a (
    BASETYPE = anyelement,
    SFUNC = tf1p,
    STYPE = INT[],
    FINALFUNC = ffnp,
    INITCOND = '{}');

--    N    P        P    P
-- should ERROR: tfp(int[],anyelement) not matched by tfp(anyarray,anyelement)
CREATE AGGREGATE myaggn12a (
    BASETYPE = anyelement,
    SFUNC = tfp,
    STYPE = INT[],
    FINALFUNC = ffnp,
    INITCOND = '{}');

--    P    N        N    N
-- should ERROR: tfnp(anyarray, int) not matched by tfnp(int[],int)
CREATE AGGREGATE myaggn13a (
    BASETYPE = int,
    SFUNC = tfnp,
    STYPE = anyarray,
    FINALFUNC = ffnp,
    INITCOND = '{}');

CREATE AGGREGATE myaggn13b (
    BASETYPE = int,
    SFUNC = tfnp,
    STYPE = anyarray,
    INITCOND = '{}');

--    P    N        N    P
-- should ERROR: tf2p(anyarray, int) not matched by tf2p(int[],anyelement)
CREATE AGGREGATE myaggn14a (
    BASETYPE = int,
    SFUNC = tf2p,
    STYPE = anyarray,
    FINALFUNC = ffnp,
    INITCOND = '{}');

CREATE AGGREGATE myaggn14b (
    BASETYPE = int,
    SFUNC = tf2p,
    STYPE = anyarray,
    INITCOND = '{}');

--    P    N        P    N
-- should ERROR: tfnp(anyarray, anyelement) not matched by tfnp(int[],int)
CREATE AGGREGATE myaggn15a (
    BASETYPE = anyelement,
    SFUNC = tfnp,
    STYPE = anyarray,
    FINALFUNC = ffnp,
    INITCOND = '{}');

CREATE AGGREGATE myaggn15b (
    BASETYPE = anyelement,
    SFUNC = tfnp,
    STYPE = anyarray,
    INITCOND = '{}');

--    P    N        P    P
-- should ERROR: tf2p(anyarray, anyelement) not matched by tf2p(int[],anyelement)
CREATE AGGREGATE myaggn16a (
    BASETYPE = anyelement,
    SFUNC = tf2p,
    STYPE = anyarray,
    FINALFUNC = ffnp,
    INITCOND = '{}');

CREATE AGGREGATE myaggn16b (
    BASETYPE = anyelement,
    SFUNC = tf2p,
    STYPE = anyarray,
    INITCOND = '{}');

--    P    P        N    N
-- should ERROR: ffnp(anyarray) not matched by ffnp(int[])
CREATE AGGREGATE myaggn17a (
    BASETYPE = int,
    SFUNC = tf1p,
    STYPE = anyarray,
    FINALFUNC = ffnp,
    INITCOND = '{}');

--    P    P        N    P
-- should ERROR: tfp(anyarray, int) not matched by tfp(anyarray, anyelement)
CREATE AGGREGATE myaggn18a (
    BASETYPE = int,
    SFUNC = tfp,
    STYPE = anyarray,
    FINALFUNC = ffnp,
    INITCOND = '{}');

--    P    P        P    N
-- should ERROR: tf1p(anyarray, anyelement) not matched by tf1p(anyarray, int)
CREATE AGGREGATE myaggn19a (
    BASETYPE = anyelement,
    SFUNC = tf1p,
    STYPE = anyarray,
    FINALFUNC = ffnp,
    INITCOND = '{}');

--    P    P        P    P
-- should ERROR: ffnp(anyarray) not matched by ffnp(int[])
CREATE AGGREGATE myaggn20a (
    BASETYPE = anyelement,
    SFUNC = tfp,
    STYPE = anyarray,
    FINALFUNC = ffnp,
    INITCOND = '{}');

-- multi-arg polymorphic
CREATE AGGREGATE mysum2 (anyelement, anyelement) (SFUNC = sum3, STYPE = anyelement, INITCOND = '0');

-- create test data for polymorphic aggregates
CREATE TEMP TABLE t (f1 int, f2 INT[], f3 text);

INSERT INTO
    t
VALUES
    (1, ARRAY[1], 'a');

INSERT INTO
    t
VALUES
    (1, ARRAY[11], 'b');

INSERT INTO
    t
VALUES
    (1, ARRAY[111], 'c');

INSERT INTO
    t
VALUES
    (2, ARRAY[2], 'a');

INSERT INTO
    t
VALUES
    (2, ARRAY[22], 'b');

INSERT INTO
    t
VALUES
    (2, ARRAY[222], 'c');

INSERT INTO
    t
VALUES
    (3, ARRAY[3], 'a');

INSERT INTO
    t
VALUES
    (3, ARRAY[3], 'b');

-- test the successfully created polymorphic aggregates
SELECT
    f3,
    myaggp01a (*)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggp03a (*)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggp03b (*)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggp05a (f1)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggp06a (f1)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggp08a (f1)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggp09a (f1)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggp09b (f1)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggp10a (f1)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggp10b (f1)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggp20a (f1)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggp20b (f1)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggn01a (*)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggn01b (*)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggn03a (*)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggn05a (f1)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggn05b (f1)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggn06a (f1)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggn06b (f1)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggn08a (f1)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggn08b (f1)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggn09a (f1)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    f3,
    myaggn10a (f1)
FROM
    t
GROUP BY
    f3
ORDER BY
    f3;

SELECT
    mysum2 (f1, f1 + 1)
FROM
    t;

-- test inlining of polymorphic SQL functions
CREATE FUNCTION bleat (int) returns int AS $$
begin
  raise notice 'bleat %', $1;
  return $1;
end$$ language plpgsql;

CREATE FUNCTION sql_if (bool, anyelement, anyelement) returns anyelement AS $$
select case when $1 then $2 else $3 end $$ language sql;

-- Note this would fail with integer overflow, never mind wrong bleat() output,
-- if the CASE expression were not successfully inlined
SELECT
    f1,
    sql_if (f1 > 0, bleat (f1), bleat (f1 + 1))
FROM
    int4_tbl;

SELECT
    q2,
    sql_if (q2 > 0, q2, q2 + 1)
FROM
    int8_tbl;

-- another sort of polymorphic aggregate
CREATE AGGREGATE array_cat_accum (anyarray) (
    sfunc = array_cat,
    stype = anyarray,
    initcond = '{}');

SELECT
    array_cat_accum (i)
FROM (
        VALUES
            (ARRAY[1, 2]),
            (ARRAY[3, 4])) AS t (i);

SELECT
    array_cat_accum (i)
FROM (
        VALUES
            (ARRAY[ROW (1, 2), ROW (3, 4)]),
            (ARRAY[ROW (5, 6), ROW (7, 8)])) AS t (i);

-- another kind of polymorphic aggregate
CREATE FUNCTION add_group (grp anyarray, ad anyelement, size integer) returns anyarray AS $$
begin
  if grp is null then
    return array[ad];
  end if;
  if array_upper(grp, 1) < size then
    return grp || ad;
  end if;
  return grp;
end;
$$ language plpgsql immutable;

CREATE AGGREGATE build_group (anyelement, integer) (SFUNC = add_group, STYPE = anyarray);

SELECT
    build_group (q1, 3)
FROM
    int8_tbl;

-- this should fail because stype isn't compatible with arg
CREATE AGGREGATE build_group (int8, integer) (SFUNC = add_group, STYPE = int2[]);

-- but we can make a non-poly agg from a poly sfunc if types are OK
CREATE AGGREGATE build_group (int8, integer) (SFUNC = add_group, STYPE = int8[]);

-- check proper resolution of data types for polymorphic transfn/finalfn
CREATE FUNCTION first_el (anyarray) returns anyelement AS 'select $1[1]' language sql strict immutable;

CREATE AGGREGATE first_el_agg_f8 (float8) (
    SFUNC = array_append,
    STYPE = float8[],
    FINALFUNC = first_el);

CREATE AGGREGATE first_el_agg_any (anyelement) (
    SFUNC = array_append,
    STYPE = anyarray,
    FINALFUNC = first_el);

SELECT
    first_el_agg_f8 (x::float8)
FROM
    generate_series(1, 10) x;

SELECT
    first_el_agg_any (x)
FROM
    generate_series(1, 10) x;

SELECT
    first_el_agg_f8 (x::float8) OVER (
        ORDER BY
            x)
FROM
    generate_series(1, 10) x;

SELECT
    first_el_agg_any (x) OVER (
        ORDER BY
            x)
FROM
    generate_series(1, 10) x;

-- check that we can apply functions taking ANYARRAY to pg_stats
SELECT DISTINCT
    array_ndims(histogram_bounds)
FROM
    pg_stats
WHERE
    histogram_bounds IS NOT NULL;

-- such functions must protect themselves if varying element type isn't OK
-- (WHERE clause here is to avoid possibly getting a collation error instead)
SELECT
    max(histogram_bounds)
FROM
    pg_stats
WHERE
    tablename = 'pg_am';

-- test variadic polymorphic functions
CREATE FUNCTION myleast (VARIADIC anyarray) returns anyelement AS $$
  select min($1[i]) from generate_subscripts($1,1) g(i)
$$ language sql immutable strict;

SELECT
    myleast (10, 1, 20, 33);

SELECT
    myleast (1.1, 0.22, 0.55);

SELECT
    myleast ('z'::text);

SELECT
    myleast ();

-- fail
-- test with variadic call parameter
SELECT
    myleast (VARIADIC ARRAY[1, 2, 3, 4, -1]);

SELECT
    myleast (VARIADIC ARRAY[1.1, -5.5]);

--test with empty variadic call parameter
SELECT
    myleast (VARIADIC ARRAY[]::INT[]);

-- an example with some ordinary arguments too
CREATE FUNCTION concat(text, VARIADIC anyarray) returns text AS $$
  select array_to_string($2, $1);
$$ language sql immutable strict;

SELECT
    concat('%', 1, 2, 3, 4, 5);

SELECT
    concat('|', 'a'::text, 'b', 'c');

SELECT
    concat('|', VARIADIC ARRAY[1, 2, 33]);

SELECT
    concat('|', VARIADIC ARRAY[]::INT[]);

DROP FUNCTION concat(text, anyarray);

-- mix variadic with anyelement
CREATE FUNCTION formarray (anyelement, VARIADIC anyarray) returns anyarray AS $$
  select array_prepend($1, $2);
$$ language sql immutable strict;

SELECT
    formarray (1, 2, 3, 4, 5);

SELECT
    formarray (1.1, VARIADIC ARRAY[1.2, 55.5]);

SELECT
    formarray (1.1, ARRAY[1.2, 55.5]);

-- fail without variadic
SELECT
    formarray (1, 'x'::text);

-- fail, type mismatch
SELECT
    formarray (1, VARIADIC ARRAY['x'::text]);

-- fail, type mismatch
DROP FUNCTION formarray (anyelement, VARIADIC anyarray);

-- test pg_typeof() function
SELECT
    pg_typeof(NULL);

-- unknown
SELECT
    pg_typeof(0);

-- integer
SELECT
    pg_typeof(0.0);

-- numeric
SELECT
    pg_typeof(1 + 1 = 2);

-- boolean
SELECT
    pg_typeof('x');

-- unknown
SELECT
    pg_typeof('' || '');

-- text
SELECT
    pg_typeof(pg_typeof(0));

-- regtype
SELECT
    pg_typeof(ARRAY[1.2, 55.5]);

-- numeric[]
SELECT
    pg_typeof(myleast (10, 1, 20, 33));

-- polymorphic input
-- test functions with default parameters
-- test basic functionality
CREATE FUNCTION dfunc (a int = 1, int = 2) returns int AS $$
  select $1 + $2;
$$ language sql;

SELECT
    dfunc ();

SELECT
    dfunc (10);

SELECT
    dfunc (10, 20);

SELECT
    dfunc (10, 20, 30);

-- fail
DROP FUNCTION dfunc ();

-- fail
DROP FUNCTION dfunc (int);

-- fail
DROP FUNCTION dfunc (int, int);

-- ok
-- fail: defaults must be at end of argument list
CREATE FUNCTION dfunc (a int = 1, b int) returns int AS $$
  select $1 + $2;
$$ language sql;

-- however, this should work:
CREATE FUNCTION dfunc (a int = 1, OUT sum int, b int = 2) AS $$
  select $1 + $2;
$$ language sql;

SELECT
    dfunc ();

-- verify it lists properly
\df dfunc
DROP FUNCTION dfunc (int, int);

-- check implicit coercion
CREATE FUNCTION dfunc (a int DEFAULT 1.0, int DEFAULT '-1') returns int AS $$
  select $1 + $2;
$$ language sql;

SELECT
    dfunc ();

CREATE FUNCTION dfunc (a text DEFAULT 'Hello', b text DEFAULT 'World') returns text AS $$
  select $1 || ', ' || $2;
$$ language sql;

SELECT
    dfunc ();

-- fail: which dfunc should be called? int or text
SELECT
    dfunc ('Hi');

-- ok
SELECT
    dfunc ('Hi', 'City');

-- ok
SELECT
    dfunc (0);

-- ok
SELECT
    dfunc (10, 20);

-- ok
DROP FUNCTION dfunc (int, int);

DROP FUNCTION dfunc (text, text);

CREATE FUNCTION dfunc (int = 1, int = 2) returns int AS $$
  select 2;
$$ language sql;

CREATE FUNCTION dfunc (int = 1, int = 2, int = 3, int = 4) returns int AS $$
  select 4;
$$ language sql;

-- Now, dfunc(nargs = 2) and dfunc(nargs = 4) are ambiguous when called
-- with 0 to 2 arguments.
SELECT
    dfunc ();

-- fail
SELECT
    dfunc (1);

-- fail
SELECT
    dfunc (1, 2);

-- fail
SELECT
    dfunc (1, 2, 3);

-- ok
SELECT
    dfunc (1, 2, 3, 4);

-- ok
DROP FUNCTION dfunc (int, int);

DROP FUNCTION dfunc (int, int, int, int);

-- default values are not allowed for output parameters
CREATE FUNCTION dfunc (OUT int = 20) returns int AS $$
  select 1;
$$ language sql;

-- polymorphic parameter test
CREATE FUNCTION dfunc (anyelement = 'World'::text) returns text AS $$
  select 'Hello, ' || $1::text;
$$ language sql;

SELECT
    dfunc ();

SELECT
    dfunc (0);

SELECT
    dfunc (to_date('20081215', 'YYYYMMDD'));

SELECT
    dfunc ('City'::text);

DROP FUNCTION dfunc (anyelement);

-- check defaults for variadics
CREATE FUNCTION dfunc (a VARIADIC INT[]) returns int AS $$ select array_upper($1, 1) $$ language sql;

SELECT
    dfunc ();

-- fail
SELECT
    dfunc (10);

SELECT
    dfunc (10, 20);

CREATE OR REPLACE FUNCTION dfunc (a VARIADIC INT[] DEFAULT ARRAY[]::INT[]) returns int AS $$ select array_upper($1, 1) $$ language sql;

SELECT
    dfunc ();

-- now ok
SELECT
    dfunc (10);

SELECT
    dfunc (10, 20);

-- can't remove the default once it exists
CREATE OR REPLACE FUNCTION dfunc (a VARIADIC INT[]) returns int AS $$ select array_upper($1, 1) $$ language sql;

\df dfunc
DROP FUNCTION dfunc (a VARIADIC INT[]);

-- Ambiguity should be reported only if there's not a better match available
CREATE FUNCTION dfunc (int = 1, int = 2, int = 3) returns int AS $$
  select 3;
$$ language sql;

CREATE FUNCTION dfunc (int = 1, int = 2) returns int AS $$
  select 2;
$$ language sql;

CREATE FUNCTION dfunc (text) returns text AS $$
  select $1;
$$ language sql;

-- dfunc(narg=2) and dfunc(narg=3) are ambiguous
SELECT
    dfunc (1);

-- fail
-- but this works since the ambiguous functions aren't preferred anyway
SELECT
    dfunc ('Hi');

DROP FUNCTION dfunc (int, int, int);

DROP FUNCTION dfunc (int, int);

DROP FUNCTION dfunc (text);

--
-- Tests for named- and mixed-notation function calling
--
CREATE FUNCTION dfunc (a int, b int, c int = 0, d int = 0) returns TABLE (a int, b int, c int, d int) AS $$
  select $1, $2, $3, $4;
$$ language sql;

SELECT
    (dfunc (10, 20, 30)).*;

SELECT
    (dfunc (a := 10, b := 20, c := 30)).*;

SELECT
    *
FROM
    dfunc (a := 10, b := 20);

SELECT
    *
FROM
    dfunc (b := 10, a := 20);

SELECT
    *
FROM
    dfunc (0);

-- fail
SELECT
    *
FROM
    dfunc (1, 2);

SELECT
    *
FROM
    dfunc (1, 2, c := 3);

SELECT
    *
FROM
    dfunc (1, 2, d := 3);

SELECT
    *
FROM
    dfunc (x := 20, b := 10, x := 30);

-- fail, duplicate name
SELECT
    *
FROM
    dfunc (10, b := 20, 30);

-- fail, named args must be last
SELECT
    *
FROM
    dfunc (x := 10, b := 20, c := 30);

-- fail, unknown param
SELECT
    *
FROM
    dfunc (10, 10, a := 20);

-- fail, a overlaps positional parameter
SELECT
    *
FROM
    dfunc (1, c := 2, d := 3);

-- fail, no value for b
DROP FUNCTION dfunc (int, int, int, int);

-- test with different parameter types
CREATE FUNCTION dfunc (a varchar, b numeric, c date = current_date) returns TABLE (a varchar, b numeric, c date) AS $$
  select $1, $2, $3;
$$ language sql;

SELECT
    (dfunc ('Hello World', 20, '2009-07-25'::date)).*;

SELECT
    *
FROM
    dfunc ('Hello World', 20, '2009-07-25'::date);

SELECT
    *
FROM
    dfunc (
        c := '2009-07-25'::date,
        a := 'Hello World',
        b := 20);

SELECT
    *
FROM
    dfunc ('Hello World', b := 20, c := '2009-07-25'::date);

SELECT
    *
FROM
    dfunc ('Hello World', c := '2009-07-25'::date, b := 20);

SELECT
    *
FROM
    dfunc ('Hello World', c := 20, b := '2009-07-25'::date);

-- fail
DROP FUNCTION dfunc (varchar, numeric, date);

-- test out parameters with named params
CREATE FUNCTION dfunc (
    a varchar = 'def a',
    OUT _a varchar,
    c numeric = NULL,
    OUT _c numeric) returns record AS $$
  select $1, $2;
$$ language sql;

SELECT
    (dfunc ()).*;

SELECT
    *
FROM
    dfunc ();

SELECT
    *
FROM
    dfunc ('Hello', 100);

SELECT
    *
FROM
    dfunc (a := 'Hello', c := 100);

SELECT
    *
FROM
    dfunc (c := 100, a := 'Hello');

SELECT
    *
FROM
    dfunc ('Hello');

SELECT
    *
FROM
    dfunc ('Hello', c := 100);

SELECT
    *
FROM
    dfunc (c := 100);

-- fail, can no longer change an input parameter's name
CREATE OR REPLACE FUNCTION dfunc (
    a varchar = 'def a',
    OUT _a varchar,
    x numeric = NULL,
    OUT _c numeric) returns record AS $$
  select $1, $2;
$$ language sql;

CREATE OR REPLACE FUNCTION dfunc (
    a varchar = 'def a',
    OUT _a varchar,
    numeric = NULL,
    OUT _c numeric) returns record AS $$
  select $1, $2;
$$ language sql;

DROP FUNCTION dfunc (varchar, numeric);

--fail, named parameters are not unique
CREATE FUNCTION testpolym (a int, a int) returns int AS $$ select 1;$$ language sql;

CREATE FUNCTION testpolym (int, OUT a int, OUT a int) returns int AS $$ select 1;$$ language sql;

CREATE FUNCTION testpolym (OUT a int, INOUT a int) returns int AS $$ select 1;$$ language sql;

CREATE FUNCTION testpolym (a int, INOUT a int) returns int AS $$ select 1;$$ language sql;

-- valid
CREATE FUNCTION testpolym (a int, OUT a int) returns int AS $$ select $1;$$ language sql;

SELECT
    testpolym (37);

DROP FUNCTION testpolym (int);

CREATE FUNCTION testpolym (a int) returns TABLE (a int) AS $$ select $1;$$ language sql;

SELECT
    *
FROM
    testpolym (37);

DROP FUNCTION testpolym (int);

-- test polymorphic params and defaults
CREATE FUNCTION dfunc (
    a anyelement,
    b anyelement = NULL,
    flag bool = TRUE) returns anyelement AS $$
  select case when $3 then $1 else $2 end;
$$ language sql;

SELECT
    dfunc (1, 2);

SELECT
    dfunc ('a'::text, 'b');

-- positional notation with default
SELECT
    dfunc (a := 1, b := 2);

SELECT
    dfunc (a := 'a'::text, b := 'b');

SELECT
    dfunc (a := 'a'::text, b := 'b', flag := FALSE);

-- named notation
SELECT
    dfunc (b := 'b'::text, a := 'a');

-- named notation with default
SELECT
    dfunc (a := 'a'::text, flag := TRUE);

-- named notation with default
SELECT
    dfunc (a := 'a'::text, flag := FALSE);

-- named notation with default
SELECT
    dfunc (b := 'b'::text, a := 'a', flag := TRUE);

-- named notation
SELECT
    dfunc ('a'::text, 'b', FALSE);

-- full positional notation
SELECT
    dfunc ('a'::text, 'b', flag := FALSE);

-- mixed notation
SELECT
    dfunc ('a'::text, 'b', TRUE);

-- full positional notation
SELECT
    dfunc ('a'::text, 'b', flag := TRUE);

-- mixed notation
-- ansi/sql syntax
SELECT
    dfunc (a => 1, b => 2);

SELECT
    dfunc (a => 'a'::text, b => 'b');

SELECT
    dfunc (a => 'a'::text, b => 'b', flag => FALSE);

-- named notation
SELECT
    dfunc (b => 'b'::text, a => 'a');

-- named notation with default
SELECT
    dfunc (a => 'a'::text, flag => TRUE);

-- named notation with default
SELECT
    dfunc (a => 'a'::text, flag => FALSE);

-- named notation with default
SELECT
    dfunc (b => 'b'::text, a => 'a', flag => TRUE);

-- named notation
SELECT
    dfunc ('a'::text, 'b', FALSE);

-- full positional notation
SELECT
    dfunc ('a'::text, 'b', flag => FALSE);

-- mixed notation
SELECT
    dfunc ('a'::text, 'b', TRUE);

-- full positional notation
SELECT
    dfunc ('a'::text, 'b', flag => TRUE);

-- mixed notation
-- this tests lexer edge cases around =>
SELECT
    dfunc (a => -1);

SELECT
    dfunc (a => + 1);

SELECT
    dfunc (a => /**/ 1);

SELECT
    dfunc (
        a => --comment to be removed by psql
        1);

-- need DO to protect the -- from psql
DO $$
  declare r integer;
  begin
    select dfunc(a=>-- comment
      1) into r;
    raise info 'r = %', r;
  end;
$$;

-- check reverse-listing of named-arg calls
CREATE VIEW dfview AS
SELECT
    q1,
    q2,
    dfunc (q1, q2, flag := q1 > q2) AS c3,
    dfunc (q1, flag := q1 < q2, b := q2) AS c4
FROM
    int8_tbl;

SELECT
    *
FROM
    dfview;

\d+ dfview
DROP VIEW dfview;

DROP FUNCTION dfunc (anyelement, anyelement, bool);