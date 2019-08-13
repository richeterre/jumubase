const CopyWebpackPlugin = require("copy-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const webpack = require("webpack");

module.exports = {
  entry: {
    app: ["./js/app.js", "./css/app.scss"],
    groupingPicker: "./js/views/groupingPicker.js",
    performanceFilter: "./js/views/performanceFilter.js",
    privacy: "./js/views/privacy.js",
    registration: "./js/views/registration.js",
    resultForm: "./js/views/resultForm.js",
    scheduler: "./js/views/scheduler.js",
  },

  output: {
    path: `${__dirname}/../priv/static/js`,
    filename: "[name].js",
  },

  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: "babel-loader",
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, "css-loader"],
      },
      {
        test: /\.scss$/,
        use: [MiniCssExtractPlugin.loader, "css-loader", "sass-loader"],
      },
      {
        test: /\.woff$/,
        use: {
          loader: "url-loader",
          options: {
            limit: 50000,
          },
        },
      },
    ],
  },

  plugins: [
    new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery",
    }),
    new MiniCssExtractPlugin({
      filename: "../css/[name].css",
    }),
    new CopyWebpackPlugin([
      {
        from: "node_modules/bootstrap-sass/assets/fonts/bootstrap/",
        to: "../fonts/",
      },
      {
        from: "static/**",
        to: "../../",
      },
    ]),
  ],
};
