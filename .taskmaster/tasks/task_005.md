# Task ID: 5

**Title:** Document test command (Issue 1)

**Status:** pending

**Dependencies:** None

**Priority:** low

**Description:** Clarify that users must run 'bun run test' (Vitest) not 'bun test' (Bun runner) to avoid 'it is not defined' errors.

**Details:**

Update README or CONTRIBUTING to state: run `bun run test` for the test suite; `bun test` uses Bun's runner and does not define Vitest globals (it, describe, expect).

**Test Strategy:**

N/A – documentation only.
