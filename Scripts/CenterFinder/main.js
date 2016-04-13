console.log("hi!");

var canvasDrawClass = require("./canvasDraw");
var canvasDraw = canvasDrawClass("contentCanvas");
canvasDraw.clear();

console.log("context: ", canvasDraw.context);


var polygonManager = require("./polygonManager");

// bezier facebook logo
var facebook = [];
polygonManager.addPointEntry(facebook, [0.666667, 0.234115], 4, 1, [0.666667, 0.234115], 0, [0.666667, 0.234115]);
polygonManager.addPointEntry(facebook, [0.825521, 0.166667], 4, 0, [0.825521, 0.166667], 1, [0.686458, 0.166667]);
polygonManager.addPointEntry(facebook, [1.000000, 0.166667], 1, 0, [1.000000, 0.166667], 0, [1.000000, 0.166667]);
polygonManager.addPointEntry(facebook, [1.000000, 0.000000], 1, 0, [1.000000, 0.000000], 0, [1.000000, 0.000000]);
polygonManager.addPointEntry(facebook, [0.708854, 0.000000], 4, 1, [0.352083, 0.000000], 0, [0.708854, 0.000000]);
polygonManager.addPointEntry(facebook, [0.234375, 0.222135], 4, 0, [0.234375, 0.081771], 1, [0.234375, 0.081771]);
polygonManager.addPointEntry(facebook, [0.234375, 0.333333], 1, 0, [0.234375, 0.333333], 0, [0.234375, 0.333333]);
polygonManager.addPointEntry(facebook, [0.000000, 0.333333], 1, 0, [0.000000, 0.333333], 0, [0.000000, 0.333333]);
polygonManager.addPointEntry(facebook, [0.000000, 0.500000], 1, 0, [0.000000, 0.500000], 0, [0.000000, 0.500000]);
polygonManager.addPointEntry(facebook, [0.234375, 0.500000], 1, 0, [0.234375, 0.500000], 0, [0.234375, 0.500000]);
polygonManager.addPointEntry(facebook, [0.234375, 1.000000], 1, 0, [0.234375, 1.000000], 0, [0.234375, 1.000000]);
polygonManager.addPointEntry(facebook, [0.666667, 1.000000], 1, 0, [0.666667, 1.000000], 0, [0.666667, 1.000000]);
polygonManager.addPointEntry(facebook, [0.666667, 0.500000], 1, 0, [0.666667, 0.500000], 0, [0.666667, 0.500000]);
polygonManager.addPointEntry(facebook, [0.960417, 0.500000], 1, 0, [0.960417, 0.500000], 0, [0.960417, 0.500000]);
polygonManager.addPointEntry(facebook, [1.000000, 0.333333], 1, 0, [1.000000, 0.333333], 0, [1.000000, 0.333333]);
polygonManager.addPointEntry(facebook, [0.666667, 0.333333], 1, 0, [0.666667, 0.333333], 0, [0.666667, 0.333333]);
canvasDraw.drawStrokedClosedPath(facebook, [300, 50, 192/2, 384/2]);

// check if HMR is enabled
if(module && module.hot) {
    // accept itself
    module.hot.accept();
    console.log("change accepted!");
}
