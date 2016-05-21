// from https://github.com/jywarren/thermographer/blob/793050dd3f69317f8bb1e2ec57c89d2305bed731/thermographer-website/public/src/geometry.js
var geometry = {
	// http://stackoverflow.com/questions/2792443/finding-the-centroid-of-a-polygon
	/**
	 * Finds the centroid of a polygon
	 * @param {Node[]} polygon Array of nodes that make up the polygon
	 * @return A tuple, in [x, y] format, with the coordinates of the centroid
	 * @type Number[]
	 */
	poly_centroid: function(polygon) {
		var n = polygon.length
		var cx = 0, cy = 0
		var a = geometry.poly_area(polygon,true)
		console.log("area: ", a);
		var centroid = []
		var i,j
		var factor = 0
		
		for (i=0;i<n;i++) {
			j = i + 1;
			if (j >= n) {
				j = 0;
			}
			
			
			factor = (polygon[i].x * polygon[j].y - polygon[j].x * polygon[i].y)
			cx += (polygon[i].x + polygon[j].x) * factor
			cy += (polygon[i].y + polygon[j].y) * factor
		}
		
		a *= 6
		factor = 1/a
		cx *= factor
		cy *= factor
		centroid[0] = cx
		centroid[1] = cy
		return centroid
	},
	/**
		 * Finds the area of a polygon
		 * @param {Fred.Point[]}  points    Array of points with p.x and
			 p.y properties that make up the polygon 
		 * @param {Boolean} [signed] If true, returns a signed area, else
			 returns a positive area.
		 *                           Defaults to false.
		 * @return Area of the polygon
		 * @type Number
		 */
		poly_area: function(points, signed) {
			var area = 0
			var length = points.length
			for (var index = 0;index < length-1; index++) {
				console.log("point: ", point);
				point = points[index];
				if (index < point.length-1) next = points[index+1]
				else next = points[0]
				area += point.x * next.y - next.x * point.y;
			}
			if (signed) return area/2
			else return Math.abs(area/2)
		}
};


// from https://github.com/mapbox/fontnik/blob/37a5e17d7ab27c6e4db255b23448544dc07bd8ac/lib/curve4_div.js
function point_d(x, y) {
	return [x, y];
}

function calc_sq_distance(x1, y1, x2, y2) {
	var dx = x2 - x1;
	var dy = y2 - y1;
	return dx * dx + dy * dy;
}
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
	this.points.push(point_d(x1, y1));
	this.recursive_bezier(x1, y1, x2, y2, x3, y3, x4, y4, 0);
	this.points.push(point_d(x4, y4));
};

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
				d2 = calc_sq_distance(x1, y1, x2, y2);
				d3 = calc_sq_distance(x4, y4, x3, y3);
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
					d2 = calc_sq_distance(x2, y2, x1, y1);
				} else if (d2 >= 1) {
					d2 = calc_sq_distance(x2, y2, x4, y4);
				} else {
					d2 = calc_sq_distance(x2, y2, x1 + d2 * dx, y1 + d2 * dy);
				}

				if (d3 <= 0) {
					d3 = calc_sq_distance(x3, y3, x1, y1);
				} else if (d3 >= 1) {
					d3 = calc_sq_distance(x3, y3, x4, y4);
				} else {
					d3 = calc_sq_distance(x3, y3, x1 + d3 * dx, y1 + d3 * dy);
				}
			}

			if (d2 > d3) {
				if (d2 < this.distance_tolerance_square) {
					this.points.push(point_d(x2, y2));
					return;
				}
			} else {
				if (d3 < this.distance_tolerance_square) {
					this.points.push(point_d(x3, y3));
					return;
				}
			}
			break;

		case 1:
			// p1,p2,p4 are collinear, p3 is significant
			if (d3 * d3 <= this.distance_tolerance_square * (dx * dx + dy * dy)) {
				if (this.angle_tolerance < Curve4Div.curve_angle_tolerance_epsilon) {
					this.points.push(point_d(x23, y23));
					return;
				}

				// Angle Condition
				da1 = Math.abs(Math.atan2(y4 - y3, x4 - x3) - Math.atan2(y3 - y2, x3 - x2));
				if (da1 >= Math.PI) da1 = 2 * Math.PI - da1;

				if (da1 < this.angle_tolerance) {
					this.points.push(point_d(x2, y2));
					this.points.push(point_d(x3, y3));
					return;
				}

				if (this.cusp_limit !== 0.0) {
					if (da1 > this.cusp_limit) {
						this.points.push(point_d(x3, y3));
						return;
					}
				}
			}
			break;

		case 2:
			// p1,p3,p4 are collinear, p2 is significant
			if (d2 * d2 <= this.distance_tolerance_square * (dx * dx + dy * dy)) {
				if (this.angle_tolerance < Curve4Div.curve_angle_tolerance_epsilon) {
					this.points.push(point_d(x23, y23));
					return;
				}

				// Angle Condition
				da1 = Math.abs(Math.atan2(y3 - y2, x3 - x2) - Math.atan2(y2 - y1, x2 - x1));
				if (da1 >= Math.PI) da1 = 2 * Math.PI - da1;

				if (da1 < this.angle_tolerance) {
					this.points.push(point_d(x2, y2));
					this.points.push(point_d(x3, y3));
					return;
				}

				if (this.cusp_limit !== 0.0) {
					if (da1 > this.cusp_limit) {
						this.points.push(point_d(x2, y2));
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
					this.points.push(point_d(x23, y23));
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
					this.points.push(point_d(x23, y23));
					return;
				}

				if (this.cusp_limit !== 0.0) {
					if (da1 > this.cusp_limit) {
						this.points.push(point_d(x2, y2));
						return;
					}

					if (da2 > this.cusp_limit) {
						this.points.push(point_d(x3, y3));
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

function addPoint(array, point, curveMode, hasCurveFrom, curveFrom, hasCurveTo, curveTo) {
	var entry = {};
	entry.point = point;
	if (typeof curveMode != 'undefined') {
			entry.curveMode = curveMode;
		// if (hasCurveTo) {
			entry.curveTo = curveTo;
		// }
		// if (hasCurveFrom) {
			entry.curveFrom = curveFrom;
		// }


	}
	array.push(entry)
}

// Facebook
var facebook = [];
addPoint(facebook,[0.666667, 0.234115], 4, 1, [0.666667, 0.234115], 0, [0.666667, 0.234115]);
addPoint(facebook,[0.825521, 0.166667], 4, 0, [0.825521, 0.166667], 1, [0.686458, 0.166667]);
addPoint(facebook,[1.000000, 0.166667], 1, 0, [1.000000, 0.166667], 0, [1.000000, 0.166667]);
addPoint(facebook,[1.000000, 0.000000], 1, 0, [1.000000, 0.000000], 0, [1.000000, 0.000000]);
addPoint(facebook,[0.708854, 0.000000], 4, 1, [0.352083, 0.000000], 0, [0.708854, 0.000000]);
addPoint(facebook,[0.234375, 0.222135], 4, 0, [0.234375, 0.081771], 1, [0.234375, 0.081771]);
addPoint(facebook,[0.234375, 0.333333], 1, 0, [0.234375, 0.333333], 0, [0.234375, 0.333333]);
addPoint(facebook,[0.000000, 0.333333], 1, 0, [0.000000, 0.333333], 0, [0.000000, 0.333333]);
addPoint(facebook,[0.000000, 0.500000], 1, 0, [0.000000, 0.500000], 0, [0.000000, 0.500000]);
addPoint(facebook,[0.234375, 0.500000], 1, 0, [0.234375, 0.500000], 0, [0.234375, 0.500000]);
addPoint(facebook,[0.234375, 1.000000], 1, 0, [0.234375, 1.000000], 0, [0.234375, 1.000000]);
addPoint(facebook,[0.666667, 1.000000], 1, 0, [0.666667, 1.000000], 0, [0.666667, 1.000000]);
addPoint(facebook,[0.666667, 0.500000], 1, 0, [0.666667, 0.500000], 0, [0.666667, 0.500000]);
addPoint(facebook,[0.960417, 0.500000], 1, 0, [0.960417, 0.500000], 0, [0.960417, 0.500000]);
addPoint(facebook,[1.000000, 0.333333], 1, 0, [1.000000, 0.333333], 0, [1.000000, 0.333333]);
addPoint(facebook,[0.666667, 0.333333], 1, 0, [0.666667, 0.333333], 0, [0.666667, 0.333333]);

function extrudeBezierPath(pathEntries) {
	var previousEntry = null;
	var nextPreviousEntry = null;
	var newPoints = [];
	for (var key in pathEntries) {
		if (pathEntries.hasOwnProperty(key) == false) {
			continue;
		}
		if (nextPreviousEntry) {
			previousEntry = nextPreviousEntry;
			nextPreviousEntry = null;
		}
		
		var entry = pathEntries[key]
		nextPreviousEntry = entry;
		var point = entry.point
		var pointX = point[0];
		var pointY = point[1];
		if (!previousEntry) {
			newPoints.push(point);
			continue;
		}
		if (typeof entry.curveMode == 'undefined') {
			newPoints.push(point);
			continue;
		}
		if (entry.curveMode == 1) {
			newPoints.push(point);
			continue;
		}
		
		var previousX = previousEntry.point[0];
		var previousY = previousEntry.point[1];
		var controlPoint1x = previousEntry.curveFrom[0];
		var controlPoint1y = previousEntry.curveFrom[1];
		var controlPoint2x = entry.curveTo[0];
		var controlPoint2y = entry.curveTo[1];
		
		if (entry.curveMode == 1) {
			controlPoint2x = pointX;
			controlPoint2y = pointY;
		}
		
		if (previousEntry.curveMode == 1) {
			controlPoint1x = previousX;
			controlPoint1y = previousY;
		}
		
		var curve4 = new Curve4Div();
		curve4.approximation_scale = 2;
		curve4.init(previousX, previousY, controlPoint1x, controlPoint1y, controlPoint2x, controlPoint2y, pointX, pointY);
		var extrudedPoints = curve4.points;
		for (var extrudedKey in extrudedPoints) {
			if (extrudedPoints.hasOwnProperty(extrudedKey) == false) {
				continue;
			}
			var extrudedPoint = extrudedPoints[extrudedKey];
			newPoints.push(extrudedPoint);
		}
	}
	
	return newPoints;
}

var extrudedFacebook = extrudeBezierPath(facebook);
var facebookPolygon = [];
for (var extrudedKey in extrudedFacebook) {
	if (extrudedFacebook.hasOwnProperty(extrudedKey) == false) {
		continue;
	}
	var point = extrudedFacebook[extrudedKey];
	facebookPolygon.push({x: point[0], y: point[1]});
	
//	console.log("addPoint(extrudedFacebook, [" + point +"]);");
}

console.log(facebookPolygon);
console.log("centroid:", geometry.poly_centroid(facebookPolygon));

//var curve4 = new Curve4Div();
//curve4.approximation_scale = 2;
//curve4.init(prev[0], prev[1], segment.x1, segment.y1, segment.x2, segment.y2, segment.x, segment.y);
//console.log(curve4.points);