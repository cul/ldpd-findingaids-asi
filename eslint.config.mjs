import globals from "globals";

import path from "path";
import { fileURLToPath } from "url";
import { FlatCompat } from "@eslint/eslintrc";
import pluginJs from "@eslint/js";

// mimic CommonJS variables -- not needed if using CommonJS
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({ baseDirectory: __dirname, recommendedConfig: pluginJs.configs.recommended });

export default [
  {
    // For now, we're only linting files under app/javascript/
    files: ["app/javascript/**/*.{js,jsx,mjs,cjs,ts,tsx}"],
  },
  {
    ignores: [
      'eslint.config.mjs',
      // For now, ignoring some Rails js files that might need to be reworked as part of the Vite changes
      'app/javascript/application.js',
      'app/javascript/controllers/*',
      // Temporarily ignoring aeonform.js while we figure out what to do with that file
      'app/assets/javascripts/aeonform.js',
    ]
  },
  { languageOptions: { globals: globals.browser } },
  ...compat.extends("airbnb"),
  {
    rules: {
      'max-len': ['error', { 'code': 120 }],
    },
  }
];
