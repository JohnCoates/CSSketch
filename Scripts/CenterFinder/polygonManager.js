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

  polygonManager.addBezierCurveEntry = function (targetArray, point, controlPoint1, controlPoint2) {
    var entry = {};
    entry.point = {x: point[0], y: point[1]};
    if (typeof controlPoint1 != 'undefined') {
        entry.controlPoint1 = {x: controlPoint1[0], y: controlPoint1[1]};
        entry.controlPoint2 = {x: controlPoint2[0], y: controlPoint2[1]};
    }
    targetArray.push(entry)
  }

  polygonManager.convertPolygonToSquarePixels = function (path, ratio) {
    var length = path.length;
    var farthestDistanceFromCentroid = {x: 0, y: 0};
    var xScale = ratio.x / ratio.y;
    var yScale = ratio.y / ratio.x;

    for (var index = 0; index < length; index +=1 ) {
      var entry = path[index];
      var point = entry.point;
      point.y = point.y * yScale;
      entry.point = point;

      if (typeof entry.controlPoint1 != 'undefined') {
          entry.controlPoint1.y *= yScale;
          entry.controlPoint2.y *= yScale;
      }

      if (typeof entry.curveFrom != 'undefined') {
          entry.curveFrom.y *= yScale;
          entry.curveTo.y *= yScale;
      }

      path[index] = entry;
    }

    return path;
  }

  // from https://github.com/mapbox/fontnik/blob/37a5e17d7ab27c6e4db255b23448544dc07bd8ac/lib/curve4_div.js
  function Curve4Div() {}

  Curve4Div.curve_collinearity_epsilon = 1e-30;
  Curve4Div.curve_angle_tolerance_epsilon = 0.01;
  Curve4Div.curve_recursion_limit = 32;

  Curve4Div.prototype.approximation_scale = 1.0;
  Curve4Div.prototype.angle_tolerance = 0.0;
  Curve4Div.prototype.cusp_limit = 0.0;


  Curve4Div.prototype.init = function(x1, y1, x2, y2, x3, y3, x4, y4) {
  	this.points = [];
  	this.distance_tolerance_square = 0.5 / this.approximation_scale;
  	this.distance_tolerance_square *= this.distance_tolerance_square;
  	this.bezier(x1, y1, x2, y2, x3, y3, x4, y4);
  };

  Curve4Div.prototype.bezier = function(x1, y1, x2, y2, x3, y3, x4, y4) {
  	this.points.push(this.point_d(x1, y1));
  	this.recursive_bezier(x1, y1, x2, y2, x3, y3, x4, y4, 0);
  	this.points.push(this.point_d(x4, y4));
  };

  Curve4Div.prototype.calc_sq_distance = function (x1, y1, x2, y2) {
  	var dx = x2 - x1;
  	var dy = y2 - y1;
  	return dx * dx + dy * dy;
  }

  Curve4Div.prototype.point_d = function (x, y) {
  	return [x, y];
  }

  Curve4Div.prototype.recursive_bezier = function(x1, y1, x2, y2, x3, y3, x4, y4, level) {
  	if (level > Curve4Div.curve_recursion_limit) {
  		return;
  	}

  	// Calculate all the mid-points of the line segments
  	var x12 = (x1 + x2) / 2;
  	var y12 = (y1 + y2) / 2;
  	var x23 = (x2 + x3) / 2;
  	var y23 = (y2 + y3) / 2;
  	var x34 = (x3 + x4) / 2;
  	var y34 = (y3 + y4) / 2;
  	var x123 = (x12 + x23) / 2;
  	var y123 = (y12 + y23) / 2;
  	var x234 = (x23 + x34) / 2;
  	var y234 = (y23 + y34) / 2;
  	var x1234 = (x123 + x234) / 2;
  	var y1234 = (y123 + y234) / 2;

  	// Try to approximate the full cubic curve by a single straight line
  	var dx = x4 - x1;
  	var dy = y4 - y1;

  	var d2 = Math.abs(((x2 - x4) * dy - (y2 - y4) * dx));
  	var d3 = Math.abs(((x3 - x4) * dy - (y3 - y4) * dx));
  	var da1, da2, k;

  	switch ((Math.floor(d2 > Curve4Div.curve_collinearity_epsilon) << 1) +
  		Math.floor(d3 > Curve4Div.curve_collinearity_epsilon)) {
  		case 0:
  			// All collinear OR p1==p4
  			k = dx * dx + dy * dy;
  			if (k === 0) {
  				d2 = this.calc_sq_distance(x1, y1, x2, y2);
  				d3 = this.calc_sq_distance(x4, y4, x3, y3);
  			} else {
  				k = 1 / k;
  				da1 = x2 - x1;
  				da2 = y2 - y1;
  				d2 = k * (da1 * dx + da2 * dy);
  				da1 = x3 - x1;
  				da2 = y3 - y1;
  				d3 = k * (da1 * dx + da2 * dy);
  				if (d2 > 0 && d2 < 1 && d3 > 0 && d3 < 1) {
  					// Simple collinear case, 1---2---3---4
  					// We can leave just two endpoints
  					return;
  				}
  				if (d2 <= 0) {
  					d2 = this.calc_sq_distance(x2, y2, x1, y1);
  				} else if (d2 >= 1) {
  					d2 = this.calc_sq_distance(x2, y2, x4, y4);
  				} else {
  					d2 = this.calc_sq_distance(x2, y2, x1 + d2 * dx, y1 + d2 * dy);
  				}

  				if (d3 <= 0) {
  					d3 = this.calc_sq_distance(x3, y3, x1, y1);
  				} else if (d3 >= 1) {
  					d3 = this.calc_sq_distance(x3, y3, x4, y4);
  				} else {
  					d3 = this.calc_sq_distance(x3, y3, x1 + d3 * dx, y1 + d3 * dy);
  				}
  			}

  			if (d2 > d3) {
  				if (d2 < this.distance_tolerance_square) {
  					this.points.push(this.point_d(x2, y2));
  					return;
  				}
  			} else {
  				if (d3 < this.distance_tolerance_square) {
  					this.points.push(this.point_d(x3, y3));
  					return;
  				}
  			}
  			break;

  		case 1:
  			// p1,p2,p4 are collinear, p3 is significant
  			if (d3 * d3 <= this.distance_tolerance_square * (dx * dx + dy * dy)) {
  				if (this.angle_tolerance < Curve4Div.curve_angle_tolerance_epsilon) {
  					this.points.push(this.point_d(x23, y23));
  					return;
  				}

  				// Angle Condition
  				da1 = Math.abs(Math.atan2(y4 - y3, x4 - x3) - Math.atan2(y3 - y2, x3 - x2));
  				if (da1 >= Math.PI) da1 = 2 * Math.PI - da1;

  				if (da1 < this.angle_tolerance) {
  					this.points.push(this.point_d(x2, y2));
  					this.points.push(this.point_d(x3, y3));
  					return;
  				}

  				if (this.cusp_limit !== 0.0) {
  					if (da1 > this.cusp_limit) {
  						this.points.push(this.point_d(x3, y3));
  						return;
  					}
  				}
  			}
  			break;

  		case 2:
  			// p1,p3,p4 are collinear, p2 is significant
  			if (d2 * d2 <= this.distance_tolerance_square * (dx * dx + dy * dy)) {
  				if (this.angle_tolerance < Curve4Div.curve_angle_tolerance_epsilon) {
  					this.points.push(this.point_d(x23, y23));
  					return;
  				}

  				// Angle Condition
  				da1 = Math.abs(Math.atan2(y3 - y2, x3 - x2) - Math.atan2(y2 - y1, x2 - x1));
  				if (da1 >= Math.PI) da1 = 2 * Math.PI - da1;

  				if (da1 < this.angle_tolerance) {
  					this.points.push(this.point_d(x2, y2));
  					this.points.push(this.point_d(x3, y3));
  					return;
  				}

  				if (this.cusp_limit !== 0.0) {
  					if (da1 > this.cusp_limit) {
  						this.points.push(this.point_d(x2, y2));
  						return;
  					}
  				}
  			}
  			break;

  		case 3:
  			// Regular case
  			if ((d2 + d3) * (d2 + d3) <= this.distance_tolerance_square * (dx * dx + dy * dy)) {
  				// If the curvature doesn't exceed the distance_tolerance value
  				// we tend to finish subdivisions.
  				if (this.angle_tolerance < Curve4Div.curve_angle_tolerance_epsilon) {
  					this.points.push(this.point_d(x23, y23));
  					return;
  				}

  				// Angle & Cusp Condition
  				k = Math.atan2(y3 - y2, x3 - x2);
  				da1 = Math.abs(k - Math.atan2(y2 - y1, x2 - x1));
  				da2 = Math.abs(Math.atan2(y4 - y3, x4 - x3) - k);
  				if (da1 >= Math.PI) da1 = 2 * Math.PI - da1;
  				if (da2 >= Math.PI) da2 = 2 * Math.PI - da2;

  				if (da1 + da2 < this.angle_tolerance) {
  					// Finally we can stop the recursion
  					this.points.push(this.point_d(x23, y23));
  					return;
  				}

  				if (this.cusp_limit !== 0.0) {
  					if (da1 > this.cusp_limit) {
  						this.points.push(this.point_d(x2, y2));
  						return;
  					}

  					if (da2 > this.cusp_limit) {
  						this.points.push(this.point_d(x3, y3));
  						return;
  					}
  				}
  			}
  			break;
  	}

  	// Continue subdivision
  	this.recursive_bezier(x1, y1, x12, y12, x123, y123, x1234, y1234, level + 1);
  	this.recursive_bezier(x1234, y1234, x234, y234, x34, y34, x4, y4, level + 1);
    };

    polygonManager.extrudeBezierPath = function (pointEntries) {
  	var previousEntry = null;
  	var nextPreviousEntry = null;
  	var newPointEntries = [];
  	for (var key in pointEntries) {
  		if (nextPreviousEntry) {
  			previousEntry = nextPreviousEntry;
  			nextPreviousEntry = null;
  		}

  		var entry = pointEntries[key]
  		nextPreviousEntry = entry;
  		var point = entry.point
  		var pointX = point.x;
  		var pointY = point.y;
  		if (!previousEntry) {
        var newEntry = { point: entry.point };
  			newPointEntries.push(newEntry);
  			continue;
  		}
  		if (typeof entry.curveMode == 'undefined') {
        var newEntry = { point: entry.point };
  			newPointEntries.push(newEntry);
  			continue;
  		}
  		if (entry.curveMode == 1) {
        var newEntry = { point: entry.point };
  			newPointEntries.push(newEntry);
  			continue;
  		}

  		var previousX = previousEntry.point.x;
  		var previousY = previousEntry.point.y;
  		var controlPoint1x = previousEntry.curveFrom.x;
  		var controlPoint1y = previousEntry.curveFrom.y;
  		var controlPoint2x = entry.curveTo.x;
  		var controlPoint2y = entry.curveTo.y;

  		if (entry.curveMode == 1) {
  			controlPoint2x = pointX;
  			controlPoint2y = pointY;
  		}

  		if (previousEntry.curveMode == 1) {
  			controlPoint1x = previousX;
  			controlPoint1y = previousY;
  		}

  		var curve4 = new Curve4Div();
  		curve4.approximation_scale = 100;
  		curve4.init(previousX, previousY, controlPoint1x, controlPoint1y, controlPoint2x, controlPoint2y, pointX, pointY);
  		var extrudedPoints = curve4.points;

  		for (var extrudedKey in extrudedPoints) {
        var extrudedPoint = extrudedPoints[extrudedKey];
        var newEntry = { point: { x: extrudedPoint[0], y: extrudedPoint[1] } };
  			newPointEntries.push(newEntry);
  		}
  	}

  	return newPointEntries;
  }

  polygonManager.findExtrudedPathCentroid = function (pointEntries) {
    // https://en.wikipedia.org/wiki/Centroid#Centroid_of_polygon
    // n is supposed to be all path entries, with the last one being
    // the same as the first one, to close the path. Our polygons ommit the
    // last path entry, so instead of summing to n-1, we sum to full n,
    // wrapping the last value to the first value
    var n = pointEntries.length;
    var cX = 0
    var cY = 0

    for (var index = 0; index < n; index++) {
      var point = pointEntries[index].point;
      var nextIndex = index + 1;
      if (index == n - 1) {
        nextIndex = 0;
      }
      var nextPoint = pointEntries[nextIndex].point;
      var xi = point.x;
      var yi = point.y;
      var xiPlus1 = nextPoint.x;
      var yiPlus1 = nextPoint.y;

      var factor = xi * yiPlus1 - xiPlus1 * yi;
      cX += (xi + xiPlus1) * factor;
      cY += (yi + yiPlus1) * factor;
    }

    var area6 = this.findExtrudedPathArea(pointEntries) * 6;
    var factor = 1 / area6;
    cX = factor * cX;
    cY = factor * cY;

    return { x: cX, y: cY };
  }

  // returns signed area
  polygonManager.findExtrudedPathArea = function (pointEntries) {
    // https://en.wikipedia.org/wiki/Centroid#Centroid_of_polygon
    // n is supposed to be all path entries, with the last one being
    // the same as the first one, to close the path. Our polygons ommit the
    // last path entry, so instead of summing to n-1, we sum to full n,
    // wrapping the last value to the first value
    var sum = 0;
    var n = pointEntries.length;
    var area = 0;
    for (var index = 0; index < n; index++) {
      var point = pointEntries[index].point;
      var nextIndex = index + 1;
      if (index == n - 1) {
        nextIndex = 0;
      }
      var nextPoint = pointEntries[nextIndex].point;

      var xi = point.x;
      var yi = point.y;
      var xiPlus1 = nextPoint.x;
      var yiPlus1 = nextPoint.y;

      area += xi * yiPlus1 - xiPlus1 * yi;
    }

    return area / 2;
  }

  polygonManager.rotatedExtrudedPath = function (pointEntries, rotationDegrees, size, origin) {
    // https://en.wikipedia.org/wiki/Transformation_matrix#Rotation
    var newEntries = [];
    var length = pointEntries.length;
    var radians = rotationDegrees * (Math.PI / 180);

    for (var index = 0; index < length; index++) {
      var point = pointEntries[index].point;
      var rotatedPoint = this.rotatePointAroundOrigin(point, radians, origin);

      var newEntry = { point: rotatedPoint };
      newEntries.push(newEntry);
    }

    return newEntries;
  }

  polygonManager.rotatePoint = function (point, radians) {
    var theta = radians;
    var x = point.x;
    var y = point.y;
    var theta = radians;
    x = x * Math.cos(theta) + y * Math.sin(theta);
    y = (0 - x) * Math.sin(theta) + y * Math.cos(theta);
    // x = x * Math.cos(theta) - y * Math.sin(theta);
    // y = x * Math.sin(theta) + y * Math.cos(theta);

    return { x: x, y: y};
  }

  polygonManager.rotatePointAroundOrigin = function (point, radians, origin) {
    var theta = radians;
    var x1, y1;
    var x0 = origin.x,
        y0 = origin.y,
        x = point.x,
        y = point.y;
    x1 = x0 + (x - x0) * Math.cos(theta) + (y - y0) * Math.sin(theta);
    y1 = y0 - (x - x0) * Math.sin(theta) + (y - y0) * Math.cos(theta);
    return { x: x1, y: y1};
  }

  return polygonManager;
});
