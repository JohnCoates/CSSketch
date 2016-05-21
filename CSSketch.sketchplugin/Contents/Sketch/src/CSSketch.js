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
var pluginsPath = @"~/Library/Application Support/com.bohemiancoding.sketch3/Plugins";
  pluginsPath = [pluginsPath stringByExpandingTildeInPath];
  // Load CSSketch
  if (!NSClassFromString("CSKMainController")) {
    var pluginFolder = [pluginsPath stringByAppendingPathComponent:"CSSKetch.sketchplugin"];
    var bundlePath = [pluginFolder stringByAppendingPathComponent:"CSSketch Helper.bundle"];

    var error = null;
    if (!loadBundle(bundlePath)) {
      return false
    }
  }
  return true;
}

function loadBundle(filePath) {
  var bundleURL = NSURL.fileURLWithPath(filePath);
  var bundle = [NSBundle bundleWithURL: bundleURL];
  if (bundle == null) {
    showNotification("CSSketch bundle missing from " + filePath);
    return false;
  }

  var loaded = [bundle load];

  if (!loaded) {
		showNotification("Couldn't load CSSketch bundle! Try allowing apps downloaded from anywhere (System Preferences -> Security & Privacy)");
  }
  return loaded;
}

function showNotification(message) {
  // NSUserNotification only shows if app is in-active
  var notification =  [[NSUserNotification alloc] init];
  notification.title = @"CSSketch";
  notification.informativeText = message;
  notification.soundName = NSUserNotificationDefaultSoundName;
  [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];

  // displayMessage only shows if app is active
  CSSketchContext.document.displayMessage("CSSketch: "+ message);
}
