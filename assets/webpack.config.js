const CopyWebpackPlugin = require('copy-webpack-plugin')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const webpack = require('webpack')

module.exports = {
  entry: {
    app: ['./js/app.js', './css/app.scss'],
    performanceFilter: './js/views/performanceFilter.js',
    registration: './js/views/registration.js',
  },

  output: {
    path:  `${__dirname}/../priv/static/js`,
    filename: '[name].js',
  },

  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: 'babel-loader',
      },
      {
        test: /\.css$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
        ],
      },
      {
        test: /\.scss$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          'sass-loader',
        ],
      },
    ],
  },

  plugins: [
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
    }),
    new MiniCssExtractPlugin({
      filename: '../css/[name].css',
    }),
    new CopyWebpackPlugin([
      {
        from: 'node_modules/bootstrap-sass/assets/fonts/bootstrap/',
        to: '../fonts/',
      },
      {
        from: 'static/**',
        to: '../../',
      },
    ]),
  ],
}
