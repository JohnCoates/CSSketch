define(function() {
  var polygonManager = {};
  polygonManager.addPointEntry = function (targetArray, point, curveMode, hasCurveFrom, curveFrom, hasCurveTo, curveTo) {
  	var entry = {};
  	entry.point = {x: point[0], y: point[1]};
  	if (typeof curveMode != 'undefined') {
  			entry.curveMode = curveMode;
  			entry.curveTo = {x: curveTo[0], y: curveTo[1]};
  			entry.curveFrom = {x: curveFrom[0], y: curveFrom[1]};
  	}
  	targetArray.push(entry)
  }
  return polygonManager;
});
