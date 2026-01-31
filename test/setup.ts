import { describe, it, expect, beforeAll, afterAll, beforeEach, afterEach } from 'bun:test';

// Make test functions globally available to match Vitest's globals behavior
(globalThis as any).describe = describe;
(globalThis as any).it = it;
(globalThis as any).expect = expect;
(globalThis as any).beforeAll = beforeAll;
(globalThis as any).afterAll = afterAll;
(globalThis as any).beforeEach = beforeEach;
(globalThis as any).afterEach = afterEach;
