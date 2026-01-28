import { describe, it, expect, beforeAll, afterAll } from '@jest/globals';
import * as esbuild from 'esbuild';
import * as fs from 'fs';
import * as path from 'path';
import * as os from 'os';

/**
 * Bundle size tests to ensure tree-shaking works correctly.
 * These tests create temporary entry files, bundle them with esbuild,
 * and verify the output sizes are within expected thresholds.
 */
describe('Bundle Size', () => {
  let tempDir: string;

  beforeAll(() => {
    tempDir = fs.mkdtempSync(path.join(os.tmpdir(), 'sql-formatter-bundle-test-'));
  });

  afterAll(() => {
    // Clean up temp directory
    fs.rmSync(tempDir, { recursive: true, force: true });
  });

  const bundleCode = async (
    code: string,
    name: string
  ): Promise<{ size: number; gzipSize: number }> => {
    const entryFile = path.join(tempDir, `${name}.ts`);
    const outFile = path.join(tempDir, `${name}.js`);

    fs.writeFileSync(entryFile, code);

    await esbuild.build({
      entryPoints: [entryFile],
      bundle: true,
      minify: true,
      outfile: outFile,
      format: 'esm',
      platform: 'browser',
      target: 'es2020',
      // Point to the source files
      alias: {
        'sql-formatter': path.resolve('./src/index.ts'),
        'sql-formatter/lite': path.resolve('./src/lite.ts'),
        'sql-formatter/languages/postgresql': path.resolve('./src/languages/postgresql/index.ts'),
        'sql-formatter/languages/mysql': path.resolve('./src/languages/mysql/index.ts'),
        'sql-formatter/languages/sqlite': path.resolve('./src/languages/sqlite/index.ts'),
      },
    });

    const content = fs.readFileSync(outFile);
    const size = content.length;

    // Calculate gzip size
    const { gzipSync } = await import('zlib');
    const gzipSize = gzipSync(content).length;

    return { size, gzipSize };
  };

  describe('Full bundle (import format)', () => {
    it('should bundle all dialects when using format()', async () => {
      const code = `
        import { format } from 'sql-formatter';
        console.log(format('SELECT * FROM users', { language: 'postgresql' }));
      `;

      const { size, gzipSize } = await bundleCode(code, 'full-bundle');

      console.log(
        `Full bundle size: ${(size / 1024).toFixed(2)} KB (${(gzipSize / 1024).toFixed(
          2
        )} KB gzipped)`
      );

      // Full bundle includes all dialects - expect around 250-350KB minified (uncompressed)
      // Note: This is larger than webpack's output because esbuild preserves more code
      expect(size).toBeGreaterThan(200 * 1024); // At least 200KB
      expect(size).toBeLessThan(400 * 1024); // But not more than 400KB
    });
  });

  describe('Lite bundle (import formatDialect)', () => {
    it('should be significantly smaller when using formatDialect with single dialect', async () => {
      const code = `
        import { formatDialect } from 'sql-formatter/lite';
        import { postgresql } from 'sql-formatter/languages/postgresql';
        console.log(formatDialect('SELECT * FROM users', { dialect: postgresql }));
      `;

      const { size, gzipSize } = await bundleCode(code, 'lite-postgresql');

      console.log(
        `Lite + PostgreSQL bundle size: ${(size / 1024).toFixed(2)} KB (${(gzipSize / 1024).toFixed(
          2
        )} KB gzipped)`
      );

      // Single dialect bundle should be much smaller - around 60-80KB
      // This is a ~75% reduction from full bundle
      expect(size).toBeLessThan(100 * 1024); // Less than 100KB
      expect(size).toBeGreaterThan(40 * 1024); // But at least 40KB (core formatter + dialect)
    });

    it('should allow multiple dialects while still being smaller than full bundle', async () => {
      const code = `
        import { formatDialect } from 'sql-formatter/lite';
        import { postgresql } from 'sql-formatter/languages/postgresql';
        import { mysql } from 'sql-formatter/languages/mysql';
        console.log(formatDialect('SELECT * FROM users', { dialect: postgresql }));
        console.log(formatDialect('SELECT * FROM users', { dialect: mysql }));
      `;

      const { size, gzipSize } = await bundleCode(code, 'lite-two-dialects');

      console.log(
        `Lite + PostgreSQL + MySQL bundle size: ${(size / 1024).toFixed(2)} KB (${(
          gzipSize / 1024
        ).toFixed(2)} KB gzipped)`
      );

      // Two dialects should still be smaller than full bundle
      expect(size).toBeLessThan(80 * 1024);
    });
  });

  describe('Size comparison', () => {
    it('lite bundle should be at least 30% smaller than full bundle', async () => {
      const fullCode = `
        import { format } from 'sql-formatter';
        console.log(format('SELECT * FROM users', { language: 'postgresql' }));
      `;

      const liteCode = `
        import { formatDialect } from 'sql-formatter/lite';
        import { postgresql } from 'sql-formatter/languages/postgresql';
        console.log(formatDialect('SELECT * FROM users', { dialect: postgresql }));
      `;

      const [fullBundle, liteBundle] = await Promise.all([
        bundleCode(fullCode, 'compare-full'),
        bundleCode(liteCode, 'compare-lite'),
      ]);

      const savings = ((fullBundle.size - liteBundle.size) / fullBundle.size) * 100;
      console.log(
        `Size savings: ${savings.toFixed(1)}% (${(
          (fullBundle.size - liteBundle.size) /
          1024
        ).toFixed(2)} KB)`
      );

      // Lite bundle should be at least 30% smaller
      expect(savings).toBeGreaterThan(30);
    });
  });
});
