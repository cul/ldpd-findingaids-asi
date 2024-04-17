import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import eslint from 'vite-plugin-eslint'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    eslint()
  ],
})
