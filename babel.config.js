module.exports = function (api) {
  const defaultConfigFunc = require('shakapacker/package/babel/preset.js')
  const resultConfig = defaultConfigFunc(api)
  const isProductionEnv = api.env('production')

  const changesOnDefault = {
    presets: [
      [
        '@babel/preset-react',
        {
          development: !isProductionEnv,
          useBuiltIns: true
        }
      ]
    ].filter(Boolean),
    plugins: [
      [
        "babel-plugin-module-resolver",
        {
          "root": [
            "./node_modules"
          ],
          "alias": {
          }
        }
      ],
      ["@babel/plugin-transform-object-rest-spread", { "useBuiltIns": true }],
      isProductionEnv && ['babel-plugin-transform-react-remove-prop-types',
        {
          removeImport: true
        }
      ]
    ].filter(Boolean),
    rules: [
      [
        'react-refresh/babel',
        {
          test: /\.(ts|js)x?$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader',
            options: {
              presets: ['@babel/preset-react', '@babel/preset-env', '@babel/preset-typescript'],
              plugins: ['@babel/plugin-transform-runtime', process.env.WEBPACK_SERVE && require.resolve('react-refresh/babel')].filter(Boolean),
            }
          }
        }
      ]
    ].filter(Boolean),
  }

  resultConfig.presets = [...resultConfig.presets, ...changesOnDefault.presets]
  resultConfig.plugins = [...resultConfig.plugins, ...changesOnDefault.plugins ]

  return resultConfig
}