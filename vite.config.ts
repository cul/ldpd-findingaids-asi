import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';
import basicSsl from '@vitejs/plugin-basic-ssl';

const eslintPlugin = () => {
  return {
    name: 'vite:eslint',
    async buildStart() {
      const { ESLint } = await import('eslint');
      const eslint = new ESLint();
      const results = await eslint.lintFiles(['app/javascript/**/*.{js,jsx,ts,tsx}']);

      await ESLint.outputFixes(results);

      const formatter = await eslint.loadFormatter('stylish');
      const resultText = formatter.format(results);
      if (resultText) {
        console.log(resultText);
      }
    }
  };
};

export default defineConfig({
  plugins: [
    // When the basicSsl plugin is active, Vite will automatically generate a self-signed
    // cert when the server is running under https.
    basicSsl({}),
    RubyPlugin(),
    eslintPlugin(),
  ],
});
