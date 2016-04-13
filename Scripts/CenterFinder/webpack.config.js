var path = require('path');
module.exports = {
    entry: {
      bundle: [
        'webpack/hot/only-dev-server',
        'webpack-dev-server/client?http://localhost:8080',
        path.resolve(__dirname, 'main.js')
      ],
    },
    output: {
        path: __dirname,
        filename: "bundle.js",
        publicPath: "http://localhost:8080/"
    },

};
