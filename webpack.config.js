const path = require('path')

module.exports = (env, argv) => {
  const mode = argv.mode || 'development'

  return {
    mode: mode,
    entry: {
      app: __dirname + '/_assets/app.js',
      database: __dirname + '/_assets/database.js',
      timeline: __dirname + '/_assets/timeline.js'
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
          use: [
            {
              loader: 'babel-loader',
              options: {
                presets: ['@babel/preset-env']
              },
            },{
              loader: '@riotjs/webpack-loader',
              options: {
                hot: true, // set it to true if you are using hmr
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
        }, {
          test: /\.less$/i,
          use: [
            {
              loader: 'file-loader',
              options: {outputPath: '.', name: 'timeline.css'}
            },
            'less-loader'
          ]
        }, {
          test: /\.m?js$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader',
            options: {
              presets: ['@babel/preset-env']
            }
          }
        }
      ]
    }
  }
}
