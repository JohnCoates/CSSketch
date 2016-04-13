define(function() {
  var init = function (canvasID) {
    var canvasDraw = {};
    canvasDraw.canvas = document.getElementById(canvasID);
    canvasDraw.context = canvasDraw.canvas.getContext("2d");
    canvasDraw.drawStrokedClosedPath = function (points, rect) {
      canvasDraw.context.lineWidth = 1;
      var x = rect[0];
      var y = rect[1];
      var width = rect[2];
      var height = rect[3];
      

      var previousPoint = null;
      var nextPreviousPoint = null;
      for (var key in points) {
        if (nextPreviousPoint) {
          previousPoint = nextPreviousPoint;
          nextPreviousPoint = null;
        }
        var curvePoint = points[key]
        nextPreviousPoint = curvePoint;
        var point = curvePoint.point
        var pointX = point.x;
        var pointY = point.y;
        pointX = x + (width * pointX);
        pointY = y + (height * pointY);

        if (!previousPoint) {
          canvasDraw.context.moveTo(x, y);
          canvasDraw.context.beginPath();
          continue;
        }

        if (typeof curvePoint.curveMode == 'undefined') {
          canvasDraw.context.lineTo(pointX, pointY);
          continue;
        }

        if (curvePoint.curveMode == 1) {
          canvasDraw.context.lineTo(pointX, pointY);
          continue;
        }

        var curveFrom = {x: curvePoint.curveFrom.x, y: curvePoint.curveFrom.y};
        curveFrom.x = x + (width * curveFrom.x);
        curveFrom.y = y + (height * curveFrom.y);


        var curveTo = {x: curvePoint.curveTo.x, y: curvePoint.curveTo.y};
        curveTo.x = x + (width * curveTo.x);
        curveTo.y = y + (height * curveTo.y);


        var previousX = x + (previousPoint.point.x * width);
        var previousY = y + (previousPoint.point.y * height);
        var controlPoint1x = x + (previousPoint.curveFrom.x * width);
        var controlPoint1y = y + (previousPoint.curveFrom.y * height);
        var controlPoint2x = curveTo.x;
        var controlPoint2y = curveTo.y;

        if (curvePoint.curveMode == 1) {
          controlPoint2x = pointX;
          controlPoint2y = pointY;
        }

        if (previousPoint.curveMode == 1) {
          controlPoint1x = previousX;
          controlPoint1y = previousY;
        }
        else {
          // console.log("previous X!:", previousX);
            // controlPoint1x = previousX;
            // controlPoint1y = previousY;
        }

        // canvasDraw.context.fillStyle = 'red';
        // context.fillRect(controlPoint1x, controlPoint1y, 10, 10);
        // canvasDraw.context.fillStyle = 'blue';
        // context.fillRect(controlPoint2x, controlPoint2y, 10, 10);

        // context.bezierCurveTo(curveFrom.x, curveFrom.y,
        //                       curveTo.x, curveTo.y,
        //                       pointX, pointY);
        canvasDraw.context.bezierCurveTo(controlPoint1x, controlPoint1y,
                          controlPoint2x, controlPoint2y,
                          pointX, pointY);

        // console.log("point: x:", pointX, "y:", pointY,
        //             "cp1x:", controlPoint1x,
        //             "cp2y:", controlPoint1y,
        //             "cp2x:", controlPoint2x,
        //             "cp2y:", controlPoint2y
        //            );
      }
      // close
      // context.lineTo(x, y);
      canvasDraw.context.closePath();
      canvasDraw.context.stroke();

    }
    canvasDraw.clear = function () {
      this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
    }

    canvasDraw.drawCentroid = function (centroid, rect) {
      var originX = rect[0];
      var originY = rect[1];
      var width = rect[2];
      var height = rect[3];

      this.context.fillStyle = 'green';
      var x = originX + (width  * centroid.x);
      var y = originY + (height * centroid.y);

      var centroidWidth = 2;
      var centroidHeight = 2;
      x = x - (centroidWidth / 2);
      y = y - (centroidHeight / 2);

      this.context.fillRect(x, y, centroidWidth, centroidHeight);
    }

    return canvasDraw;
  };


  return init;
});
