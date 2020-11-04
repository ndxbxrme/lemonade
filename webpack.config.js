var path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const autoprefixer = require("autoprefixer");

module.exports = {
    mode: "development",
    entry: "./src/audio.coffee",
    output: {
        path: path.join(__dirname, "app"),
        publicPath: "",
        filename: "audio.[contenthash].js"
    },
    devServer: {
      contentBase: path.join(__dirname, "app"),
      compress: true,
      historyApiFallback: true,
      port: 9000
    },
    plugins: [
      new HtmlWebpackPlugin({
        template: path.join(__dirname, "src/index.pug")
      })
    ],
    node: {
        fs: "empty"
    },
    module: {
        rules: [
            {
                test: /\.coffee$/,
                exclude: /node_modules/,
                use: {
                  loader: "coffee-loader",
                  options: {
                    sourceMap: true,
                    presets: ["@babel/env"]
                  }
                }
            },
            {
                test: /\.styl$/,
                use: [
                    "style-loader",
                    "css-loader",
                    "stylus-loader"
                ]
            },
            {
                test: /\.css$/,
                use: [
                    "style-loader",
                    "css-loader"
                ]
            },
            {
                test: /\.pug$/,
                use: "pug-loader"
            },
            {
              test: /\.(gif|png|jpe?g|svg)$/i,
              use: [
                'file-loader',
                {
                  loader: 'image-webpack-loader',
                  options: {
                    disable: true
                  },
                },
              ],
            }
        ]
    }
}