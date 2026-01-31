# Task ID: 2

**Title:** Handle inline psql commands (Category B)

**Status:** pending

**Dependencies:** 1

**Priority:** medium

**Description:** Allow psql meta-commands like \gset, \g, \gx to appear at end of SQL statements, not only at line start.

**Details:**

**File:** `src/lexer/Tokenizer.ts` — same PSQL_COMMAND rule (after Task 1). Depends on Task 1 so the regex already uses `[a-zA-Z_!.]+`.

**Current behaviour:** The lookbehind `(?<=^|\\n)` only allows a match at start of input or immediately after a newline. So `SELECT 1 as a \\gset` fails because `\\gset` is preceded by space, not newline.

**Target behaviour:** These should parse and format:
- `SELECT 1 as a \\gset`
- `SELECT 'test' \\g testfile.txt`
- `\\g`, `\\gx` at end of a line of SQL

**Why it's safe:** In `buildRulesBeforeParams()` (Tokenizer.ts), LINE_COMMENT, BLOCK_COMMENT, QUOTED_IDENTIFIER, and string rules run before PSQL_COMMAND. So a backslash inside a string (e.g. `'x \\gset'`) is already consumed as part of a STRING token and never seen by the PSQL rule. We only need to allow the backslash-command to be preceded by optional horizontal whitespace on the same line.

**Exact change:** Relax the lookbehind to allow optional spaces/tabs before the backslash. Replace:
`/(?<=^|\\n)\\\\[a-zA-Z_!.]+[^\\n]*/uy`
with:
`/(?<=^|\n)[ \t]*\\[a-zA-Z_!.]+[^\n]*/uy`
So after start or newline we allow zero or more space/tab, then backslash, then command. Do not use `\\s` (would match newline and could change behaviour).

**Affected pgFormatter tests:** ex21.sql, psql.sql, psql_crosstab.sql (test-files); reloptions.sql, txid.sql (pg-test-files). See test/pgFormatter/pgFormatter.test.ts for the two describe blocks.

**Acceptance criteria:** All five files format without parse errors; a string containing `'\\gset'` remains one string token (no false positive).

**Test Strategy:**

1) Run pgFormatter tests (test-files and pg-test-files) — ex21, psql, psql_crosstab, reloptions, txid must pass. 2) Format a minimal SQL containing a string with backslash (e.g. SELECT '\\gset';) and confirm output is still a single string, not a psql command.

## Subtasks

### 2.1. Verify token order in buildRulesBeforeParams

**Status:** pending  
**Dependencies:** None  

In Tokenizer.ts, confirm LINE_COMMENT, BLOCK_COMMENT, QUOTED_IDENTIFIER/string rules appear before the PSQL_COMMAND rule (lines 34-50). Document that backslash inside quotes is safe.

### 2.2. Add optional [ \\t]* inside lookbehind

**Status:** pending  
**Dependencies:** None  

In the PSQL_COMMAND regex (after Task 1), change the lookbehind from (?<=^|\n) to (?<=^|\n)[ \t]* so that backslash-command after spaces on the same line is matched. Keep the rest of the regex unchanged.

### 2.3. Run pgFormatter tests for all five affected files

**Status:** pending  
**Dependencies:** None  

Run vitest with pgFormatter pattern; ensure ex21, psql, psql_crosstab (test-files) and reloptions, txid (pg-test-files) all pass.

### 2.4. Regression: string with backslash not treated as command

**Status:** pending  
**Dependencies:** None  

Format SELECT '\\gset' AS x; and confirm the single-quoted value is not tokenized as PSQL_COMMAND. Add a small test in test/features/strings.ts or pgFormatter if useful.
