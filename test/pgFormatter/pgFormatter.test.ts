/**
 * Direct comparison tests between sql-formatter (postgresql dialect) and pgFormatter.
 *
 * These tests format SQL input with sql-formatter and compare against pgFormatter's
 * expected output. Tests pass only when outputs match exactly.
 *
 * Run: yarn test -- --testPathPattern=pgFormatter
 */
import { format } from '../../src/sqlFormatter.js';
import fs from 'fs';
import path from 'path';

// Path to fixtures (relative to project root where Jest runs)
const FIXTURES_ROOT = path.resolve('./test/pgFormatter/fixtures');

// Test file directories
const TEST_FILES_DIR = path.join(FIXTURES_ROOT, 'test-files');
const TEST_FILES_EXPECTED_DIR = path.join(TEST_FILES_DIR, 'expected');

const PG_TEST_FILES_DIR = path.join(FIXTURES_ROOT, 'pg-test-files/sql');
const PG_TEST_FILES_EXPECTED_DIR = path.join(FIXTURES_ROOT, 'pg-test-files/expected');

/**
 * sql-formatter options configured to match pgFormatter's default style:
 * - 4 spaces indentation
 * - Uppercase keywords (SELECT, FROM, WHERE, etc.)
 * - Logical operators at start of line (AND, OR)
 */
const PGFORMATTER_COMPATIBLE_OPTIONS = {
  language: 'postgresql' as const,
  tabWidth: 4,
  keywordCase: 'upper' as const,
  logicalOperatorNewline: 'before' as const,
};

/**
 * Helper to check if a file exists
 */
function fileExists(filePath: string): boolean {
  try {
    fs.accessSync(filePath, fs.constants.R_OK);
    return true;
  } catch {
    return false;
  }
}

/**
 * Get all SQL test files from a directory
 */
function getTestFiles(dir: string): string[] {
  if (!fileExists(dir)) {
    return [];
  }
  return fs
    .readdirSync(dir)
    .filter(f => f.endsWith('.sql'))
    .sort((a, b) => {
      // Sort numerically for exN.sql files
      const numA = a.match(/^ex(\d+)\.sql$/);
      const numB = b.match(/^ex(\d+)\.sql$/);
      if (numA && numB) {
        return parseInt(numA[1], 10) - parseInt(numB[1], 10);
      }
      return a.localeCompare(b);
    });
}

/**
 * Format SQL using sql-formatter with pgFormatter-compatible options
 */
function formatWithSqlFormatter(sql: string): string {
  return format(sql, PGFORMATTER_COMPATIBLE_OPTIONS);
}

describe('pgFormatter comparison', () => {
  describe('test-files (ex0.sql - ex77.sql)', () => {
    const testFiles = getTestFiles(TEST_FILES_DIR);

    if (testFiles.length === 0) {
      it.skip('No test files found - ensure fixtures are available', () => {});
      return;
    }

    test.each(testFiles)('%s', file => {
      const inputPath = path.join(TEST_FILES_DIR, file);
      const expectedPath = path.join(TEST_FILES_EXPECTED_DIR, file);

      // Skip if expected file doesn't exist (e.g., ex67.sql)
      if (!fileExists(expectedPath)) {
        return;
      }

      const input = fs.readFileSync(inputPath, 'utf-8');
      const expected = fs.readFileSync(expectedPath, 'utf-8');
      const result = formatWithSqlFormatter(input);

      expect(result).toBe(expected);
    });
  });

  describe('pg-test-files (PostgreSQL regression tests)', () => {
    const testFiles = getTestFiles(PG_TEST_FILES_DIR);

    if (testFiles.length === 0) {
      it.skip('No pg-test-files found - ensure fixtures are available', () => {});
      return;
    }

    test.each(testFiles)('%s', file => {
      const inputPath = path.join(PG_TEST_FILES_DIR, file);
      const expectedPath = path.join(PG_TEST_FILES_EXPECTED_DIR, file);

      // Skip if expected file doesn't exist
      if (!fileExists(expectedPath)) {
        return;
      }

      const input = fs.readFileSync(inputPath, 'utf-8');
      const expected = fs.readFileSync(expectedPath, 'utf-8');
      const result = formatWithSqlFormatter(input);

      expect(result).toBe(expected);
    });
  });
});
