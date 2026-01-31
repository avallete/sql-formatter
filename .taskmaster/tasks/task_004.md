# Task ID: 4

**Title:** Skip MySQL DELIMITER test in pgFormatter (Category G)

**Status:** pending

**Dependencies:** None

**Priority:** low

**Description:** Exclude ex59.sql from PostgreSQL pgFormatter tests—it uses MySQL DELIMITER syntax.

**Details:**

In test/pgFormatter/pgFormatter.test.ts (or equivalent), skip or remove ex59.sql from the PostgreSQL expected files list. ex59.sql is MySQL syntax, not PostgreSQL.

**Test Strategy:**

Run pgFormatter tests and confirm ex59 is skipped; other tests still pass.
