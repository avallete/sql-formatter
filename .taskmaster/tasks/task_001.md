# Task ID: 1

**Title:** Expand PSQL_COMMAND regex for \. and \! (Category C)

**Status:** pending

**Dependencies:** None

**Priority:** high

**Description:** Modify the PSQL_COMMAND regex in the tokenizer to match \. (end COPY data) and \! (shell command), not just letters after backslash.

**Details:**

**File:** `src/lexer/Tokenizer.ts`, in `buildRulesBeforeParams()`, lines 46–50.

**Current code (line 49):**
`regex: cfg.psqlMetaCommands ? /(?<=^|\\n)\\\[a-zA-Z_]+[^\\n]*/uy : undefined`

**Problem:** The character class `[a-zA-Z_]+` only allows letters and underscore after the backslash. Psql also uses:
- `\\.` — end of COPY ... FROM stdin data (single period, e.g. in ex51.sql)
- `\\!` — run shell command (e.g. `\\! cat /tmp/file` in hs_standby_allowed.sql)

**Exact change:** On line 49, replace `[a-zA-Z_]+` with `[a-zA-Z_!.]+` so the full regex becomes:
`/(?<=^|\\n)\\\\[a-zA-Z_!.]+[^\\n]*/uy`
Keep the lookbehind `(?<=^|\\n)` unchanged (Task 2 will relax it for inline commands).

**Verification:** Confirm `psqlMetaCommands` is enabled for PostgreSQL in `src/languages/postgresql/postgresql.formatter.ts` (tokenizerOptions).

**Acceptance criteria:** ex51.sql and hs_standby_allowed.sql format without parse errors; full test suite passes.

**Test Strategy:**

1) bun run grammar && vitest run --testPathPattern=pgFormatter (or filter for ex51 / hs_standby). 2) bun run test for full suite.

## Subtasks

### 1.1. Confirm psqlMetaCommands and PSQL_COMMAND location

**Status:** pending  
**Dependencies:** None  

Open src/lexer/Tokenizer.ts:46-50 and src/languages/postgresql/postgresql.formatter.ts; confirm psqlMetaCommands is true for PostgreSQL so the regex is active.

### 1.2. Edit regex: add . and ! to character class

**Status:** pending  
**Dependencies:** None  

In Tokenizer.ts line 49, change [a-zA-Z_]+ to [a-zA-Z_!.]+ in the PSQL_COMMAND regex. Save file.

### 1.3. Run pgFormatter tests for ex51.sql and hs_standby_allowed.sql

**Status:** pending  
**Dependencies:** None  

Run pgFormatter tests (test-files for ex51; pg-test-files for hs_standby_allowed). Both must pass.

### 1.4. Run full test suite

**Status:** pending  
**Dependencies:** None  

Run bun run test (or bun run grammar && vitest run). Fix any regressions.
