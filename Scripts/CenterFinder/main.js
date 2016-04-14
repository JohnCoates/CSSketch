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
var ratio = { x: 192, y: 384 };
facebook = polygonManager.convertPolygonToSquarePixels(facebook, ratio);

// canvasDraw.drawStrokedClosedPath(facebook, [300, 50, 192/2, 384/2]);


var extrudedFacebook = polygonManager.extrudeBezierPath(facebook);
var rect = [300, 50 + 250, 192/2, 384/2];
var centroid = polygonManager.findExtrudedPathCentroid(extrudedFacebook);
canvasDraw.drawStrokedClosedPath(extrudedFacebook, rect);
canvasDraw.drawCentroid(centroid, rect);
console.log("facebook centroid: ", centroid);
// canvasDraw.context.rotate(20*Math.PI/180);
var rect = [300, 50 + 250, 192/2, 384/2];
// canvasDraw.context.fillStyle = 'grey';
// canvasDraw.context.fillRect(rect[0], rect[1], rect[2], rect[3]);
var rotationDegrees = 20;
// rect = polygonManager.rotatedBoundingRect(rect, rotationDegrees);
var size = {width: rect[2], height: rect[3]};
// extrudedFacebook = polygonManager.rotatedExtrudedPath(extrudedFacebook, rotationDegrees, size, centroid);
// canvasDraw.drawStrokedClosedPath(extrudedFacebook, rect);

function drawRotatedPath(path, rect, degreesPerRotation) {
  var centroid = polygonManager.findExtrudedPathCentroid(path);
  var size = {width: rect[2], height: rect[3]};
  for (var rotation = 0; rotation < 360; rotation += degreesPerRotation) {

    var rotated = polygonManager.rotatedExtrudedPath(path, rotation, size, centroid);
    canvasDraw.drawStrokedClosedPath(rotated, rect);
  }
}

// drawRotatedPath(extrudedFacebook, rect, 90);

// rotate left
var polygon = [];
polygonManager.addPointEntry(polygon, [0.905958565858884123934, 0.529375358212546776038], 4, 1, [0.903891072488077873537, 0.526654984560596228782], 0, [0.905958565858884123934, 0.529375358212546776038]);
polygonManager.addPointEntry(polygon, [0.901731690523013496019, 0.524388006517303995047], 4, 1, [0.900674971689045866796, 0.523330083430434189751], 1, [0.902880297951239141341, 0.525496306894024489687]);
polygonManager.addPointEntry(polygon, [0.898377756832594354108, 0.521466123705949580192], 4, 1, [0.897137260810110692688, 0.520609709778483753517], 1, [0.899618252855078237573, 0.522272160343564717522]);
polygonManager.addPointEntry(polygon, [0.894426547279497996534, 0.519451032111912125444], 2, 1, [0.893507661336917280437, 0.519048013793104723312], 1, [0.895804876193368682102, 0.520055559590123395175]);
polygonManager.addPointEntry(polygon, [0.891715833748885078336, 0.518090845285936962838], 2, 1, [0.889372674595304668621, 0.517939713416384228672], 1, [0.892726608285723810532, 0.518342731735191630804]);
polygonManager.addPointEntry(polygon, [0.888315955761337039398, 0.517536695097576715519], 4, 1, [0.884089080425466189439, 0.517939713416384228672], 1, [0.888913231624014477106, 0.517587072387427515885]);
polygonManager.addPointEntry(polygon, [0.88064325814078903143, 0.518644995474297321181], 4, 1, [0.877335268747498897568, 0.519954805010421572398], 1, [0.882389141431692225481, 0.518141222575787985249]);
polygonManager.addPointEntry(polygon, [0.874348889434112042096, 0.52116385996684411186], 4, 0, [0.874348889434112042096, 0.52116385996684411186], 1, [0.875727218347982838687, 0.520206691459676240363]);
polygonManager.addPointEntry(polygon, [0.729302743397767461175, 0.61884542498781103248], 4, 1, [0.718505833572445684609, 0.626150132016196847573], 0, [0.729302743397767461175, 0.61884542498781103248]);
polygonManager.addPointEntry(polygon, [0.721767878668606588377, 0.653505000405255609408], 2, 1, [0.728383857455186745078, 0.66534366352022578095], 1, [0.715105955584897423627, 0.641615960000434415456]);
polygonManager.addPointEntry(polygon, [0.753377555093378559192, 0.661766875940809295997], 4, 0, [0.753377555093378559192, 0.661766875940809295997], 1, [0.742580645268056893649, 0.669172337548896933868]);
polygonManager.addPointEntry(polygon, [0.856476557850919695269, 0.592397347816069008708], 4, 1, [0.838236671890695284048, 0.69113683592390551258], 0, [0.856476557850919695269, 0.592397347816069008708]);
polygonManager.addPointEntry(polygon, [0.719838218189187362128, 0.844938701838816030865], 3, 1, [0.636541207494257688104, 0.921612936991942022225], 1, [0.790959990144924351974, 0.779498602322448830293]);
polygonManager.addPointEntry(polygon, [0.42124623114762799192, 0.948061014163684157019], 2, 1, [0.312128525466184081338, 0.937884801613794616415], 1, [0.530272048234813664358, 0.958237226713573253534]);
polygonManager.addPointEntry(polygon, [0.142548124762938044352, 0.789876324031741905429], 2, 1, [0.0719317400756204761159, 0.698038524633483703496], 1, [0.213164509450255612588, 0.88171412342999999634]);
polygonManager.addPointEntry(polygon, [0.0474893740029770500266, 0.46192016710214217623], 2, 1, [0.0567701220230409156486, 0.342274103706166787919], 1, [0.0382086259829131982824, 0.581566230498117509029]);
polygonManager.addPointEntry(polygon, [0.191754466988128119409, 0.156331526866358372363], 2, 1, [0.275510920654348012704, 0.0789016323654682105726], 1, [0.10799801332190825387, 0.233711044077397567253]);
polygonManager.addPointEntry(polygon, [0.490851841298106883471, 0.052100914164769730752], 2, 1, [0.597856109311615480095, 0.062075617555255251101], 1, [0.381734135616663083912, 0.0418743243250295354985]);
polygonManager.addPointEntry(polygon, [0.765828459615345513711, 0.205449384471021956333], 3, 1, [0.774144377395699856415, 0.215927860760016826491], 1, [0.695533685007931112843, 0.1165838451739691084]);
polygonManager.addPointEntry(polygon, [0.798219189091310843409, 0.207968248963568802523], 2, 1, [0.807821547191277966604, 0.198849959500549205993], 1, [0.788754663882730966407, 0.217086538426588399053]);
polygonManager.addPointEntry(polygon, [0.800562348244891253124, 0.172401882328807265488], 3, 1, [0.722365154531283915063, 0.0735616396412688972051], 1, [0.8088323217281166988, 0.182930735907653102545]);
polygonManager.addPointEntry(polygon, [0.494757106554074232996, 0.0018747561833855677909], 2, 1, [0.37346416213343786028, -0.00956088861277715543197], 1, [0.613752836118259370579, 0.0129577599505916931516]);
polygonManager.addPointEntry(polygon, [0.162074451042775430354, 0.117742522840540625451], 2, 1, [0.0689913050593626980822, 0.203786933905941020084], 1, [0.255203541323317240064, 0.0315973571954383594673]);
polygonManager.addPointEntry(polygon, [0.00168290976533521014803, 0.457587720174961409825], 2, 1, [-0.00865455708869631787361, 0.590684519961137022293], 1, [0.0119744323222377158089, 0.324490920388786019402]);
polygonManager.addPointEntry(polygon, [0.107400737459230968818, 0.822268921405894359644], 2, 1, [0.185919541252741488124, 0.924333310643892680503], 1, [0.0288819336657203801222, 0.720154154878045016375]);
polygonManager.addPointEntry(polygon, [0.417340965891660531373, 0.998136040275515390441], 3, 1, [0.430664812059078971895, 0.999345095231937929903], 1, [0.295956132876766031536, 0.986851527348905466219]);
polygonManager.addPointEntry(polygon, [0.457128727205399709721, 1], 3, 1, [0.564316772407424394054, 1], 1, [0.443942713929368348857, 1]);
polygonManager.addPointEntry(polygon, [0.74933445694602418552, 0.883426951284931649688], 2, 1, [0.825831711665857448601, 0.813049877363172912581], 1, [0.666818499302288092423, 0.959345527090294081241]);
polygonManager.addPointEntry(polygon, [0.899112865586658593919, 0.613354300394058582491], 4, 0, [0.899112865586658593919, 0.613354300394058582491], 1, [0.877381213044627794595, 0.718743590762218720336]);
polygonManager.addPointEntry(polygon, [0.95750806723765458095, 0.717685667675349137085], 4, 1, [0.961826831167783335985, 0.725393393022542465332], 0, [0.95750806723765458095, 0.717685667675349137085]);
polygonManager.addPointEntry(polygon, [0.977080337814620780712, 0.729675462659872153814], 2, 1, [0.981215324556233392528, 0.729675462659872153814], 1, [0.969361695896944097761, 0.729675462659872153814]);
polygonManager.addPointEntry(polygon, [0.989117743662426440743, 0.725947543210902712651], 2, 1, [0.999868709190619431304, 0.718642836182516897559], 1, [0.985350311297846004344, 0.728516784993300636764]);
polygonManager.addPointEntry(polygon, [0.996606664094458305492, 0.691287967793458135723], 4, 0, [0.996606664094458305492, 0.691287967793458135723], 1, [1.00322264288103846219, 0.703126630908428307265]);

polygon = polygonManager.convertPolygonToSquarePixels(polygon, { x: 350, y: 318 });
var rotateLeft = polygon;
rect = [500, 50, 350/2, 318/2];
// canvasDraw.drawStrokedClosedPath(rotateLeft, rect);

var extrudedRotateLeft = polygonManager.extrudeBezierPath(rotateLeft);
// drawRotatedPath(extrudedRotateLeft, rect, 180);
drawCenteredRotatedExtrudedPath(extrudedRotateLeft, rect, 180);

function drawCenteredRotatedExtrudedPath(path, rect, degreesPerRotation) {
  var size = {width: rect[2], height: rect[3]};
  var centroid = polygonManager.findExtrudedPathCentroid(path);
  var center = centerOfPath(path);
  var allPaths = [];

  // canvasDraw.drawCentroid(centroid, rect);
  path = hydratePathWithCenteringInformation(path);

  for (var rotation = 0; rotation < 360; rotation += degreesPerRotation) {
    var rotated = polygonManager.rotatedExtrudedPath(path, rotation, size, centroid);
    // var pathCentered = centeredPath(rotated, center);
    // var pathCentered = centroidCenteredPath(rotated, centroid);
    // allPaths = allPaths.concat(pathCentered);

    canvasDraw.drawStrokedClosedPath(rotated, rect);
    var centroid = polygonManager.findExtrudedPathCentroid(rotated);
    canvasDraw.drawCentroid(centroid, rect);

  }

  // console.log("center of all paths");
  // var allCenter = centerOfPath(allPaths);
  // canvasDraw.drawCentroid(allCenter, rect);
  // var pathCentered = centeredPath(path, allCenter);
  // canvasDraw.drawStrokedClosedPath(path, rect);

  return;
  var scale = rect[2];
  var numberOfSides = 360,
      size = scale / 2,
      Xcenter = rect[0] + (centroid.x * scale),
      Ycenter = rect[1] + (centroid.y * scale);

  canvasDraw.context.beginPath();
  canvasDraw.context.moveTo (Xcenter +  size * Math.cos(0), Ycenter +  size *  Math.sin(0));

  for (var i = 1; i <= numberOfSides;i += 1) {
      canvasDraw.context.lineTo (Xcenter + size * Math.cos(i * 2 * Math.PI / numberOfSides), Ycenter + size * Math.sin(i * 2 * Math.PI / numberOfSides));
  }

  canvasDraw.context.strokeStyle = "#000000";
  canvasDraw.context.lineWidth = 1;
  canvasDraw.context.stroke();


  // clamp furthest point from center to edge

}
function minMaxForPath(path) {
  var min = {x: 0, y:0 };
  var max = {x: 0, y:0 };
  var length = path.length;
  for (var index = 0; index < length; index +=1 ) {
    var entry = path[index];
    var point = entry.point;
    if (point.x < min.x) {
      min.x = point.x;
    }

    if (point.y < min.y) {
      min.y = point.y;
    }

    if (point.x > max.x) {
      max.x = point.x;
    }

    if (point.y > max.y) {
      max.y = point.y;
    }
  }

  return {min: min, max: max};
}
function centerOfPath(path) {
  var minMax = minMaxForPath(path);
  var min = minMax.min;
  var max = minMax.max;
  var size = {x: max.x - min.x, y: max.y - min.y};
  console.log("size: ", size);
  return {x: min.x + (size.x / 2), y: min.y + (size.y / 2)};
}

function centeredPath(path, targetCenter) {
  var currentCenter = centerOfPath(path);
  var translate = {x: targetCenter.x - currentCenter.x, y: targetCenter.y - currentCenter.y};
  var length = path.length;
  for (var index = 0; index < length; index +=1 ) {
    var entry = path[index];
    var point = entry.point;
    point.x = point.x + translate.x;
    point.y = point.y + translate.y;

    path[index].point = point;
  }

  return path;
}

function centroidCenteredPath(path, targetCentroid) {
  var centroid = polygonManager.findExtrudedPathCentroid(path);
  var translate = {x: targetCentroid.x - centroid.x, y: targetCentroid.y - centroid.y};
  var length = path.length;
  for (var index = 0; index < length; index +=1 ) {
    var entry = path[index];
    var point = entry.point;
    point.x = point.x + translate.x;
    point.y = point.y + translate.y;

    path[index].point = point;
  }

  return path;
}

function hydratePathWithCenteringInformation(path) {
  var centroid = polygonManager.findExtrudedPathCentroid(path);
  var minMax = minMaxForPath(path);
  var length = path.length;
  var farthestDistanceFromCentroid = 0;
  var closestDistanceFromCentroid = 99999;

  for (var index = 0; index < length; index +=1 ) {
    var entry = path[index];
    var point = entry.point;

    entry.distanceFromCentroid = Math.abs(centroid.x - point.x) + Math.abs(centroid.y - point.y);
    if (entry.distanceFromCentroid > farthestDistanceFromCentroid) {
      farthestDistanceFromCentroid = entry.distanceFromCentroid;
    }
    if (entry.distanceFromCentroid < closestDistanceFromCentroid) {
      closestDistanceFromCentroid = entry.distanceFromCentroid;
    }

    path[index] = entry;
  }

  for (var index = 0; index < length; index +=1 ) {
    var entry = path[index];
    if (entry.distanceFromCentroid == closestDistanceFromCentroid) {
      entry.shouldCentroidClamp = true;
      console.log("should centroid clamp: ", entry);
    }
    if (entry.distanceFromCentroid == farthestDistanceFromCentroid) {
      entry.shouldEdgeClamp = true;
      console.log("should edge clamp:", entry);
    }
    else {
      entry.shouldEdgeClamp = false;
    }

    path[index] = entry;
  }

  return path;
}

// check if HMR is enabled
if(module && module.hot) {
    // accept itself
    module.hot.accept();
}
