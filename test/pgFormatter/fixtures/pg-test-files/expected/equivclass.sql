--
-- Tests for the planner's "equivalence class" mechanism
--
-- One thing that's not tested well during normal querying is the logic
-- for handling "broken" ECs.  This is because an EC can only become broken
-- if its underlying btree operator family doesn't include a complete set
-- of cross-type equality operators.  There are not (and should not be)
-- any such families built into Postgres; so we have to hack things up
-- to create one.  We do this by making two alias types that are really
-- int8 (so we need no new C code) and adding only some operators for them
-- into the standard integer_ops opfamily.
CREATE TYPE int8alias1;

CREATE FUNCTION int8alias1in (cstring) returns int8alias1 strict immutable language internal AS 'int8in';

CREATE FUNCTION int8alias1out (int8alias1) returns cstring strict immutable language internal AS 'int8out';

CREATE TYPE int8alias1 (
    input = int8alias1in,
    output = int8alias1out,
    LIKE = int8);

CREATE TYPE int8alias2;

CREATE FUNCTION int8alias2in (cstring) returns int8alias2 strict immutable language internal AS 'int8in';

CREATE FUNCTION int8alias2out (int8alias2) returns cstring strict immutable language internal AS 'int8out';

CREATE TYPE int8alias2 (
    input = int8alias2in,
    output = int8alias2out,
    LIKE = int8);

CREATE CAST (int8 AS int8alias1) WITHOUT function;

CREATE CAST (int8 AS int8alias2) WITHOUT function;

CREATE CAST (int8alias1 AS int8) WITHOUT function;

CREATE CAST (int8alias2 AS int8) WITHOUT function;

CREATE FUNCTION int8alias1eq (int8alias1, int8alias1) returns bool strict immutable language internal AS 'int8eq';

CREATE OPERATOR = (
    procedure = int8alias1eq,
    leftarg = int8alias1,
    rightarg = int8alias1,
    commutator = =,
    restrict = eqsel,
    JOIN = eqjoinsel,
    merges);

ALTER OPERATOR FAMILY integer_ops USING btree
ADD operator 3 = (int8alias1, int8alias1);

CREATE FUNCTION int8alias2eq (int8alias2, int8alias2) returns bool strict immutable language internal AS 'int8eq';

CREATE OPERATOR = (
    procedure = int8alias2eq,
    leftarg = int8alias2,
    rightarg = int8alias2,
    commutator = =,
    restrict = eqsel,
    JOIN = eqjoinsel,
    merges);

ALTER OPERATOR FAMILY integer_ops USING btree
ADD operator 3 = (int8alias2, int8alias2);

CREATE FUNCTION int8alias1eq (int8, int8alias1) returns bool strict immutable language internal AS 'int8eq';

CREATE OPERATOR = (
    procedure = int8alias1eq,
    leftarg = int8,
    rightarg = int8alias1,
    restrict = eqsel,
    JOIN = eqjoinsel,
    merges);

ALTER OPERATOR FAMILY integer_ops USING btree
ADD operator 3 = (int8, int8alias1);

CREATE FUNCTION int8alias1eq (int8alias1, int8alias2) returns bool strict immutable language internal AS 'int8eq';

CREATE OPERATOR = (
    procedure = int8alias1eq,
    leftarg = int8alias1,
    rightarg = int8alias2,
    restrict = eqsel,
    JOIN = eqjoinsel,
    merges);

ALTER OPERATOR FAMILY integer_ops USING btree
ADD operator 3 = (int8alias1, int8alias2);

CREATE FUNCTION int8alias1lt (int8alias1, int8alias1) returns bool strict immutable language internal AS 'int8lt';

CREATE OPERATOR < (
    procedure = int8alias1lt,
    leftarg = int8alias1,
    rightarg = int8alias1);

ALTER OPERATOR FAMILY integer_ops USING btree
ADD operator 1 < (int8alias1, int8alias1);

CREATE FUNCTION int8alias1cmp (int8, int8alias1) returns int strict immutable language internal AS 'btint8cmp';

ALTER OPERATOR FAMILY integer_ops USING btree
ADD function 1 int8alias1cmp (int8, int8alias1);

CREATE TABLE ec0 (ff int8 PRIMARY KEY, f1 int8, f2 int8);

CREATE TABLE ec1 (ff int8 PRIMARY KEY, f1 int8alias1, f2 int8alias2);

CREATE TABLE ec2 (xf int8 PRIMARY KEY, x1 int8alias1, x2 int8alias2);

-- for the moment we only want to look at nestloop plans
SET
    enable_hashjoin = off;

SET
    enable_mergejoin = off;

--
-- Note that for cases where there's a missing operator, we don't care so
-- much whether the plan is ideal as that we don't fail or generate an
-- outright incorrect plan.
--
EXPLAIN (costs off)
SELECT
    *
FROM
    ec0
WHERE
    ff = f1
    AND f1 = '42'::int8;

EXPLAIN (costs off)
SELECT
    *
FROM
    ec0
WHERE
    ff = f1
    AND f1 = '42'::int8alias1;

EXPLAIN (costs off)
SELECT
    *
FROM
    ec1
WHERE
    ff = f1
    AND f1 = '42'::int8alias1;

EXPLAIN (costs off)
SELECT
    *
FROM
    ec1
WHERE
    ff = f1
    AND f1 = '42'::int8alias2;

EXPLAIN (costs off)
SELECT
    *
FROM
    ec1,
    ec2
WHERE
    ff = x1
    AND ff = '42'::int8;

EXPLAIN (costs off)
SELECT
    *
FROM
    ec1,
    ec2
WHERE
    ff = x1
    AND ff = '42'::int8alias1;

EXPLAIN (costs off)
SELECT
    *
FROM
    ec1,
    ec2
WHERE
    ff = x1
    AND '42'::int8 = x1;

EXPLAIN (costs off)
SELECT
    *
FROM
    ec1,
    ec2
WHERE
    ff = x1
    AND x1 = '42'::int8alias1;

EXPLAIN (costs off)
SELECT
    *
FROM
    ec1,
    ec2
WHERE
    ff = x1
    AND x1 = '42'::int8alias2;

CREATE UNIQUE INDEX ec1_expr1 ON ec1 ((ff + 1));

CREATE UNIQUE INDEX ec1_expr2 ON ec1 ((ff + 2 + 1));

CREATE UNIQUE INDEX ec1_expr3 ON ec1 ((ff + 3 + 1));

CREATE UNIQUE INDEX ec1_expr4 ON ec1 ((ff + 4));

EXPLAIN (costs off)
SELECT
    *
FROM
    ec1, (
        SELECT
            ff + 1 AS x
        FROM (
                SELECT
                    ff + 2 AS ff
                FROM
                    ec1
                UNION ALL
                SELECT
                    ff + 3 AS ff
                FROM
                    ec1) ss0
        UNION ALL
        SELECT
            ff + 4 AS x
        FROM
            ec1) AS ss1
WHERE
    ss1.x = ec1.f1
    AND ec1.ff = 42::int8;

EXPLAIN (costs off)
SELECT
    *
FROM
    ec1, (
        SELECT
            ff + 1 AS x
        FROM (
                SELECT
                    ff + 2 AS ff
                FROM
                    ec1
                UNION ALL
                SELECT
                    ff + 3 AS ff
                FROM
                    ec1) ss0
        UNION ALL
        SELECT
            ff + 4 AS x
        FROM
            ec1) AS ss1
WHERE
    ss1.x = ec1.f1
    AND ec1.ff = 42::int8
    AND ec1.ff = ec1.f1;

EXPLAIN (costs off)
SELECT
    *
FROM
    ec1, (
        SELECT
            ff + 1 AS x
        FROM (
                SELECT
                    ff + 2 AS ff
                FROM
                    ec1
                UNION ALL
                SELECT
                    ff + 3 AS ff
                FROM
                    ec1) ss0
        UNION ALL
        SELECT
            ff + 4 AS x
        FROM
            ec1) AS ss1, (
        SELECT
            ff + 1 AS x
        FROM (
                SELECT
                    ff + 2 AS ff
                FROM
                    ec1
                UNION ALL
                SELECT
                    ff + 3 AS ff
                FROM
                    ec1) ss0
        UNION ALL
        SELECT
            ff + 4 AS x
        FROM
            ec1) AS ss2
WHERE
    ss1.x = ec1.f1
    AND ss1.x = ss2.x
    AND ec1.ff = 42::int8;

-- let's try that as a mergejoin
SET
    enable_mergejoin = ON;

SET
    enable_nestloop = off;

EXPLAIN (costs off)
SELECT
    *
FROM
    ec1, (
        SELECT
            ff + 1 AS x
        FROM (
                SELECT
                    ff + 2 AS ff
                FROM
                    ec1
                UNION ALL
                SELECT
                    ff + 3 AS ff
                FROM
                    ec1) ss0
        UNION ALL
        SELECT
            ff + 4 AS x
        FROM
            ec1) AS ss1, (
        SELECT
            ff + 1 AS x
        FROM (
                SELECT
                    ff + 2 AS ff
                FROM
                    ec1
                UNION ALL
                SELECT
                    ff + 3 AS ff
                FROM
                    ec1) ss0
        UNION ALL
        SELECT
            ff + 4 AS x
        FROM
            ec1) AS ss2
WHERE
    ss1.x = ec1.f1
    AND ss1.x = ss2.x
    AND ec1.ff = 42::int8;

-- check partially indexed scan
SET
    enable_nestloop = ON;

SET
    enable_mergejoin = off;

DROP INDEX ec1_expr3;

EXPLAIN (costs off)
SELECT
    *
FROM
    ec1, (
        SELECT
            ff + 1 AS x
        FROM (
                SELECT
                    ff + 2 AS ff
                FROM
                    ec1
                UNION ALL
                SELECT
                    ff + 3 AS ff
                FROM
                    ec1) ss0
        UNION ALL
        SELECT
            ff + 4 AS x
        FROM
            ec1) AS ss1
WHERE
    ss1.x = ec1.f1
    AND ec1.ff = 42::int8;

-- let's try that as a mergejoin
SET
    enable_mergejoin = ON;

SET
    enable_nestloop = off;

EXPLAIN (costs off)
SELECT
    *
FROM
    ec1, (
        SELECT
            ff + 1 AS x
        FROM (
                SELECT
                    ff + 2 AS ff
                FROM
                    ec1
                UNION ALL
                SELECT
                    ff + 3 AS ff
                FROM
                    ec1) ss0
        UNION ALL
        SELECT
            ff + 4 AS x
        FROM
            ec1) AS ss1
WHERE
    ss1.x = ec1.f1
    AND ec1.ff = 42::int8;

-- check effects of row-level security
SET
    enable_nestloop = ON;

SET
    enable_mergejoin = off;

ALTER TABLE ec1 enable ROW level security;

CREATE POLICY p1 ON ec1 USING (f1 < '5'::int8alias1);

CREATE USER regress_user_ectest;

GRANT
SELECT
    ON ec0 TO regress_user_ectest;

GRANT
SELECT
    ON ec1 TO regress_user_ectest;

-- without any RLS, we'll treat {a.ff, b.ff, 43} as an EquivalenceClass
EXPLAIN (costs off)
SELECT
    *
FROM
    ec0 a,
    ec1 b
WHERE
    a.ff = b.ff
    AND a.ff = 43::bigint::int8alias1;

SET SESSION AUTHORIZATION regress_user_ectest;

-- with RLS active, the non-leakproof a.ff = 43 clause is not treated
-- as a suitable source for an EquivalenceClass; currently, this is true
-- even though the RLS clause has nothing to do directly with the EC
EXPLAIN (costs off)
SELECT
    *
FROM
    ec0 a,
    ec1 b
WHERE
    a.ff = b.ff
    AND a.ff = 43::bigint::int8alias1;

RESET SESSION AUTHORIZATION;

REVOKE
SELECT
    ON ec0
FROM
    regress_user_ectest;

REVOKE
SELECT
    ON ec1
FROM
    regress_user_ectest;

DROP USER regress_user_ectest;

-- check that X=X is converted to X IS NOT NULL when appropriate
EXPLAIN (costs off)
SELECT
    *
FROM
    tenk1
WHERE
    unique1 = unique1
    AND unique2 = unique2;

-- this could be converted, but isn't at present
EXPLAIN (costs off)
SELECT
    *
FROM
    tenk1
WHERE
    unique1 = unique1
    OR unique2 = unique2;