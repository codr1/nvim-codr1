
const js = require('@eslint/js');
const globals = require('globals');
const tsParser = require('@typescript-eslint/parser');
const tsPlugin = require('@typescript-eslint/eslint-plugin');

module.exports = [
  js.configs.recommended,
  {
    files: ['*.ts', '*.tsx'], // Apply this config only to TypeScript files
    languageOptions: {
      parser: tsParser,
      ecmaVersion: 2022,
      sourceType: 'module',
      globals: {
        ...globals.browser,
        ...globals.es2021,
        ...globals.node,
      },
    },
    plugins: {
      '@typescript-eslint': tsPlugin,
    },
    rules: {
      'indent': ['error', 4],
      'linebreak-style': ['error', 'unix'],
      'quotes': ['error', 'double'],
      'semi': ['error', 'always'],
      'space-before-function-paren': ['error', 'always'],
      'space-in-parens': ['error', 'always'],
      'array-bracket-spacing': ['error', 'always'],
      'object-curly-spacing': ['error', 'always'],
      'comma-spacing': ['error', { 'before': false, 'after': true }],
      'func-call-spacing': ['error', 'never'],
      'function-paren-newline': ['error', 'multiline'],
      'keyword-spacing': ['error', { 'before': true, 'after': true }],
      'space-infix-ops': 'error',
      'key-spacing': ['error', { 'beforeColon': false, 'afterColon': true }],
      'space-before-blocks': 'error',
      
      // TypeScript-specific rules
      '@typescript-eslint/no-unused-vars': ['error'],
      '@typescript-eslint/no-explicit-any': 'warn',
      '@typescript-eslint/explicit-function-return-type': 'off',
    },
  },
  {
    files: ['*.js', '*.jsx'], // Apply this config only to JavaScript files
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
      globals: {
        ...globals.browser,
        ...globals.es2021,
        ...globals.node,
      },
    },
    rules: {
      'indent': ['error', 4],
      'linebreak-style': ['error', 'unix'],
      'quotes': ['error', 'double'],
      'semi': ['error', 'always'],
      'space-before-function-paren': ['error', 'always'],
      'space-in-parens': ['error', 'always'],
      'array-bracket-spacing': ['error', 'always'],
      'object-curly-spacing': ['error', 'always'],
      'comma-spacing': ['error', { 'before': false, 'after': true }],
      'func-call-spacing': ['error', 'never'],
      'function-paren-newline': ['error', 'multiline'],
      'keyword-spacing': ['error', { 'before': true, 'after': true }],
      'space-infix-ops': 'error',
      'key-spacing': ['error', { 'beforeColon': false, 'afterColon': true }],
      'space-before-blocks': 'error'    
    },
  },
];

