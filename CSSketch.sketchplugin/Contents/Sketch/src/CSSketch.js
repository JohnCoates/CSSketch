var CSSketchContext = null;

var layoutLayers = function(context) {
  CSSketchContext = context;

  if (loadCSSketchAsNeeded()) {
    var mainController = CSKMainController.sharedInstance();
    mainController.layoutLayersWithContext(context);
  }
}

var setPageStylesheet = function(context) {
  CSSketchContext = context;

  if (loadCSSketchAsNeeded()) {
    var mainController = CSKMainController.sharedInstance();
    mainController.selectStylesheetWithContext(context);
  }
}

function loadCSSketchAsNeeded() {
  if (!NSClassFromString("CSKFileMonitor")){
    if (!loadBundle("CSSketch Helper.bundle")) {
      log("Couldn't load bundle!");
      return false;
    }
  }

  return true;
}

function loadBundle(filename) {
  var pluginURL = pluginPathURL();
  var bundleURL = pluginURL.URLByAppendingPathComponent(filename);
  var bundle = [NSBundle bundleWithURL: bundleURL];
	if (!bundle) {
		showNotification("Bundle missing!");
		return false;
	}

	var loaded = [bundle load];
	if (!loaded) {
		showNotification("Couldn't load CSSketch bundle! Try allowing apps downloaded from anywhere (System Preferences -> Security & Privacy)");
    return false;
	}

	return loaded;
}

function pluginPathURL() {
  return CSSketchContext.plugin.url();
}

function showNotification(message) {
  // NSUserNotification only shows if app is active
  var notification =  [[NSUserNotification alloc] init];
  notification.title = @"CSSketch";
  notification.informativeText = message;
  notification.soundName = NSUserNotificationDefaultSoundName;
  [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];

  // displayMessage only shows if app is active
  CSSketchContext.document.displayMessage("CSSketch: "+ message);
}
