const path = require('path')

module.exports = (env, argv) => {
  const mode = argv.mode || 'development'

  return {
    mode: mode,
    entry: {
      app: __dirname + '/_assets/app.js',
      database: __dirname + '/_assets/database.js'
    },
    output: {
      path: __dirname + '/assets',
      filename: '[name].js'
    },
    devtool: mode == 'development' ? 'eval-source-map' : false,
    module: {
      rules: [
        {
          test: /\.riot$/,
          exclude: /node_modules/,
          use: [{
            loader: '@riotjs/webpack-loader',
            options: {
              hot: false, // set it to true if you are using hmr
              // add here all the other @riotjs/compiler options riot.js.org/compiler
              // template: 'pug' for example
            }
          }]
        }, {
          test: /\.s[ac]ss$/i,
          use: [
            {
              loader: 'file-loader',
              options: {outputPath: '.', name: 'app.css'}
            },
            'sass-loader'
          ]
        }
      ]
    }
  }
}
