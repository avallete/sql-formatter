import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    include: ['test/**/*.test.ts', 'test/**/perftest.ts'],
    exclude: ['**/node_modules/**', '**/updateExpected.ts', 'test/perf/**'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov'],
      reportsDirectory: 'coverage',
      include: ['src/**/*.ts'],
    },
  },
  resolve: {
    alias: [
      {
        find: /^(\\.\\.?\/.+)\\.js$/,
        replacement: '$1',
      },
    ],
  },
});
