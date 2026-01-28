/**
 * Lightweight entry point for sql-formatter.
 *
 * This module exports only `formatDialect()` which accepts a dialect object directly,
 * avoiding the import of all dialect definitions. This enables tree-shaking when
 * bundling, resulting in significantly smaller bundle sizes when only specific
 * dialects are needed.
 *
 * Usage:
 * ```typescript
 * import { formatDialect } from 'sql-formatter/lite';
 * import { postgresql } from 'sql-formatter/languages/postgresql';
 *
 * const formatted = formatDialect('SELECT * FROM users', {
 *   dialect: postgresql,
 *   keywordCase: 'upper',
 * });
 * ```
 */

import { FormatOptions } from './FormatOptions.js';
import { createDialect, DialectOptions } from './dialect.js';
import Formatter from './formatter/Formatter.js';
import { validateConfig } from './validateConfig.js';

export type FormatOptionsWithDialect = Partial<FormatOptions> & {
  dialect: DialectOptions;
};

const defaultOptions: FormatOptions = {
  tabWidth: 2,
  useTabs: false,
  keywordCase: 'preserve',
  identifierCase: 'preserve',
  dataTypeCase: 'preserve',
  functionCase: 'preserve',
  indentStyle: 'standard',
  logicalOperatorNewline: 'before',
  expressionWidth: 50,
  linesBetweenQueries: 1,
  denseOperators: false,
  newlineBeforeSemicolon: false,
};

/**
 * Format whitespace in a SQL query to make it easier to read.
 *
 * This function requires passing a dialect object directly, which enables
 * tree-shaking - only the dialects you import will be included in your bundle.
 *
 * @param {string} query - input SQL query string
 * @param {FormatOptionsWithDialect} cfg Configuration options (dialect is required)
 * @return {string} formatted query
 */
export const formatDialect = (
  query: string,
  { dialect, ...cfg }: FormatOptionsWithDialect
): string => {
  if (typeof query !== 'string') {
    throw new Error('Invalid query argument. Expected string, instead got ' + typeof query);
  }

  const options = validateConfig({
    ...defaultOptions,
    ...cfg,
  });

  return new Formatter(createDialect(dialect), options).format(query);
};

// Re-export types that consumers might need
export { expandPhrases } from './expandPhrases.js';
export { ConfigError } from './validateConfig.js';

export type {
  IndentStyle,
  KeywordCase,
  DataTypeCase,
  FunctionCase,
  IdentifierCase,
  LogicalOperatorNewline,
  FormatOptions,
} from './FormatOptions.js';
export type { ParamItems } from './formatter/Params.js';
export type { ParamTypes } from './lexer/TokenizerOptions.js';
export type { DialectOptions } from './dialect.js';
