#!/usr/bin/env npx tsx
/**
 * Script to update expected files with sql-formatter's current output.
 * Similar to Jest's --updateSnapshot flag but for direct comparison tests.
 *
 * Usage: npx tsx test/pgFormatter/updateExpected.ts
 *    or: npm run test:pgFormatter:update
 */
import fs from 'fs';
import path from 'path';
import { format } from '../../src/sqlFormatter.js';

// Path to fixtures (relative to project root)
const FIXTURES_ROOT = path.resolve('./test/pgFormatter/fixtures');

// Test file directories
const TEST_FILES_DIR = path.join(FIXTURES_ROOT, 'test-files');
const TEST_FILES_EXPECTED_DIR = path.join(TEST_FILES_DIR, 'expected');

const PG_TEST_FILES_DIR = path.join(FIXTURES_ROOT, 'pg-test-files/sql');
const PG_TEST_FILES_EXPECTED_DIR = path.join(FIXTURES_ROOT, 'pg-test-files/expected');

/**
 * sql-formatter options configured to match pgFormatter's default style.
 * Keep in sync with pgFormatter.test.ts
 */
const PGFORMATTER_COMPATIBLE_OPTIONS = {
  language: 'postgresql' as const,
  tabWidth: 4,
  keywordCase: 'upper' as const,
  logicalOperatorNewline: 'before' as const,
  caseWhenStyle: 'newline' as const,
  subqueryParenStyle: 'same-line' as const,
};

function fileExists(filePath: string): boolean {
  try {
    fs.accessSync(filePath, fs.constants.R_OK);
    return true;
  } catch {
    return false;
  }
}

function getTestFiles(dir: string): string[] {
  if (!fileExists(dir)) {
    return [];
  }
  return fs
    .readdirSync(dir)
    .filter(f => f.endsWith('.sql'))
    .sort((a, b) => {
      const numA = a.match(/^ex(\d+)\.sql$/);
      const numB = b.match(/^ex(\d+)\.sql$/);
      if (numA && numB) {
        return parseInt(numA[1], 10) - parseInt(numB[1], 10);
      }
      return a.localeCompare(b);
    });
}

function formatWithSqlFormatter(sql: string): string {
  return format(sql, PGFORMATTER_COMPATIBLE_OPTIONS);
}

interface UpdateResult {
  updated: number;
  skipped: number;
  errors: string[];
}

function updateExpectedFiles(inputDir: string, expectedDir: string, label: string): UpdateResult {
  const testFiles = getTestFiles(inputDir);
  const result: UpdateResult = { updated: 0, skipped: 0, errors: [] };

  if (testFiles.length === 0) {
    console.log(`  No files found in ${inputDir}`);
    return result;
  }

  // Ensure expected directory exists
  if (!fileExists(expectedDir)) {
    fs.mkdirSync(expectedDir, { recursive: true });
  }

  for (const file of testFiles) {
    const inputPath = path.join(inputDir, file);
    const expectedPath = path.join(expectedDir, file);

    const input = fs.readFileSync(inputPath, 'utf-8');
    
    let formatted: string;
    try {
      formatted = formatWithSqlFormatter(input);
    } catch (err) {
      const msg = err instanceof Error ? err.message.split('\n')[0] : String(err);
      console.log(`  Skipped: ${file} (parse error: ${msg})`);
      result.errors.push(file);
      result.skipped++;
      continue;
    }

    // Check if update is needed
    let needsUpdate = true;
    if (fileExists(expectedPath)) {
      const existing = fs.readFileSync(expectedPath, 'utf-8');
      needsUpdate = existing !== formatted;
    }

    if (needsUpdate) {
      fs.writeFileSync(expectedPath, formatted, 'utf-8');
      console.log(`  Updated: ${file}`);
      result.updated++;
    }
  }

  return result;
}

console.log('Updating expected files with sql-formatter output...\n');

console.log('test-files:');
const testFilesResult = updateExpectedFiles(TEST_FILES_DIR, TEST_FILES_EXPECTED_DIR, 'test-files');

console.log('\npg-test-files:');
const pgTestFilesResult = updateExpectedFiles(PG_TEST_FILES_DIR, PG_TEST_FILES_EXPECTED_DIR, 'pg-test-files');

const totalUpdated = testFilesResult.updated + pgTestFilesResult.updated;
const totalSkipped = testFilesResult.skipped + pgTestFilesResult.skipped;
const allErrors = [...testFilesResult.errors, ...pgTestFilesResult.errors];

console.log(`\nDone. Updated ${totalUpdated} file(s).`);
if (totalSkipped > 0) {
  console.log(`Skipped ${totalSkipped} file(s) due to parse errors:`);
  allErrors.forEach(f => console.log(`  - ${f}`));
}
