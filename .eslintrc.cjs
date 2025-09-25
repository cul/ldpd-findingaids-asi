module.exports = {
  env: {
    browser: true,
    es2021: true,
  },
  extends: [
    'airbnb',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
  },
  plugins: [
    '@typescript-eslint',
  ],
  overrides: [
    {
      env: {
        node: true,
      },
      files: [
        '.eslintrc.{js,cjs}',
      ],
      parserOptions: {
        sourceType: 'script',
      },
    },
  ],
  rules: {
    'max-len': ['error', { ignoreComments: true }, { code: 120 }],
    'no-unused-vars': 'off',
    '@typescript-eslint/no-unused-vars': 'warn',
    // Disable import extension and resolution rules
    'import/extensions': 'off',
    'import/no-unresolved': 'off',
    'react/require-default-props': 'off',
    // Allow JSX in .tsx files
    'react/jsx-filename-extension': [1, { extensions: ['.jsx', '.tsx'] }],
  },
};
