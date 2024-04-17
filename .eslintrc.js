module.exports = {
  env: {
    browser: true,
    es2021: true,
  },
  extends: 'airbnb',
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
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
  },
  ignorePatterns: [
    // For now, ignoring some Rails js files that might need to be reworked as part of the Vite changes
    'app/javascript/application.js',
    'app/javascript/controllers/*',
    'app/assets/javascripts/aeonform.js',
  ],
  rules: {
    'max-len': ['error', { code: 120 }],
  },
};
