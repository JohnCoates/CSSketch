define(function() {
  var init = function (canvasID) {
    var canvasDraw = {};
    canvasDraw.canvas = document.getElementById(canvasID);
    canvasDraw.context = canvasDraw.canvas.getContext("2d");
    canvasDraw.drawStrokedClosedPath = function (pathEntries, rect) {
      canvasDraw.context.lineWidth = 1;
      rect = { x: rect[0], y: rect[1], width: rect[2], height: rect[3]};
      var scale = rect.width;

      // translate point to screen pixel
      var screenX = function (x) {
        return rect.x + (scale * x);
      }

      var screenY = function (y) {
        return rect.y + (scale * y);
      }

      var length = pathEntries.length;
      for (var key = 0; key < length; key++) {
        var entry = pathEntries[key]
        var point = entry.point

        if (key == 0) {
          this.context.moveTo(screenX(point.x), screenY(point.y));
          this.context.beginPath();
          continue;
        }
        var previousEntry = pathEntries[key - 1];

        if (typeof entry.controlPoint1 != 'undefined') {
          this.context.bezierCurveTo(
                            screenX(entry.controlPoint1.x), screenY(entry.controlPoint1.y),
                            screenX(entry.controlPoint2.x), screenY(entry.controlPoint2.y),
                            screenX(point.x), screenY(point.y));
          continue;
        }

        if (typeof entry.curveMode == 'undefined') {
          this.context.lineTo(screenX(point.x), screenY(point.y));
          continue;
        }

        var curveFrom = entry.curveFrom;
        var curveTo = entry.curveTo;
        var previousPoint = previousEntry.point;

        var controlPoint1 = { x: previousEntry.curveFrom.x, y: previousEntry.curveFrom.y };
        var controlPoint2 = { x: curveTo.x, y: curveTo.y };

        if (entry.curveMode == 1) {
          controlPoint2.x = point.x;
          controlPoint2.y = point.y;
        }

        if (previousEntry.curveMode == 1) {
          controlPoint1.x = previousPoint.x;
          controlPoint1.y = previousPoint.y;
        }
        // canvasDraw.context.fillStyle = 'blue';
        // this.context.fillRect(screenX(controlPoint2x), screenY(controlPoint2y), 4, 4);

        this.context.bezierCurveTo(screenX(controlPoint1.x), screenY(controlPoint1.y),
                          screenX(controlPoint2.x), screenY(controlPoint2.y),
                          screenX(point.x), screenY(point.y));
      }

      this.context.closePath();
      this.context.stroke();
    }

    canvasDraw.clear = function () {
      this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
    }

    canvasDraw.drawCentroid = function (centroid, rect) {
      var originX = rect[0];
      var originY = rect[1];
      var width = rect[2];
      var height = rect[3];
      var scale = width;

      this.context.fillStyle = 'green';
      var x = originX + (scale * centroid.x);
      var y = originY + (scale * centroid.y);

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
