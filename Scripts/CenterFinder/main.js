console.log("hi!");

var canvasDrawClass = require("./canvasDraw");
var canvasDraw = canvasDrawClass("contentCanvas");
canvasDraw.clear();


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


var extrudedFacebook = polygonManager.extrudeBezierPath(facebook);
var rect = [300, 50 + 250, 192/2, 384/2];
var centroid = polygonManager.findExtrudedPathCentroid(extrudedFacebook);
// canvasDraw.context.rotate(20*Math.PI/180);
var rect = [300, 50 + 250, 192/2, 384/2];
canvasDraw.context.fillStyle = 'grey';
canvasDraw.context.fillRect(rect[0], rect[1], rect[2], rect[3]);
var rotationDegrees = 20;
// rect = polygonManager.rotatedBoundingRect(rect, rotationDegrees);
var size = {width: rect[2], height: rect[3]};
// extrudedFacebook = polygonManager.rotatedExtrudedPath(extrudedFacebook, rotationDegrees, size, centroid);
console.log("rotated: ", extrudedFacebook);
// canvasDraw.drawStrokedClosedPath(extrudedFacebook, rect);

function drawRotatedPath(path, rect) {
  var centroid = polygonManager.findExtrudedPathCentroid(path);
  var size = {width: rect[2], height: rect[3]};
  for (var rotation = 0; rotation < 360; rotation += 10) {

    var rotated = polygonManager.rotatedExtrudedPath(path, rotation, size, centroid);
    canvasDraw.drawStrokedClosedPath(rotated, rect);
  }
}

drawRotatedPath(extrudedFacebook, rect);


// rotate left
var polygon = [];
polygonManager.addPointEntry(polygon, [0.996607, 0.691288], 1, 0, [0.996607, 0.691288], 0, [0.996607, 0.691288]);
polygonManager.addPointEntry(polygon, [0.905959, 0.529375], 4, 1, [0.905637, 0.529375], 0, [0.905959, 0.529375]);
polygonManager.addPointEntry(polygon, [0.904810, 0.528015], 4, 1, [0.903891, 0.528519], 1, [0.905132, 0.528519]);
polygonManager.addPointEntry(polygon, [0.901732, 0.524388], 4, 1, [0.900675, 0.525496], 1, [0.902880, 0.525496]);
polygonManager.addPointEntry(polygon, [0.898378, 0.521466], 4, 1, [0.897137, 0.522272], 1, [0.899618, 0.522272]);
polygonManager.addPointEntry(polygon, [0.894427, 0.519451], 2, 1, [0.893508, 0.520056], 1, [0.895805, 0.520056]);
polygonManager.addPointEntry(polygon, [0.891716, 0.518091], 2, 1, [0.891119, 0.518343], 1, [0.892727, 0.518343]);
polygonManager.addPointEntry(polygon, [0.889924, 0.518040], 4, 1, [0.889373, 0.518141], 1, [0.890521, 0.518141]);
polygonManager.addPointEntry(polygon, [0.888316, 0.517537], 4, 1, [0.887489, 0.517587], 1, [0.888913, 0.517587]);
polygonManager.addPointEntry(polygon, [0.885881, 0.517889], 4, 1, [0.884089, 0.517839], 1, [0.886708, 0.517839]);
polygonManager.addPointEntry(polygon, [0.880643, 0.518645], 4, 1, [0.880046, 0.518141], 1, [0.882389, 0.518141]);
polygonManager.addPointEntry(polygon, [0.878851, 0.519350], 2, 1, [0.877335, 0.519098], 1, [0.879495, 0.519098]);
polygonManager.addPointEntry(polygon, [0.874349, 0.521164], 4, 0, [0.874349, 0.520207], 1, [0.875727, 0.520207]);
polygonManager.addPointEntry(polygon, [0.729303, 0.618845], 4, 1, [0.718506, 0.618845], 0, [0.729303, 0.618845]);
polygonManager.addPointEntry(polygon, [0.721768, 0.653505], 2, 1, [0.728384, 0.641616], 1, [0.715106, 0.641616]);
polygonManager.addPointEntry(polygon, [0.753378, 0.661767], 4, 0, [0.753378, 0.669172], 1, [0.742581, 0.669172]);
polygonManager.addPointEntry(polygon, [0.856477, 0.592397], 4, 1, [0.838237, 0.592397], 0, [0.856477, 0.592397]);
polygonManager.addPointEntry(polygon, [0.719838, 0.844939], 3, 1, [0.636541, 0.779499], 1, [0.790960, 0.779499]);
polygonManager.addPointEntry(polygon, [0.421246, 0.948061], 2, 1, [0.312129, 0.958237], 1, [0.530272, 0.958237]);
polygonManager.addPointEntry(polygon, [0.142548, 0.789876], 2, 1, [0.071932, 0.881714], 1, [0.213165, 0.881714]);
polygonManager.addPointEntry(polygon, [0.047489, 0.461920], 2, 1, [0.056770, 0.581566], 1, [0.038209, 0.581566]);
polygonManager.addPointEntry(polygon, [0.191754, 0.156332], 2, 1, [0.275511, 0.233711], 1, [0.107998, 0.233711]);
polygonManager.addPointEntry(polygon, [0.490852, 0.052101], 2, 1, [0.597856, 0.041874], 1, [0.381734, 0.041874]);
polygonManager.addPointEntry(polygon, [0.765828, 0.205449], 3, 1, [0.774144, 0.116584], 1, [0.695534, 0.116584]);
polygonManager.addPointEntry(polygon, [0.798219, 0.207968], 2, 1, [0.807822, 0.217087], 1, [0.788755, 0.217087]);
polygonManager.addPointEntry(polygon, [0.800562, 0.172402], 3, 1, [0.722365, 0.182931], 1, [0.808832, 0.182931]);
polygonManager.addPointEntry(polygon, [0.494757, 0.001875], 2, 1, [0.373464, 0.012958], 1, [0.613753, 0.012958]);
polygonManager.addPointEntry(polygon, [0.162074, 0.117743], 2, 1, [0.068991, 0.031597], 1, [0.255204, 0.031597]);
polygonManager.addPointEntry(polygon, [0.001683, 0.457588], 2, 1, [-0.008655, 0.324491], 1, [0.011974, 0.324491]);
polygonManager.addPointEntry(polygon, [0.107401, 0.822269], 2, 1, [0.185920, 0.720154], 1, [0.028882, 0.720154]);
polygonManager.addPointEntry(polygon, [0.417341, 0.998136], 3, 1, [0.430665, 0.986852], 1, [0.295956, 0.986852]);
polygonManager.addPointEntry(polygon, [0.457129, 1.000000], 3, 1, [0.564317, 1.000000], 1, [0.443943, 1.000000]);
polygonManager.addPointEntry(polygon, [0.749334, 0.883427], 2, 1, [0.825832, 0.959346], 1, [0.666818, 0.959346]);
polygonManager.addPointEntry(polygon, [0.899113, 0.613354], 4, 0, [0.899113, 0.718744], 1, [0.877381, 0.718744]);
polygonManager.addPointEntry(polygon, [0.957508, 0.717686], 4, 1, [0.961827, 0.717686], 0, [0.957508, 0.717686]);
polygonManager.addPointEntry(polygon, [0.977080, 0.729675], 2, 1, [0.981215, 0.729675], 1, [0.969362, 0.729675]);
polygonManager.addPointEntry(polygon, [0.989118, 0.725948], 2, 1, [0.999869, 0.728517], 1, [0.985350, 0.728517]);
polygonManager.addPointEntry(polygon, [0.996607, 0.691288], 4, 0, [0.996607, 0.703127], 1, [1.003223, 0.703127]);

var rotateLeft = polygon;

rect = [500, 200, 350/2, 318/2];

// var extrudedRotateLeft = polygonManager.extrudeBezierPath(rotateLeft);
canvasDraw.drawStrokedClosedPath(rotateLeft, rect);

// canvasDraw.drawCentroid(centroid, rect);
console.log("centroid: ", centroid);

console.log("extruded: ", extrudedFacebook.length);
// check if HMR is enabled
if(module && module.hot) {
    // accept itself
    module.hot.accept();
    console.log("change accepted!");
}
