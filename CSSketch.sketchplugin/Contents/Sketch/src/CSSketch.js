var CSSketchContext = null;

var layoutLayers = function(context) {
  CSSketchContext = context;
  loadCSSketchAsNeeded();

  var mainController = CSKMainController.sharedInstance();
  mainController.layoutLayersWithContext(context);
}

var setPageStylesheet = function(context) {
  CSSketchContext = context;
  loadCSSketchAsNeeded();

  var mainController = CSKMainController.sharedInstance();
  mainController.selectStylesheetWithContext(context);
}

function loadCSSketchAsNeeded() {
  if (!NSClassFromString("CSKFileMonitor")){
    loadBundle("CSSketch Helper.bundle");
  }
}

function loadBundle(filename) {
  var pluginURL = pluginPathURL();
	var bundleURL = pluginURL.URLByAppendingPathComponent(filename);
  var bundle = [NSBundle bundleWithURL: bundleURL];
  [bundle load];
}

function pluginPathURL() {
  return CSSketchContext.plugin.url();
}
