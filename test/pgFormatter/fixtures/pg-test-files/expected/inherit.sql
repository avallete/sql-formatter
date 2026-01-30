--
-- Test inheritance features
--
CREATE TABLE a (aa TEXT);

CREATE TABLE b (bb TEXT) INHERITS (a);

CREATE TABLE c (cc TEXT) INHERITS (a);

CREATE TABLE d (dd TEXT) INHERITS (b, c, a);

INSERT INTO
    a (aa)
VALUES
    ('aaa');

INSERT INTO
    a (aa)
VALUES
    ('aaaa');

INSERT INTO
    a (aa)
VALUES
    ('aaaaa');

INSERT INTO
    a (aa)
VALUES
    ('aaaaaa');

INSERT INTO
    a (aa)
VALUES
    ('aaaaaaa');

INSERT INTO
    a (aa)
VALUES
    ('aaaaaaaa');

INSERT INTO
    b (aa)
VALUES
    ('bbb');

INSERT INTO
    b (aa)
VALUES
    ('bbbb');

INSERT INTO
    b (aa)
VALUES
    ('bbbbb');

INSERT INTO
    b (aa)
VALUES
    ('bbbbbb');

INSERT INTO
    b (aa)
VALUES
    ('bbbbbbb');

INSERT INTO
    b (aa)
VALUES
    ('bbbbbbbb');

INSERT INTO
    c (aa)
VALUES
    ('ccc');

INSERT INTO
    c (aa)
VALUES
    ('cccc');

INSERT INTO
    c (aa)
VALUES
    ('ccccc');

INSERT INTO
    c (aa)
VALUES
    ('cccccc');

INSERT INTO
    c (aa)
VALUES
    ('ccccccc');

INSERT INTO
    c (aa)
VALUES
    ('cccccccc');

INSERT INTO
    d (aa)
VALUES
    ('ddd');

INSERT INTO
    d (aa)
VALUES
    ('dddd');

INSERT INTO
    d (aa)
VALUES
    ('ddddd');

INSERT INTO
    d (aa)
VALUES
    ('dddddd');

INSERT INTO
    d (aa)
VALUES
    ('ddddddd');

INSERT INTO
    d (aa)
VALUES
    ('dddddddd');

SELECT
    relname,
    a.*
FROM
    a,
    pg_class
WHERE
    a.tableoid = pg_class.oid;

SELECT
    relname,
    b.*
FROM
    b,
    pg_class
WHERE
    b.tableoid = pg_class.oid;

SELECT
    relname,
    c.*
FROM
    c,
    pg_class
WHERE
    c.tableoid = pg_class.oid;

SELECT
    relname,
    d.*
FROM
    d,
    pg_class
WHERE
    d.tableoid = pg_class.oid;

SELECT
    relname,
    a.*
FROM
    ONLY a,
    pg_class
WHERE
    a.tableoid = pg_class.oid;

SELECT
    relname,
    b.*
FROM
    ONLY b,
    pg_class
WHERE
    b.tableoid = pg_class.oid;

SELECT
    relname,
    c.*
FROM
    ONLY c,
    pg_class
WHERE
    c.tableoid = pg_class.oid;

SELECT
    relname,
    d.*
FROM
    ONLY d,
    pg_class
WHERE
    d.tableoid = pg_class.oid;

UPDATE a
SET
    aa = 'zzzz'
WHERE
    aa = 'aaaa';

UPDATE ONLY a
SET
    aa = 'zzzzz'
WHERE
    aa = 'aaaaa';

UPDATE b
SET
    aa = 'zzz'
WHERE
    aa = 'aaa';

UPDATE ONLY b
SET
    aa = 'zzz'
WHERE
    aa = 'aaa';

UPDATE a
SET
    aa = 'zzzzzz'
WHERE
    aa LIKE 'aaa%';

SELECT
    relname,
    a.*
FROM
    a,
    pg_class
WHERE
    a.tableoid = pg_class.oid;

SELECT
    relname,
    b.*
FROM
    b,
    pg_class
WHERE
    b.tableoid = pg_class.oid;

SELECT
    relname,
    c.*
FROM
    c,
    pg_class
WHERE
    c.tableoid = pg_class.oid;

SELECT
    relname,
    d.*
FROM
    d,
    pg_class
WHERE
    d.tableoid = pg_class.oid;

SELECT
    relname,
    a.*
FROM
    ONLY a,
    pg_class
WHERE
    a.tableoid = pg_class.oid;

SELECT
    relname,
    b.*
FROM
    ONLY b,
    pg_class
WHERE
    b.tableoid = pg_class.oid;

SELECT
    relname,
    c.*
FROM
    ONLY c,
    pg_class
WHERE
    c.tableoid = pg_class.oid;

SELECT
    relname,
    d.*
FROM
    ONLY d,
    pg_class
WHERE
    d.tableoid = pg_class.oid;

UPDATE b
SET
    aa = 'new';

SELECT
    relname,
    a.*
FROM
    a,
    pg_class
WHERE
    a.tableoid = pg_class.oid;

SELECT
    relname,
    b.*
FROM
    b,
    pg_class
WHERE
    b.tableoid = pg_class.oid;

SELECT
    relname,
    c.*
FROM
    c,
    pg_class
WHERE
    c.tableoid = pg_class.oid;

SELECT
    relname,
    d.*
FROM
    d,
    pg_class
WHERE
    d.tableoid = pg_class.oid;

SELECT
    relname,
    a.*
FROM
    ONLY a,
    pg_class
WHERE
    a.tableoid = pg_class.oid;

SELECT
    relname,
    b.*
FROM
    ONLY b,
    pg_class
WHERE
    b.tableoid = pg_class.oid;

SELECT
    relname,
    c.*
FROM
    ONLY c,
    pg_class
WHERE
    c.tableoid = pg_class.oid;

SELECT
    relname,
    d.*
FROM
    ONLY d,
    pg_class
WHERE
    d.tableoid = pg_class.oid;

UPDATE a
SET
    aa = 'new';

DELETE FROM ONLY c
WHERE
    aa = 'new';

SELECT
    relname,
    a.*
FROM
    a,
    pg_class
WHERE
    a.tableoid = pg_class.oid;

SELECT
    relname,
    b.*
FROM
    b,
    pg_class
WHERE
    b.tableoid = pg_class.oid;

SELECT
    relname,
    c.*
FROM
    c,
    pg_class
WHERE
    c.tableoid = pg_class.oid;

SELECT
    relname,
    d.*
FROM
    d,
    pg_class
WHERE
    d.tableoid = pg_class.oid;

SELECT
    relname,
    a.*
FROM
    ONLY a,
    pg_class
WHERE
    a.tableoid = pg_class.oid;

SELECT
    relname,
    b.*
FROM
    ONLY b,
    pg_class
WHERE
    b.tableoid = pg_class.oid;

SELECT
    relname,
    c.*
FROM
    ONLY c,
    pg_class
WHERE
    c.tableoid = pg_class.oid;

SELECT
    relname,
    d.*
FROM
    ONLY d,
    pg_class
WHERE
    d.tableoid = pg_class.oid;

DELETE FROM a;

SELECT
    relname,
    a.*
FROM
    a,
    pg_class
WHERE
    a.tableoid = pg_class.oid;

SELECT
    relname,
    b.*
FROM
    b,
    pg_class
WHERE
    b.tableoid = pg_class.oid;

SELECT
    relname,
    c.*
FROM
    c,
    pg_class
WHERE
    c.tableoid = pg_class.oid;

SELECT
    relname,
    d.*
FROM
    d,
    pg_class
WHERE
    d.tableoid = pg_class.oid;

SELECT
    relname,
    a.*
FROM
    ONLY a,
    pg_class
WHERE
    a.tableoid = pg_class.oid;

SELECT
    relname,
    b.*
FROM
    ONLY b,
    pg_class
WHERE
    b.tableoid = pg_class.oid;

SELECT
    relname,
    c.*
FROM
    ONLY c,
    pg_class
WHERE
    c.tableoid = pg_class.oid;

SELECT
    relname,
    d.*
FROM
    ONLY d,
    pg_class
WHERE
    d.tableoid = pg_class.oid;

-- Confirm PRIMARY KEY adds NOT NULL constraint to child table
CREATE TEMP TABLE z (b TEXT, PRIMARY KEY (aa, b)) inherits (a);

INSERT INTO
    z
VALUES
    (NULL, 'text');

-- should fail
-- Check inherited UPDATE with all children excluded
CREATE TABLE some_tab (a int, b int);

CREATE TABLE some_tab_child () inherits (some_tab);

INSERT INTO
    some_tab_child
VALUES
    (1, 2);

EXPLAIN (VERBOSE, costs off)
UPDATE some_tab
SET
    a = a + 1
WHERE
    FALSE;

UPDATE some_tab
SET
    a = a + 1
WHERE
    FALSE;

EXPLAIN (VERBOSE, costs off)
UPDATE some_tab
SET
    a = a + 1
WHERE
    FALSE
RETURNING
    b,
    a;

UPDATE some_tab
SET
    a = a + 1
WHERE
    FALSE
RETURNING
    b,
    a;

TABLE some_tab;

DROP TABLE some_tab cascade;

-- Check UPDATE with inherited target and an inherited source table
CREATE TEMP TABLE foo (f1 int, f2 int);

CREATE TEMP TABLE foo2 (f3 int) inherits (foo);

CREATE TEMP TABLE bar (f1 int, f2 int);

CREATE TEMP TABLE bar2 (f3 int) inherits (bar);

INSERT INTO
    foo
VALUES
    (1, 1);

INSERT INTO
    foo
VALUES
    (3, 3);

INSERT INTO
    foo2
VALUES
    (2, 2, 2);

INSERT INTO
    foo2
VALUES
    (3, 3, 3);

INSERT INTO
    bar
VALUES
    (1, 1);

INSERT INTO
    bar
VALUES
    (2, 2);

INSERT INTO
    bar
VALUES
    (3, 3);

INSERT INTO
    bar
VALUES
    (4, 4);

INSERT INTO
    bar2
VALUES
    (1, 1, 1);

INSERT INTO
    bar2
VALUES
    (2, 2, 2);

INSERT INTO
    bar2
VALUES
    (3, 3, 3);

INSERT INTO
    bar2
VALUES
    (4, 4, 4);

UPDATE bar
SET
    f2 = f2 + 100
WHERE
    f1 IN (
        SELECT
            f1
        FROM
            foo);

SELECT
    tableoid::regclass::text AS relname,
    bar.*
FROM
    bar
ORDER BY
    1,
    2;

-- Check UPDATE with inherited target and an appendrel subquery
UPDATE bar
SET
    f2 = f2 + 100
FROM (
        SELECT
            f1
        FROM
            foo
        UNION ALL
        SELECT
            f1 + 3
        FROM
            foo) ss
WHERE
    bar.f1 = ss.f1;

SELECT
    tableoid::regclass::text AS relname,
    bar.*
FROM
    bar
ORDER BY
    1,
    2;

-- Check UPDATE with *partitioned* inherited target and an appendrel subquery
CREATE TABLE some_tab (a int);

INSERT INTO
    some_tab
VALUES
    (0);

CREATE TABLE some_tab_child () inherits (some_tab);

INSERT INTO
    some_tab_child
VALUES
    (1);

CREATE TABLE parted_tab (a int, b char)
PARTITION BY
    list (a);

CREATE TABLE parted_tab_part1 partition of parted_tab FOR
VALUES
    IN (1);

CREATE TABLE parted_tab_part2 partition of parted_tab FOR
VALUES
    IN (2);

CREATE TABLE parted_tab_part3 partition of parted_tab FOR
VALUES
    IN (3);

INSERT INTO
    parted_tab
VALUES
    (1, 'a'),
    (2, 'a'),
    (3, 'a');

UPDATE parted_tab
SET
    b = 'b'
FROM (
        SELECT
            a
        FROM
            some_tab
        UNION ALL
        SELECT
            a + 1
        FROM
            some_tab) ss (a)
WHERE
    parted_tab.a = ss.a;

SELECT
    tableoid::regclass::text AS relname,
    parted_tab.*
FROM
    parted_tab
ORDER BY
    1,
    2;

TRUNCATE parted_tab;

INSERT INTO
    parted_tab
VALUES
    (1, 'a'),
    (2, 'a'),
    (3, 'a');

UPDATE parted_tab
SET
    b = 'b'
FROM (
        SELECT
            0
        FROM
            parted_tab
        UNION ALL
        SELECT
            1
        FROM
            parted_tab) ss (a)
WHERE
    parted_tab.a = ss.a;

SELECT
    tableoid::regclass::text AS relname,
    parted_tab.*
FROM
    parted_tab
ORDER BY
    1,
    2;

-- modifies partition key, but no rows will actually be updated
EXPLAIN
UPDATE parted_tab
SET
    a = 2
WHERE
    FALSE;

DROP TABLE parted_tab;

-- Check UPDATE with multi-level partitioned inherited target
CREATE TABLE mlparted_tab (a int, b char, c text)
PARTITION BY
    list (a);

CREATE TABLE mlparted_tab_part1 partition of mlparted_tab FOR
VALUES
    IN (1);

CREATE TABLE mlparted_tab_part2 partition of mlparted_tab FOR
VALUES
    IN (2)
PARTITION BY
    list (b);

CREATE TABLE mlparted_tab_part3 partition of mlparted_tab FOR
VALUES
    IN (3);

CREATE TABLE mlparted_tab_part2a partition of mlparted_tab_part2 FOR
VALUES
    IN ('a');

CREATE TABLE mlparted_tab_part2b partition of mlparted_tab_part2 FOR
VALUES
    IN ('b');

INSERT INTO
    mlparted_tab
VALUES
    (1, 'a'),
    (2, 'a'),
    (2, 'b'),
    (3, 'a');

UPDATE mlparted_tab mlp
SET
    c = 'xxx'
FROM (
        SELECT
            a
        FROM
            some_tab
        UNION ALL
        SELECT
            a + 1
        FROM
            some_tab) ss (a)
WHERE (
        mlp.a = ss.a
        AND mlp.b = 'b')
    OR mlp.a = 3;

SELECT
    tableoid::regclass::text AS relname,
    mlparted_tab.*
FROM
    mlparted_tab
ORDER BY
    1,
    2;

DROP TABLE mlparted_tab;

DROP TABLE some_tab cascade;

/* Test multiple inheritance of column defaults */
CREATE TABLE firstparent (tomorrow date DEFAULT now()::date + 1);

CREATE TABLE secondparent (tomorrow date DEFAULT now()::date + 1);

CREATE TABLE jointchild () INHERITS (firstparent, secondparent);

-- ok
CREATE TABLE thirdparent (tomorrow date DEFAULT now()::date - 1);

CREATE TABLE otherchild () INHERITS (firstparent, thirdparent);

-- not ok
CREATE TABLE otherchild (tomorrow date DEFAULT now()) INHERITS (firstparent, thirdparent);

-- ok, child resolves ambiguous default
DROP TABLE firstparent,
secondparent,
jointchild,
thirdparent,
otherchild;

-- Test changing the type of inherited columns
INSERT INTO
    d
VALUES
    ('test', 'one', 'two', 'three');

ALTER TABLE a
ALTER COLUMN aa type integer USING bit_length(aa);

SELECT
    *
FROM
    d;

-- Test non-inheritable parent constraints
CREATE TABLE p1 (ff1 int);

ALTER TABLE p1
ADD CONSTRAINT p1chk CHECK (ff1 > 0) no inherit;

ALTER TABLE p1
ADD CONSTRAINT p2chk CHECK (ff1 > 10);

-- connoinherit should be true for NO INHERIT constraint
SELECT
    pc.relname,
    pgc.conname,
    pgc.contype,
    pgc.conislocal,
    pgc.coninhcount,
    pgc.connoinherit
FROM
    pg_class AS pc
    INNER JOIN pg_constraint AS pgc ON (pgc.conrelid = pc.oid)
WHERE
    pc.relname = 'p1'
ORDER BY
    1,
    2;

-- Test that child does not inherit NO INHERIT constraints
CREATE TABLE c1 () inherits (p1);

\d p1
\d c1
-- Test that child does not override inheritable constraints of the parent
CREATE TABLE c2 (CONSTRAINT p2chk CHECK (ff1 > 10) no inherit) inherits (p1);

--fails
DROP TABLE p1 cascade;

-- Tests for casting between the rowtypes of parent and child
-- tables. See the pgsql-hackers thread beginning Dec. 4/04
CREATE TABLE base (i integer);

CREATE TABLE derived () inherits (base);

CREATE TABLE more_derived (LIKE derived, b int) inherits (derived);

INSERT INTO
    derived (i)
VALUES
    (0);

SELECT
    derived::base
FROM
    derived;

SELECT
    NULL::derived::base;

-- remove redundant conversions.
EXPLAIN (VERBOSE ON, costs off)
SELECT
    ROW (i, b)::more_derived::derived::base
FROM
    more_derived;

EXPLAIN (VERBOSE ON, costs off)
SELECT
    (1, 2)::more_derived::derived::base;

DROP TABLE more_derived;

DROP TABLE derived;

DROP TABLE base;

CREATE TABLE p1 (ff1 int);

CREATE TABLE p2 (f1 text);

CREATE FUNCTION p2text (p2) returns text AS 'select $1.f1' language sql;

CREATE TABLE c1 (f3 int) inherits (p1, p2);

INSERT INTO
    c1
VALUES
    (123456789, 'hi', 42);

SELECT
    p2text (c1.*)
FROM
    c1;

DROP FUNCTION p2text (p2);

DROP TABLE c1;

DROP TABLE p2;

DROP TABLE p1;

CREATE TABLE ac (aa TEXT);

ALTER TABLE ac
ADD CONSTRAINT ac_check CHECK (aa IS NOT NULL);

CREATE TABLE bc (bb TEXT) INHERITS (ac);

SELECT
    pc.relname,
    pgc.conname,
    pgc.contype,
    pgc.conislocal,
    pgc.coninhcount,
    pg_get_expr(pgc.conbin, pc.oid) AS consrc
FROM
    pg_class AS pc
    INNER JOIN pg_constraint AS pgc ON (pgc.conrelid = pc.oid)
WHERE
    pc.relname IN ('ac', 'bc')
ORDER BY
    1,
    2;

INSERT INTO
    ac (aa)
VALUES
    (NULL);

INSERT INTO
    bc (aa)
VALUES
    (NULL);

ALTER TABLE bc
DROP CONSTRAINT ac_check;

-- fail, disallowed
ALTER TABLE ac
DROP CONSTRAINT ac_check;

SELECT
    pc.relname,
    pgc.conname,
    pgc.contype,
    pgc.conislocal,
    pgc.coninhcount,
    pg_get_expr(pgc.conbin, pc.oid) AS consrc
FROM
    pg_class AS pc
    INNER JOIN pg_constraint AS pgc ON (pgc.conrelid = pc.oid)
WHERE
    pc.relname IN ('ac', 'bc')
ORDER BY
    1,
    2;

-- try the unnamed-constraint case
ALTER TABLE ac
ADD CHECK (aa IS NOT NULL);

SELECT
    pc.relname,
    pgc.conname,
    pgc.contype,
    pgc.conislocal,
    pgc.coninhcount,
    pg_get_expr(pgc.conbin, pc.oid) AS consrc
FROM
    pg_class AS pc
    INNER JOIN pg_constraint AS pgc ON (pgc.conrelid = pc.oid)
WHERE
    pc.relname IN ('ac', 'bc')
ORDER BY
    1,
    2;

INSERT INTO
    ac (aa)
VALUES
    (NULL);

INSERT INTO
    bc (aa)
VALUES
    (NULL);

ALTER TABLE bc
DROP CONSTRAINT ac_aa_check;

-- fail, disallowed
ALTER TABLE ac
DROP CONSTRAINT ac_aa_check;

SELECT
    pc.relname,
    pgc.conname,
    pgc.contype,
    pgc.conislocal,
    pgc.coninhcount,
    pg_get_expr(pgc.conbin, pc.oid) AS consrc
FROM
    pg_class AS pc
    INNER JOIN pg_constraint AS pgc ON (pgc.conrelid = pc.oid)
WHERE
    pc.relname IN ('ac', 'bc')
ORDER BY
    1,
    2;

ALTER TABLE ac
ADD CONSTRAINT ac_check CHECK (aa IS NOT NULL);

ALTER TABLE bc no inherit ac;

SELECT
    pc.relname,
    pgc.conname,
    pgc.contype,
    pgc.conislocal,
    pgc.coninhcount,
    pg_get_expr(pgc.conbin, pc.oid) AS consrc
FROM
    pg_class AS pc
    INNER JOIN pg_constraint AS pgc ON (pgc.conrelid = pc.oid)
WHERE
    pc.relname IN ('ac', 'bc')
ORDER BY
    1,
    2;

ALTER TABLE bc
DROP CONSTRAINT ac_check;

SELECT
    pc.relname,
    pgc.conname,
    pgc.contype,
    pgc.conislocal,
    pgc.coninhcount,
    pg_get_expr(pgc.conbin, pc.oid) AS consrc
FROM
    pg_class AS pc
    INNER JOIN pg_constraint AS pgc ON (pgc.conrelid = pc.oid)
WHERE
    pc.relname IN ('ac', 'bc')
ORDER BY
    1,
    2;

ALTER TABLE ac
DROP CONSTRAINT ac_check;

SELECT
    pc.relname,
    pgc.conname,
    pgc.contype,
    pgc.conislocal,
    pgc.coninhcount,
    pg_get_expr(pgc.conbin, pc.oid) AS consrc
FROM
    pg_class AS pc
    INNER JOIN pg_constraint AS pgc ON (pgc.conrelid = pc.oid)
WHERE
    pc.relname IN ('ac', 'bc')
ORDER BY
    1,
    2;

DROP TABLE bc;

DROP TABLE ac;

CREATE TABLE ac (a int CONSTRAINT check_a CHECK (a <> 0));

CREATE TABLE bc (
    a int CONSTRAINT check_a CHECK (a <> 0),
    b int CONSTRAINT check_b CHECK (b <> 0)) inherits (ac);

SELECT
    pc.relname,
    pgc.conname,
    pgc.contype,
    pgc.conislocal,
    pgc.coninhcount,
    pg_get_expr(pgc.conbin, pc.oid) AS consrc
FROM
    pg_class AS pc
    INNER JOIN pg_constraint AS pgc ON (pgc.conrelid = pc.oid)
WHERE
    pc.relname IN ('ac', 'bc')
ORDER BY
    1,
    2;

DROP TABLE bc;

DROP TABLE ac;

CREATE TABLE ac (a int CONSTRAINT check_a CHECK (a <> 0));

CREATE TABLE bc (b int CONSTRAINT check_b CHECK (b <> 0));

CREATE TABLE cc (c int CONSTRAINT check_c CHECK (c <> 0)) inherits (ac, bc);

SELECT
    pc.relname,
    pgc.conname,
    pgc.contype,
    pgc.conislocal,
    pgc.coninhcount,
    pg_get_expr(pgc.conbin, pc.oid) AS consrc
FROM
    pg_class AS pc
    INNER JOIN pg_constraint AS pgc ON (pgc.conrelid = pc.oid)
WHERE
    pc.relname IN ('ac', 'bc', 'cc')
ORDER BY
    1,
    2;

ALTER TABLE cc no inherit bc;

SELECT
    pc.relname,
    pgc.conname,
    pgc.contype,
    pgc.conislocal,
    pgc.coninhcount,
    pg_get_expr(pgc.conbin, pc.oid) AS consrc
FROM
    pg_class AS pc
    INNER JOIN pg_constraint AS pgc ON (pgc.conrelid = pc.oid)
WHERE
    pc.relname IN ('ac', 'bc', 'cc')
ORDER BY
    1,
    2;

DROP TABLE cc;

DROP TABLE bc;

DROP TABLE ac;

CREATE TABLE p1 (f1 int);

CREATE TABLE p2 (f2 int);

CREATE TABLE c1 (f3 int) inherits (p1, p2);

INSERT INTO
    c1
VALUES
    (1, -1, 2);

ALTER TABLE p2
ADD CONSTRAINT cc CHECK (f2 > 0);

-- fail
ALTER TABLE p2
ADD CHECK (f2 > 0);

-- check it without a name, too
DELETE FROM c1;

INSERT INTO
    c1
VALUES
    (1, 1, 2);

ALTER TABLE p2
ADD CHECK (f2 > 0);

INSERT INTO
    c1
VALUES
    (1, -1, 2);

-- fail
CREATE TABLE c2 (f3 int) inherits (p1, p2);

\d c2
CREATE TABLE c3 (f4 int) inherits (c1, c2);

\d c3
DROP TABLE p1 cascade;

DROP TABLE p2 cascade;

CREATE TABLE pp1 (f1 int);

CREATE TABLE cc1 (f2 text, f3 int) inherits (pp1);

ALTER TABLE pp1
ADD COLUMN a1 int CHECK (a1 > 0);

\d cc1
CREATE TABLE cc2 (f4 float) inherits (pp1, cc1);

\d cc2
ALTER TABLE pp1
ADD COLUMN a2 int CHECK (a2 > 0);

\d cc2
DROP TABLE pp1 cascade;

-- Test for renaming in simple multiple inheritance
CREATE TABLE inht1 (a int, b int);

CREATE TABLE inhs1 (b int, c int);

CREATE TABLE inhts (d int) INHERITS (inht1, inhs1);

ALTER TABLE inht1
RENAME a TO aa;

ALTER TABLE inht1
RENAME b TO bb;

-- to be failed
ALTER TABLE inhts
RENAME aa TO aaa;

-- to be failed
ALTER TABLE inhts
RENAME d TO dd;

\d+ inhts
DROP TABLE inhts;

-- Test for renaming in diamond inheritance
CREATE TABLE inht2 (x int) INHERITS (inht1);

CREATE TABLE inht3 (y int) INHERITS (inht1);

CREATE TABLE inht4 (z int) INHERITS (inht2, inht3);

ALTER TABLE inht1
RENAME aa TO aaa;

\d+ inht4
CREATE TABLE inhts (d int) INHERITS (inht2, inhs1);

ALTER TABLE inht1
RENAME aaa TO aaaa;

ALTER TABLE inht1
RENAME b TO bb;

-- to be failed
\d+ inhts
WITH RECURSIVE
    r AS (
        SELECT
            'inht1'::regclass AS inhrelid
        UNION ALL
        SELECT
            c.inhrelid
        FROM
            pg_inherits c,
            r
        WHERE
            r.inhrelid = c.inhparent)
SELECT
    a.attrelid::regclass,
    a.attname,
    a.attinhcount,
    e.expected
FROM (
        SELECT
            inhrelid,
            count(*) AS expected
        FROM
            pg_inherits
        WHERE
            inhparent IN (
                SELECT
                    inhrelid
                FROM
                    r)
        GROUP BY
            inhrelid) e
    JOIN pg_attribute a ON e.inhrelid = a.attrelid
WHERE
    NOT attislocal
ORDER BY
    a.attrelid::regclass::name,
    a.attnum;

DROP TABLE inht1,
inhs1 CASCADE;

-- Test non-inheritable indices [UNIQUE, EXCLUDE] constraints
CREATE TABLE test_constraints (
    id int,
    val1 varchar,
    val2 int,
    UNIQUE (val1, val2));

CREATE TABLE test_constraints_inh () INHERITS (test_constraints);

\d+ test_constraints
ALTER TABLE ONLY test_constraints
DROP CONSTRAINT test_constraints_val1_val2_key;

\d+ test_constraints
\d+ test_constraints_inh
DROP TABLE test_constraints_inh;

DROP TABLE test_constraints;

CREATE TABLE test_ex_constraints (
    c circle,
    EXCLUDE USING gist (
        c
        WITH
            &&));

CREATE TABLE test_ex_constraints_inh () INHERITS (test_ex_constraints);

\d+ test_ex_constraints
ALTER TABLE test_ex_constraints
DROP CONSTRAINT test_ex_constraints_c_excl;

\d+ test_ex_constraints
\d+ test_ex_constraints_inh
DROP TABLE test_ex_constraints_inh;

DROP TABLE test_ex_constraints;

-- Test non-inheritable foreign key constraints
CREATE TABLE test_primary_constraints (id int PRIMARY KEY);

CREATE TABLE test_foreign_constraints (id1 int REFERENCES test_primary_constraints (id));

CREATE TABLE test_foreign_constraints_inh () INHERITS (test_foreign_constraints);

\d+ test_primary_constraints
\d+ test_foreign_constraints
ALTER TABLE test_foreign_constraints
DROP CONSTRAINT test_foreign_constraints_id1_fkey;

\d+ test_foreign_constraints
\d+ test_foreign_constraints_inh
DROP TABLE test_foreign_constraints_inh;

DROP TABLE test_foreign_constraints;

DROP TABLE test_primary_constraints;

-- Test foreign key behavior
CREATE TABLE inh_fk_1 (a int PRIMARY KEY);

INSERT INTO
    inh_fk_1
VALUES
    (1),
    (2),
    (3);

CREATE TABLE inh_fk_2 (
    x int PRIMARY KEY,
    y int REFERENCES inh_fk_1 ON DELETE CASCADE);

INSERT INTO
    inh_fk_2
VALUES
    (11, 1),
    (22, 2),
    (33, 3);

CREATE TABLE inh_fk_2_child () inherits (inh_fk_2);

INSERT INTO
    inh_fk_2_child
VALUES
    (111, 1),
    (222, 2);

DELETE FROM inh_fk_1
WHERE
    a = 1;

SELECT
    *
FROM
    inh_fk_1
ORDER BY
    1;

SELECT
    *
FROM
    inh_fk_2
ORDER BY
    1,
    2;

DROP TABLE inh_fk_1,
inh_fk_2,
inh_fk_2_child;

-- Test that parent and child CHECK constraints can be created in either order
CREATE TABLE p1 (f1 int);

CREATE TABLE p1_c1 () inherits (p1);

ALTER TABLE p1
ADD CONSTRAINT inh_check_constraint1 CHECK (f1 > 0);

ALTER TABLE p1_c1
ADD CONSTRAINT inh_check_constraint1 CHECK (f1 > 0);

ALTER TABLE p1_c1
ADD CONSTRAINT inh_check_constraint2 CHECK (f1 < 10);

ALTER TABLE p1
ADD CONSTRAINT inh_check_constraint2 CHECK (f1 < 10);

SELECT
    conrelid::regclass::text AS relname,
    conname,
    conislocal,
    coninhcount
FROM
    pg_constraint
WHERE
    conname LIKE 'inh\_check\_constraint%'
ORDER BY
    1,
    2;

DROP TABLE p1 cascade;

-- Test that a valid child can have not-valid parent, but not vice versa
CREATE TABLE invalid_check_con (f1 int);

CREATE TABLE invalid_check_con_child () inherits (invalid_check_con);

ALTER TABLE invalid_check_con_child
ADD CONSTRAINT inh_check_constraint CHECK (f1 > 0) NOT valid;

ALTER TABLE invalid_check_con
ADD CONSTRAINT inh_check_constraint CHECK (f1 > 0);

-- fail
ALTER TABLE invalid_check_con_child
DROP CONSTRAINT inh_check_constraint;

INSERT INTO
    invalid_check_con
VALUES
    (0);

ALTER TABLE invalid_check_con_child
ADD CONSTRAINT inh_check_constraint CHECK (f1 > 0);

ALTER TABLE invalid_check_con
ADD CONSTRAINT inh_check_constraint CHECK (f1 > 0) NOT valid;

INSERT INTO
    invalid_check_con
VALUES
    (0);

-- fail
INSERT INTO
    invalid_check_con_child
VALUES
    (0);

-- fail
SELECT
    conrelid::regclass::text AS relname,
    conname,
    convalidated,
    conislocal,
    coninhcount,
    connoinherit
FROM
    pg_constraint
WHERE
    conname LIKE 'inh\_check\_constraint%'
ORDER BY
    1,
    2;

-- We don't drop the invalid_check_con* tables, to test dump/reload with
--
-- Test parameterized append plans for inheritance trees
--
CREATE TEMP TABLE patest0 (id, x) AS
SELECT
    x,
    x
FROM
    generate_series(0, 1000) x;

CREATE TEMP TABLE patest1 () inherits (patest0);

INSERT INTO
    patest1
SELECT
    x,
    x
FROM
    generate_series(0, 1000) x;

CREATE TEMP TABLE patest2 () inherits (patest0);

INSERT INTO
    patest2
SELECT
    x,
    x
FROM
    generate_series(0, 1000) x;

CREATE INDEX patest0i ON patest0 (id);

CREATE INDEX patest1i ON patest1 (id);

CREATE INDEX patest2i ON patest2 (id);

ANALYZE patest0;

ANALYZE patest1;

ANALYZE patest2;

EXPLAIN (costs off)
SELECT
    *
FROM
    patest0
    JOIN (
        SELECT
            f1
        FROM
            int4_tbl
        LIMIT
            1) ss ON id = f1;

SELECT
    *
FROM
    patest0
    JOIN (
        SELECT
            f1
        FROM
            int4_tbl
        LIMIT
            1) ss ON id = f1;

DROP INDEX patest2i;

EXPLAIN (costs off)
SELECT
    *
FROM
    patest0
    JOIN (
        SELECT
            f1
        FROM
            int4_tbl
        LIMIT
            1) ss ON id = f1;

SELECT
    *
FROM
    patest0
    JOIN (
        SELECT
            f1
        FROM
            int4_tbl
        LIMIT
            1) ss ON id = f1;

DROP TABLE patest0 cascade;

--
-- Test merge-append plans for inheritance trees
--
CREATE TABLE matest0 (id serial PRIMARY KEY, name text);

CREATE TABLE matest1 (id integer PRIMARY KEY) inherits (matest0);

CREATE TABLE matest2 (id integer PRIMARY KEY) inherits (matest0);

CREATE TABLE matest3 (id integer PRIMARY KEY) inherits (matest0);

CREATE INDEX matest0i ON matest0 ((1 - id));

CREATE INDEX matest1i ON matest1 ((1 - id));

-- create index matest2i on matest2 ((1-id));  -- intentionally missing
CREATE INDEX matest3i ON matest3 ((1 - id));

INSERT INTO
    matest1 (name)
VALUES
    ('Test 1');

INSERT INTO
    matest1 (name)
VALUES
    ('Test 2');

INSERT INTO
    matest2 (name)
VALUES
    ('Test 3');

INSERT INTO
    matest2 (name)
VALUES
    ('Test 4');

INSERT INTO
    matest3 (name)
VALUES
    ('Test 5');

INSERT INTO
    matest3 (name)
VALUES
    ('Test 6');

SET
    enable_indexscan = off;

-- force use of seqscan/sort, so no merge
EXPLAIN (VERBOSE, costs off)
SELECT
    *
FROM
    matest0
ORDER BY
    1 - id;

SELECT
    *
FROM
    matest0
ORDER BY
    1 - id;

EXPLAIN (VERBOSE, costs off)
SELECT
    min(1 - id)
FROM
    matest0;

SELECT
    min(1 - id)
FROM
    matest0;

RESET enable_indexscan;

SET
    enable_seqscan = off;

-- plan with fewest seqscans should be merge
SET
    enable_parallel_append = off;

-- Don't let parallel-append interfere
EXPLAIN (VERBOSE, costs off)
SELECT
    *
FROM
    matest0
ORDER BY
    1 - id;

SELECT
    *
FROM
    matest0
ORDER BY
    1 - id;

EXPLAIN (VERBOSE, costs off)
SELECT
    min(1 - id)
FROM
    matest0;

SELECT
    min(1 - id)
FROM
    matest0;

RESET enable_seqscan;

RESET enable_parallel_append;

DROP TABLE matest0 cascade;

--
-- Check that use of an index with an extraneous column doesn't produce
-- a plan with extraneous sorting
--
CREATE TABLE matest0 (a int, b int, c int, d int);

CREATE TABLE matest1 () inherits (matest0);

CREATE INDEX matest0i ON matest0 (b, c);

CREATE INDEX matest1i ON matest1 (b, c);

SET
    enable_nestloop = off;

-- we want a plan with two MergeAppends
EXPLAIN (costs off)
SELECT
    t1.*
FROM
    matest0 t1,
    matest0 t2
WHERE
    t1.b = t2.b
    AND t2.c = t2.d
ORDER BY
    t1.b
LIMIT
    10;

RESET enable_nestloop;

DROP TABLE matest0 cascade;

--
-- Test merge-append for UNION ALL append relations
--
SET
    enable_seqscan = off;

SET
    enable_indexscan = ON;

SET
    enable_bitmapscan = off;

-- Check handling of duplicated, constant, or volatile targetlist items
EXPLAIN (costs off)
SELECT
    thousand,
    tenthous
FROM
    tenk1
UNION ALL
SELECT
    thousand,
    thousand
FROM
    tenk1
ORDER BY
    thousand,
    tenthous;

EXPLAIN (costs off)
SELECT
    thousand,
    tenthous,
    thousand + tenthous AS x
FROM
    tenk1
UNION ALL
SELECT
    42,
    42,
    hundred
FROM
    tenk1
ORDER BY
    thousand,
    tenthous;

EXPLAIN (costs off)
SELECT
    thousand,
    tenthous
FROM
    tenk1
UNION ALL
SELECT
    thousand,
    random()::integer
FROM
    tenk1
ORDER BY
    thousand,
    tenthous;

-- Check min/max aggregate optimization
EXPLAIN (costs off)
SELECT
    min(x)
FROM (
        SELECT
            unique1 AS x
        FROM
            tenk1 a
        UNION ALL
        SELECT
            unique2 AS x
        FROM
            tenk1 b) s;

EXPLAIN (costs off)
SELECT
    min(y)
FROM (
        SELECT
            unique1 AS x,
            unique1 AS y
        FROM
            tenk1 a
        UNION ALL
        SELECT
            unique2 AS x,
            unique2 AS y
        FROM
            tenk1 b) s;

-- XXX planner doesn't recognize that index on unique2 is sufficiently sorted
EXPLAIN (costs off)
SELECT
    x,
    y
FROM (
        SELECT
            thousand AS x,
            tenthous AS y
        FROM
            tenk1 a
        UNION ALL
        SELECT
            unique2 AS x,
            unique2 AS y
        FROM
            tenk1 b) s
ORDER BY
    x,
    y;

-- exercise rescan code path via a repeatedly-evaluated subquery
EXPLAIN (costs off)
SELECT
    ARRAY (
        SELECT
            f.i
        FROM ( (
                    SELECT
                        d + g.i
                    FROM
                        generate_series(4, 30, 3) d
                    ORDER BY
                        1)
                UNION ALL (
                    SELECT
                        d + g.i
                    FROM
                        generate_series(0, 30, 5) d
                    ORDER BY
                        1)) f (i)
        ORDER BY
            f.i
        LIMIT
            10)
FROM
    generate_series(1, 3) g (i);

SELECT
    ARRAY (
        SELECT
            f.i
        FROM ( (
                    SELECT
                        d + g.i
                    FROM
                        generate_series(4, 30, 3) d
                    ORDER BY
                        1)
                UNION ALL (
                    SELECT
                        d + g.i
                    FROM
                        generate_series(0, 30, 5) d
                    ORDER BY
                        1)) f (i)
        ORDER BY
            f.i
        LIMIT
            10)
FROM
    generate_series(1, 3) g (i);

RESET enable_seqscan;

RESET enable_indexscan;

RESET enable_bitmapscan;

--
-- Check handling of a constant-null CHECK constraint
--
CREATE TABLE cnullparent (f1 int);

CREATE TABLE cnullchild (
    CHECK (
        f1 = 1
        OR f1 = NULL)) inherits (cnullparent);

INSERT INTO
    cnullchild
VALUES
    (1);

INSERT INTO
    cnullchild
VALUES
    (2);

INSERT INTO
    cnullchild
VALUES
    (NULL);

SELECT
    *
FROM
    cnullparent;

SELECT
    *
FROM
    cnullparent
WHERE
    f1 = 2;

DROP TABLE cnullparent cascade;

--
-- Check use of temporary tables with inheritance trees
--
CREATE TABLE inh_perm_parent (a1 int);

CREATE TEMP TABLE inh_temp_parent (a1 int);

CREATE TEMP TABLE inh_temp_child () inherits (inh_perm_parent);

-- ok
CREATE TABLE inh_perm_child () inherits (inh_temp_parent);

-- error
CREATE TEMP TABLE inh_temp_child_2 () inherits (inh_temp_parent);

-- ok
INSERT INTO
    inh_perm_parent
VALUES
    (1);

INSERT INTO
    inh_temp_parent
VALUES
    (2);

INSERT INTO
    inh_temp_child
VALUES
    (3);

INSERT INTO
    inh_temp_child_2
VALUES
    (4);

SELECT
    tableoid::regclass,
    a1
FROM
    inh_perm_parent;

SELECT
    tableoid::regclass,
    a1
FROM
    inh_temp_parent;

DROP TABLE inh_perm_parent cascade;

DROP TABLE inh_temp_parent cascade;

--
-- Check that constraint exclusion works correctly with partitions using
-- implicit constraints generated from the partition bound information.
--
CREATE TABLE list_parted (a varchar)
PARTITION BY
    list (a);

CREATE TABLE part_ab_cd partition of list_parted FOR
VALUES
    IN ('ab', 'cd');

CREATE TABLE part_ef_gh partition of list_parted FOR
VALUES
    IN ('ef', 'gh');

CREATE TABLE part_null_xy partition of list_parted FOR
VALUES
    IN (NULL, 'xy');

EXPLAIN (costs off)
SELECT
    *
FROM
    list_parted;

EXPLAIN (costs off)
SELECT
    *
FROM
    list_parted
WHERE
    a IS NULL;

EXPLAIN (costs off)
SELECT
    *
FROM
    list_parted
WHERE
    a IS NOT NULL;

EXPLAIN (costs off)
SELECT
    *
FROM
    list_parted
WHERE
    a IN ('ab', 'cd', 'ef');

EXPLAIN (costs off)
SELECT
    *
FROM
    list_parted
WHERE
    a = 'ab'
    OR a IN (NULL, 'cd');

EXPLAIN (costs off)
SELECT
    *
FROM
    list_parted
WHERE
    a = 'ab';

CREATE TABLE range_list_parted (a int, b char(2))
PARTITION BY
    range (a);

CREATE TABLE part_1_10 partition of range_list_parted FOR
VALUES
FROM
    (1) TO (10)
PARTITION BY
    list (b);

CREATE TABLE part_1_10_ab partition of part_1_10 FOR
VALUES
    IN ('ab');

CREATE TABLE part_1_10_cd partition of part_1_10 FOR
VALUES
    IN ('cd');

CREATE TABLE part_10_20 partition of range_list_parted FOR
VALUES
FROM
    (10) TO (20)
PARTITION BY
    list (b);

CREATE TABLE part_10_20_ab partition of part_10_20 FOR
VALUES
    IN ('ab');

CREATE TABLE part_10_20_cd partition of part_10_20 FOR
VALUES
    IN ('cd');

CREATE TABLE part_21_30 partition of range_list_parted FOR
VALUES
FROM
    (21) TO (30)
PARTITION BY
    list (b);

CREATE TABLE part_21_30_ab partition of part_21_30 FOR
VALUES
    IN ('ab');

CREATE TABLE part_21_30_cd partition of part_21_30 FOR
VALUES
    IN ('cd');

CREATE TABLE part_40_inf partition of range_list_parted FOR
VALUES
FROM
    (40) TO (maxvalue)
PARTITION BY
    list (b);

CREATE TABLE part_40_inf_ab partition of part_40_inf FOR
VALUES
    IN ('ab');

CREATE TABLE part_40_inf_cd partition of part_40_inf FOR
VALUES
    IN ('cd');

CREATE TABLE part_40_inf_null partition of part_40_inf FOR
VALUES
    IN (NULL);

EXPLAIN (costs off)
SELECT
    *
FROM
    range_list_parted;

EXPLAIN (costs off)
SELECT
    *
FROM
    range_list_parted
WHERE
    a = 5;

EXPLAIN (costs off)
SELECT
    *
FROM
    range_list_parted
WHERE
    b = 'ab';

EXPLAIN (costs off)
SELECT
    *
FROM
    range_list_parted
WHERE
    a BETWEEN 3 AND 23
    AND b IN ('ab');

/* Should select no rows because range partition key cannot be null */
EXPLAIN (costs off)
SELECT
    *
FROM
    range_list_parted
WHERE
    a IS NULL;

/* Should only select rows from the null-accepting partition */
EXPLAIN (costs off)
SELECT
    *
FROM
    range_list_parted
WHERE
    b IS NULL;

EXPLAIN (costs off)
SELECT
    *
FROM
    range_list_parted
WHERE
    a IS NOT NULL
    AND a < 67;

EXPLAIN (costs off)
SELECT
    *
FROM
    range_list_parted
WHERE
    a >= 30;

DROP TABLE list_parted;

DROP TABLE range_list_parted;

-- check that constraint exclusion is able to cope with the partition
-- constraint emitted for multi-column range partitioned tables
CREATE TABLE mcrparted (a int, b int, c int)
PARTITION BY
    range (a, abs(b), c);

CREATE TABLE mcrparted_def partition of mcrparted DEFAULT;

CREATE TABLE mcrparted0 partition of mcrparted FOR
VALUES
FROM
    (minvalue, minvalue, minvalue) TO (1, 1, 1);

CREATE TABLE mcrparted1 partition of mcrparted FOR
VALUES
FROM
    (1, 1, 1) TO (10, 5, 10);

CREATE TABLE mcrparted2 partition of mcrparted FOR
VALUES
FROM
    (10, 5, 10) TO (10, 10, 10);

CREATE TABLE mcrparted3 partition of mcrparted FOR
VALUES
FROM
    (11, 1, 1) TO (20, 10, 10);

CREATE TABLE mcrparted4 partition of mcrparted FOR
VALUES
FROM
    (20, 10, 10) TO (20, 20, 20);

CREATE TABLE mcrparted5 partition of mcrparted FOR
VALUES
FROM
    (20, 20, 20) TO (maxvalue, maxvalue, maxvalue);

EXPLAIN (costs off)
SELECT
    *
FROM
    mcrparted
WHERE
    a = 0;

-- scans mcrparted0, mcrparted_def
EXPLAIN (costs off)
SELECT
    *
FROM
    mcrparted
WHERE
    a = 10
    AND abs(b) < 5;

-- scans mcrparted1, mcrparted_def
EXPLAIN (costs off)
SELECT
    *
FROM
    mcrparted
WHERE
    a = 10
    AND abs(b) = 5;

-- scans mcrparted1, mcrparted2, mcrparted_def
EXPLAIN (costs off)
SELECT
    *
FROM
    mcrparted
WHERE
    abs(b) = 5;

-- scans all partitions
EXPLAIN (costs off)
SELECT
    *
FROM
    mcrparted
WHERE
    a > -1;

-- scans all partitions
EXPLAIN (costs off)
SELECT
    *
FROM
    mcrparted
WHERE
    a = 20
    AND abs(b) = 10
    AND c > 10;

-- scans mcrparted4
EXPLAIN (costs off)
SELECT
    *
FROM
    mcrparted
WHERE
    a = 20
    AND c > 20;

-- scans mcrparted3, mcrparte4, mcrparte5, mcrparted_def
-- check that partitioned table Appends cope with being referenced in
-- subplans
CREATE TABLE parted_minmax (a int, b varchar(16))
PARTITION BY
    range (a);

CREATE TABLE parted_minmax1 partition of parted_minmax FOR
VALUES
FROM
    (1) TO (10);

CREATE INDEX parted_minmax1i ON parted_minmax1 (a, b);

INSERT INTO
    parted_minmax
VALUES
    (1, '12345');

EXPLAIN (costs off)
SELECT
    min(a),
    max(a)
FROM
    parted_minmax
WHERE
    b = '12345';

SELECT
    min(a),
    max(a)
FROM
    parted_minmax
WHERE
    b = '12345';

DROP TABLE parted_minmax;

-- Test code that uses Append nodes in place of MergeAppend when the
-- partition ordering matches the desired ordering.
CREATE INDEX mcrparted_a_abs_c_idx ON mcrparted (a, abs(b), c);

-- MergeAppend must be used when a default partition exists
EXPLAIN (costs off)
SELECT
    *
FROM
    mcrparted
ORDER BY
    a,
    abs(b),
    c;

DROP TABLE mcrparted_def;

-- Append is used for a RANGE partitioned table with no default
-- and no subpartitions
EXPLAIN (costs off)
SELECT
    *
FROM
    mcrparted
ORDER BY
    a,
    abs(b),
    c;

-- Append is used with subpaths in reverse order with backwards index scans
EXPLAIN (costs off)
SELECT
    *
FROM
    mcrparted
ORDER BY
    a DESC,
    abs(b) DESC,
    c DESC;

-- check that Append plan is used containing a MergeAppend for sub-partitions
-- that are unordered.
DROP TABLE mcrparted5;

CREATE TABLE mcrparted5 partition of mcrparted FOR
VALUES
FROM
    (20, 20, 20) TO (maxvalue, maxvalue, maxvalue)
PARTITION BY
    list (a);

CREATE TABLE mcrparted5a partition of mcrparted5 FOR
VALUES
    IN (20);

CREATE TABLE mcrparted5_def partition of mcrparted5 DEFAULT;

EXPLAIN (costs off)
SELECT
    *
FROM
    mcrparted
ORDER BY
    a,
    abs(b),
    c;

DROP TABLE mcrparted5_def;

-- check that an Append plan is used and the sub-partitions are flattened
-- into the main Append when the sub-partition is unordered but contains
-- just a single sub-partition.
EXPLAIN (costs off)
SELECT
    a,
    abs(b)
FROM
    mcrparted
ORDER BY
    a,
    abs(b),
    c;

-- check that Append is used when the sub-partitioned tables are pruned
-- during planning.
EXPLAIN (costs off)
SELECT
    *
FROM
    mcrparted
WHERE
    a < 20
ORDER BY
    a,
    abs(b),
    c;

CREATE TABLE mclparted (a int)
PARTITION BY
    list (a);

CREATE TABLE mclparted1 partition of mclparted FOR
VALUES
    IN (1);

CREATE TABLE mclparted2 partition of mclparted FOR
VALUES
    IN (2);

CREATE INDEX ON mclparted (a);

-- Ensure an Append is used for a list partition with an order by.
EXPLAIN (costs off)
SELECT
    *
FROM
    mclparted
ORDER BY
    a;

-- Ensure a MergeAppend is used when a partition exists with interleaved
-- datums in the partition bound.
CREATE TABLE mclparted3_5 partition of mclparted FOR
VALUES
    IN (3, 5);

CREATE TABLE mclparted4 partition of mclparted FOR
VALUES
    IN (4);

EXPLAIN (costs off)
SELECT
    *
FROM
    mclparted
ORDER BY
    a;

DROP TABLE mclparted;

-- Ensure subplans which don't have a path with the correct pathkeys get
-- sorted correctly.
DROP INDEX mcrparted_a_abs_c_idx;

CREATE INDEX ON mcrparted1 (a, abs(b), c);

CREATE INDEX ON mcrparted2 (a, abs(b), c);

CREATE INDEX ON mcrparted3 (a, abs(b), c);

CREATE INDEX ON mcrparted4 (a, abs(b), c);

EXPLAIN (costs off)
SELECT
    *
FROM
    mcrparted
WHERE
    a < 20
ORDER BY
    a,
    abs(b),
    c
LIMIT
    1;

SET
    enable_bitmapscan = 0;

-- Ensure Append node can be used when the partition is ordered by some
-- pathkeys which were deemed redundant.
EXPLAIN (costs off)
SELECT
    *
FROM
    mcrparted
WHERE
    a = 10
ORDER BY
    a,
    abs(b),
    c;

RESET enable_bitmapscan;

DROP TABLE mcrparted;

-- Ensure LIST partitions allow an Append to be used instead of a MergeAppend
CREATE TABLE bool_lp (b bool)
PARTITION BY
    list (b);

CREATE TABLE bool_lp_true partition of bool_lp FOR
VALUES
    IN (TRUE);

CREATE TABLE bool_lp_false partition of bool_lp FOR
VALUES
    IN (FALSE);

CREATE INDEX ON bool_lp (b);

EXPLAIN (costs off)
SELECT
    *
FROM
    bool_lp
ORDER BY
    b;

DROP TABLE bool_lp;

-- Ensure const bool quals can be properly detected as redundant
CREATE TABLE bool_rp (b bool, a int)
PARTITION BY
    range (b, a);

CREATE TABLE bool_rp_false_1k partition of bool_rp FOR
VALUES
FROM
    (FALSE, 0) TO (FALSE, 1000);

CREATE TABLE bool_rp_true_1k partition of bool_rp FOR
VALUES
FROM
    (TRUE, 0) TO (TRUE, 1000);

CREATE TABLE bool_rp_false_2k partition of bool_rp FOR
VALUES
FROM
    (FALSE, 1000) TO (FALSE, 2000);

CREATE TABLE bool_rp_true_2k partition of bool_rp FOR
VALUES
FROM
    (TRUE, 1000) TO (TRUE, 2000);

CREATE INDEX ON bool_rp (b, a);

EXPLAIN (costs off)
SELECT
    *
FROM
    bool_rp
WHERE
    b = TRUE
ORDER BY
    b,
    a;

EXPLAIN (costs off)
SELECT
    *
FROM
    bool_rp
WHERE
    b = FALSE
ORDER BY
    b,
    a;

EXPLAIN (costs off)
SELECT
    *
FROM
    bool_rp
WHERE
    b = TRUE
ORDER BY
    a;

EXPLAIN (costs off)
SELECT
    *
FROM
    bool_rp
WHERE
    b = FALSE
ORDER BY
    a;

DROP TABLE bool_rp;

-- Ensure an Append scan is chosen when the partition order is a subset of
-- the required order.
CREATE TABLE range_parted (a int, b int, c int)
PARTITION BY
    range (a, b);

CREATE TABLE range_parted1 partition of range_parted FOR
VALUES
FROM
    (0, 0) TO (10, 10);

CREATE TABLE range_parted2 partition of range_parted FOR
VALUES
FROM
    (10, 10) TO (20, 20);

CREATE INDEX ON range_parted (a, b, c);

EXPLAIN (costs off)
SELECT
    *
FROM
    range_parted
ORDER BY
    a,
    b,
    c;

EXPLAIN (costs off)
SELECT
    *
FROM
    range_parted
ORDER BY
    a DESC,
    b DESC,
    c DESC;

DROP TABLE range_parted;