// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const { generateWebpackConfig, merge } = require('shakapacker')
const path = require("path");
const webpackConfig = generateWebpackConfig()

const customConfig = {
  resolve: {
    alias: {
      arclight: path.resolve(__dirname, '../../node_modules/arclight/app/assets/javascripts/arclight'),
      blacklight: path.resolve(__dirname, '../../node_modules/blacklight-frontend/app/javascript/blacklight'),
    }
  },
  module: {
    rules: [
      {
      test: /\.css$/i,
      exclude: /node_modules/,
      use: ["style-loader", "css-loader"],
      },
    ]
  }
}

module.exports = merge(webpackConfig, customConfig)
