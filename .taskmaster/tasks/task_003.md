# Task ID: 3

**Title:** Handle COMMENT ON OPERATOR with operator names (Category H)

**Status:** pending

**Dependencies:** 1

**Priority:** medium

**Description:** Grammar change so COMMENT ON OPERATOR accepts operator tokens (e.g. ######) not just identifiers.

**Details:**

**Context:** PostgreSQL allows `COMMENT ON OPERATOR ###### (int4, NONE) IS '...';` — the operator name can be operator characters (e.g. `######`), not only an identifier. create_operator.sql line 40 has this; the formatter currently fails on it.

**Grammar layout (grammar.ne):** Statements are `statement -> expressions_or_clauses (%DELIMITER | %EOF)` and `expressions_or_clauses -> free_form_sql:* clause:*`. So COMMENT ON ... is consumed as a sequence of `free_form_sql` tokens. Inside that, `asteriskless_free_form_sql` can be `atomic_expression` (line 192-207), and `atomic_expression` already includes `operator` (line 202) and `identifier` (line 203). So in theory OPERATOR tokens are allowed in free-form SQL. The failure may be: (a) tokenization — e.g. `######` tokenized as multiple tokens or wrong type; (b) ambiguity — parser choosing a different branch (e.g. property_access expects identifier after dot at line 259, but COMMENT ON OPERATOR is not property_access); (c) a specific sequence the grammar doesn't allow. The `comment` rule (line 368-391) only handles LINE_COMMENT, BLOCK_COMMENT, DISABLE_COMMENT, PSQL_COMMAND — no dedicated COMMENT ON OPERATOR rule.

**Files:** `src/parser/grammar.ne` (main place to change); `src/lexer/` and `src/languages/postgresql/postgresql.formatter.ts` (operators list) if tokenization is wrong.

**Acceptance criteria:** `COMMENT ON OPERATOR ###### (int4, NONE) IS 'bad right unary';` formats without parse error; create_operator.sql pgFormatter test passes; full suite passes.

**Test Strategy:**

1) Reproduce with format(..., { language: 'postgresql' }). 2) After grammar change: bun run grammar, then vitest run (pgFormatter for create_operator.sql, then full suite).

## Subtasks

### 3.1. Reproduce and capture exact parse error

**Status:** pending  
**Dependencies:** None  

Call format("COMMENT ON OPERATOR ###### (int4, NONE) IS 'bad right unary';", { language: 'postgresql' }) or run on test/pgFormatter/fixtures/pg-test-files/sql/create_operator.sql. Note the exact error message and stack (token/rule where it fails).

### 3.2. Trace grammar path for COMMENT ON OPERATOR

**Status:** pending  
**Dependencies:** None  

In grammar.ne: main -> statement -> expressions_or_clauses -> free_form_sql. No dedicated COMMENT ON rule. Check whether the failure is in tokenization (lexer) or in a grammar rule (e.g. property_access at 259, or something consuming OPERATOR).

### 3.3. Inspect tokenization of ######

**Status:** pending  
**Dependencies:** None  

Add a temporary log or run tokenizer on 'COMMENT ON OPERATOR ###### (int4, NONE) IS 'x';' with PostgreSQL config. See if ###### is one OPERATOR token or several; check postgresql.formatter operators list for '#'.

### 3.4. Implement fix in grammar or tokenizer

**Status:** pending  
**Dependencies:** None  

Either: (1) Add a grammar rule that accepts operator(s) or identifier after COMMENT ON OPERATOR before the parenthesis; or (2) If tokenization is wrong, adjust lexer/operator list. Then run bun run grammar if grammar.ne changed.

### 3.5. Verify create_operator.sql and full suite

**Status:** pending  
**Dependencies:** None  

Run pgFormatter tests (create_operator.sql in pg-test-files) and bun run test. Fix any regressions.
