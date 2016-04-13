define(function() {
  var init = function (canvasID) {
    var canvasDraw = {};
    canvasDraw.canvas = document.getElementById(canvasID);
    canvasDraw.context = canvasDraw.canvas.getContext("2d");
    canvasDraw.drawStrokedClosedPath = function (points, rect) {
      canvasDraw.context.lineWidth = 1;
      var originX = rect[0];
      var originY = rect[1];
      var width = rect[2];
      var height = rect[3];

      var screenX = function (x) {
        return originX + (width * x);
      }

      var screenY = function (y) {
        return originY + (height * y);
      }

      var calculatedEntries = [];
      var length = points.length;
      for (var key = 0; key < length; key++) {

        var curvePoint = points[key]
        var point = curvePoint.point
        var pointX = point.x;
        var pointY = point.y;

        if (key == 0) {
          canvasDraw.context.moveTo(screenX(pointX), screenY(pointY));
          canvasDraw.context.beginPath();
          calculatedEntries.push(curvePoint);
          continue;
        }
        var previousPoint = points[key - 1];

        canvasDraw.context.fillStyle = 'green';
        this.context.fillRect(screenX(previousPoint.point.x), screenY(previousPoint.point.y), 3, 3);
        if (typeof curvePoint.controlPoint1 != 'undefined') {
          // console.log("curve point: ", curvePoint);
          // console.log("drawing pre-calculated curve #" + key, curvePoint.point);

          canvasDraw.context.fillStyle = 'red';
          this.context.fillRect(screenX(curvePoint.controlPoint1.x), screenY(curvePoint.controlPoint1.y), 4, 4);
          canvasDraw.context.fillStyle = 'blue';
          this.context.fillRect(screenX(curvePoint.controlPoint2.x), screenY(curvePoint.controlPoint2.y), 4, 4);

          canvasDraw.context.bezierCurveTo(
                            screenX(curvePoint.controlPoint1.x), screenY(curvePoint.controlPoint1.y),
                            screenX(curvePoint.controlPoint2.x), screenY(curvePoint.controlPoint2.y),
                            screenX(pointX), screenY(pointY));
                            // console.log("point x:", screenX(pointX));
          continue;
        }

        if (typeof curvePoint.curveMode == 'undefined') {
          canvasDraw.context.lineTo(screenX(pointX), screenY(pointY));
          continue;
        }

        // if (curvePoint.curveMode == 1) {
        //   canvasDraw.context.lineTo(screenX(pointX), screenY(pointY));
        //   continue;
        // }

        var curveFrom = curvePoint.curveFrom;
        var curveTo = curvePoint.curveTo;

        var previousX = previousPoint.point.x;
        var previousY = previousPoint.point.y;

        var controlPoint1x = previousPoint.curveFrom.x;
        var controlPoint1y = previousPoint.curveFrom.y;
        var controlPoint2x = curveTo.x;
        var controlPoint2y = curveTo.y;

        if (curvePoint.curveMode == 1) {
          console.log("curve mode 1");
          controlPoint2x = pointX;
          controlPoint2y = pointY;
        }

        if (previousPoint.curveMode == 1) {
          console.log("curve mode 1");
          controlPoint1x = previousX;
          controlPoint1y = previousY;
        }

        canvasDraw.context.fillStyle = 'red';
        this.context.fillRect(screenX(controlPoint1x), screenY(controlPoint1y), 4, 4);
        canvasDraw.context.fillStyle = 'blue';
        this.context.fillRect(screenX(controlPoint2x), screenY(controlPoint2y), 4, 4);

        // context.bezierCurveTo(curveFrom.x, curveFrom.y,
        //                       curveTo.x, curveTo.y,
        //                       pointX, pointY);
        canvasDraw.context.bezierCurveTo(screenX(controlPoint1x), screenY(controlPoint1y),
                          screenX(controlPoint2x), screenY(controlPoint2y),
                          screenX(pointX), screenY(pointY));

        var calculatedEntry = {point: point};
        calculatedEntry.controlPoint1 = {x: controlPoint1x, y: controlPoint1y};
        calculatedEntry.controlPoint2 = {x: controlPoint2x, y: controlPoint2y};
        calculatedEntries.push(calculatedEntry);
        // console.log("drawing bezier #" + key, pointX, pointY);
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
      return calculatedEntries;
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
