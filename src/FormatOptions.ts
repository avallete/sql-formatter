// import only type to avoid ESLint no-cycle rule producing an error
import { ParamItems } from './formatter/Params.js';
import { ParamTypes } from './lexer/TokenizerOptions.js';

export type IndentStyle = 'standard' | 'tabularLeft' | 'tabularRight';

export type KeywordCase = 'preserve' | 'upper' | 'lower';
export type IdentifierCase = KeywordCase;
export type DataTypeCase = KeywordCase;
export type FunctionCase = KeywordCase;

export type LogicalOperatorNewline = 'before' | 'after';

// pgFormatter compatibility options
export type CaseWhenStyle = 'inline' | 'newline';
export type SubqueryParenStyle = 'same-line' | 'new-line';

export interface FormatOptions {
  tabWidth: number;
  useTabs: boolean;
  keywordCase: KeywordCase;
  identifierCase: IdentifierCase;
  dataTypeCase: DataTypeCase;
  functionCase: FunctionCase;
  indentStyle: IndentStyle;
  logicalOperatorNewline: LogicalOperatorNewline;
  expressionWidth: number;
  linesBetweenQueries: number;
  denseOperators: boolean;
  newlineBeforeSemicolon: boolean;
  // pgFormatter compatibility options
  caseWhenStyle: CaseWhenStyle;
  subqueryParenStyle: SubqueryParenStyle;
  params?: ParamItems | string[];
  paramTypes?: ParamTypes;
}
