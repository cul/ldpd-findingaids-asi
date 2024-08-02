import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import eslint from 'vite-plugin-eslint'
import basicSsl from '@vitejs/plugin-basic-ssl'

export default defineConfig({
  plugins: [
    basicSsl({
      domains: ['*.library.columbia.edu'],
    }),
    RubyPlugin(),
    eslint()
  ],
  // server: {
  //   https: {
  //     host: true
  //   }
  // }
})
