# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SQL Formatter is a JavaScript/TypeScript library for pretty-printing SQL queries. It supports 20 SQL dialects including PostgreSQL, MySQL, BigQuery, Snowflake, and others.

## Common Commands

```bash
# Install dependencies
bun install

# Run all tests
bun run test

# Run tests in watch mode
bun run test:watch

# Run a single test file
bun run grammar && vitest run test/postgresql.test.ts

# Run pgFormatter compatibility tests
bun run test:pgFormatter

# Compile the Nearley grammar (required before tests/build)
bun run grammar

# Build all outputs (CJS, ESM, UMD bundle)
bun run build

# Type checking
bun run ts:check

# Lint and format
bun run lint
bun run pretty

# Full check (type check + format check + lint + test)
bun run check
```

## Architecture

### Pipeline Flow

SQL input → **Tokenizer** → tokens → **Parser** → AST → **Formatter** → formatted SQL

### Key Directories

- `src/lexer/` - Tokenization engine that converts SQL strings into token streams
- `src/parser/` - Nearley-based parser that builds AST from tokens
  - `grammar.ne` - Nearley grammar definition (compiles to `grammar.ts`)
- `src/formatter/` - AST traversal and formatting logic
  - `Formatter.ts` - Entry point that orchestrates parsing and formatting
  - `ExpressionFormatter.ts` - Core formatting logic for SQL expressions
  - `Layout.ts` - Manages whitespace and indentation output
- `src/languages/` - Dialect-specific configurations (one folder per dialect)

### Dialect Structure

Each dialect in `src/languages/<dialect>/` contains:

- `<dialect>.formatter.ts` - Main dialect configuration (`DialectOptions`)
- `<dialect>.keywords.ts` - Reserved keywords and data types
- `<dialect>.functions.ts` - Built-in function names
- `index.ts` - Re-exports for tree-shaking support

Dialect options define:

- `tokenizerOptions` - Keywords, operators, string/identifier syntax, parameter styles
- `formatOptions` - Formatting behavior like one-line clauses

### Adding a New Dialect

1. Create a new folder under `src/languages/`
2. Define keywords, functions, and formatter configuration
3. Export from `src/index.ts` and `src/allDialects.ts`
4. Add to `dialectNameMap` in `src/sqlFormatter.ts`
5. Create `test/<dialect>.test.ts` using existing feature tests

### Grammar Compilation

The parser uses Nearley. After editing `src/parser/grammar.ne`, run:

```bash
bun run grammar
```

This generates `src/parser/grammar.ts` which must be committed.

## Testing Patterns

- Dialect tests: `test/<dialect>.test.ts` - compose feature tests for each dialect
- Feature tests: `test/features/` - reusable test suites for SQL features (joins, constraints, etc.)
- Option tests: `test/options/` - tests for formatting options
- Unit tests: `test/unit/` - isolated component tests

Tests use Vitest with global `describe`/`it`/`expect`. The `dedent` library is used for readable multi-line SQL expectations.

## API

Two main entry points:

- `format(query, { language: 'postgresql', ...options })` - includes all dialects
- `formatDialect(query, { dialect: postgresql, ...options })` - tree-shakeable, import specific dialect
