CREATE TABLE kbln (
    id integer NOT NULL,
    blank_series varchar(50) NOT NULL,
    company_id varchar(8))
PARTITION BY
    range (id);

CREATE TABLE kbln_p0 partition of kbln FOR
VALUES
FROM
    (minvalue) TO (500000)
PARTITION BY
    hash (blank_series);

CREATE TABLE kbln_p0_1 partition of kbln_p0 FOR
VALUES
WITH
    (modulus 2, remainder 0);

CREATE TABLE kbln_p0_2 partition of kbln_p0 FOR
VALUES
WITH
    (modulus 2, remainder 1);

ALTER TABLE t1 detach partition t1_a;

ALTER TABLE t1 attach partition t1_a FOR
VALUES
    IN (1, 2, 3);

CREATE TABLE kbln (
    id integer NOT NULL,
    blank_series varchar(50) NOT NULL,
    company_id varchar(8))
PARTITION BY
    list (id);

SELECT
    id,
    for_group,
    some_val,
    sum(some_val) OVER (
        PARTITION BY
            for_group
        ORDER BY
            id) AS sum_so_far_in_group,
    sum(some_val) OVER (
        PARTITION BY
            for_group) AS sum_in_group,
    sum(some_val) OVER (
        PARTITION BY
            for_group
        ORDER BY
            id range 3 preceding) AS sum_current_and_3_preceeding,
    sum(some_val) OVER (
        PARTITION BY
            for_group
        ORDER BY
            id RANGE BETWEEN 3 preceding
            AND 3 following) AS sum_current_and_3_preceeding_and_3_following,
    sum(some_val) OVER (
        PARTITION BY
            for_group
        ORDER BY
            id RANGE BETWEEN current ROW
            AND unbounded following) AS sum_current_and_all_following
FROM
    test
ORDER BY
    for_group,
    id;