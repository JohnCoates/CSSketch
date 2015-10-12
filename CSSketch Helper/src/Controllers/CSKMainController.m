//
//  CSKMainController.m
//  CSSketch Helper
//
//  Created by John Coates on 10/5/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import "CSKMainController.h"
#import "CSKToolbarProxy.h"

static BOOL DEBUG_WriteOutLayerTree = FALSE;

static NSString * const kCSKPluginIdentifier = @"sketchCSSPlugin";
static NSString * const kCSKStylesheetURLKey = @"sketchCSS-StylesheetURL";
static NSString * const kCSKStylesheetRelativeURLKey = @"sketchCSS-StylesheetRelativeURL";
static NSString * const kCSKStylesheetBookmarkKey = @"sketchCSS-StylesheetBookmark";

@interface CSKMainController ()

@property (strong) CSKStylesheet *stylesheetController;
@property (strong) NSArray *toolbarProxies;
@property (weak) CSK_MSDocument *document;
@property (strong) CSK_MSPluginCommand *pluginCommand;
@property (strong) NSArray *domModels;
@property (strong) NSString *documentStylesheetRules;
@property (strong) NSArray *fileMonitors;

@end

@implementation CSKMainController

+ (instancetype)sharedInstance {
    static CSKMainController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [CSKMainController new];
        
        if (NSClassFromString(@"MSLayer")) {
            sharedInstance.inSketch = TRUE;
        }
        else {
            sharedInstance.inSketch = FALSE;
        }
        
        if ([sharedInstance inSketch]) {
            if (DEBUG){
                // redirect log output to file
                [sharedInstance redirectConsoleLogToDocumentFolder];
            }
        }
        
    });
    
    return sharedInstance;
}
- (void)redirectConsoleLogToDocumentFolder {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"sketch.log"];
    freopen([logPath fileSystemRepresentation],"a+",stderr);

}

- (instancetype)init {
    self = [super init];
    
    return self;
}

- (void)addToolbarAsRequired:(NSDictionary *)context {
    CSK_MSPluginCommand *command = context[@"command"];
    CSK_MSDocument *document = context[@"document"];
    
    NSWindow *documentWindow = document.documentWindow;
    
    for (CSKToolbarProxy *proxy in  self.toolbarProxies) {
        // skip adding toolbar if it's already been added
        if (proxy.window == documentWindow) {
            return;
        }
    }
    
    NSToolbar *toolbar = documentWindow.toolbar;
    CSKToolbarProxy *toolbarProxy = [[CSKToolbarProxy alloc] initWithOriginalToolbarDelegate:toolbar.delegate];
    toolbarProxy.document = document;
    toolbarProxy.command = command;
    toolbarProxy.window = documentWindow;
    toolbar.delegate = toolbarProxy;
    
    // add toolbar item at the end
    NSMutableArray *toolbarProxies = [self.toolbarProxies mutableCopy];
    
    if (!toolbarProxies) {
        toolbarProxies = [NSMutableArray array];
    }
    
    [toolbarProxies addObject:toolbarProxy];
    self.toolbarProxies = toolbarProxies;
    
    [toolbar insertItemWithItemIdentifier:@"CSSketch"
                                  atIndex:toolbar.visibleItems.count - 1];
}

- (void)refreshDocument {
    [self.document.currentView refresh];
}

- (void)layoutLayersWithContext:(NSDictionary *)context {
    self.domModels = [NSArray array];
    
    if (DEBUG) {
        NSLog(@"context (%@): %@", NSStringFromClass([context class]), context);
    }
    CSK_MSPluginCommand *command = context[@"command"];
    CSK_MSDocument *document = context[@"document"];
    CSK_MSPage *page = document.currentPage;
    self.document = document;
    self.pluginCommand = command;
    
    // add toolbar icon on UI Thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addToolbarAsRequired:context];

    });
    
    NSURL *stylesheetURL = [CSKMainController stylesheetURLForPage:page
                                                     pluginCommand:command];
    
    if (!stylesheetURL) {
        // No URL, select stylesheet!
        [self selectStylesheetWithContext:context];
        
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:stylesheetURL.path]) {
        NSLog(@"error: stylesheet file %@ doesn't exist", stylesheetURL);
        return;
    }
    
    if (DEBUG) {
        NSLog(@"stylesheet: %@", stylesheetURL);
    }
    
    self.documentStylesheetRules = @"\n";
    
    NSDictionary *layerTree = [self layerTreeFromLayer:page];
    if (DEBUG_WriteOutLayerTree) {
        [self saveDebugTree:layerTree];
    }
    
    if (DEBUG) {
        NSLog(@"layer tree: %@", layerTree);
    }

    self.stylesheetController = [[CSKStylesheet alloc] initWithFile:stylesheetURL];
    [self.stylesheetController parseStylesheet:^(NSError *error, NSString *compiledStylesheet) {
        // Call WebKit on UI thread
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // add stylesheet rules
            // prior so their precedence is worst
            NSString *mergedStylesheet = [self.documentStylesheetRules stringByAppendingString:compiledStylesheet];
            
            CSKDOM *domModel = [[CSKDOM alloc] initWithStylesheet:mergedStylesheet callback:^(NSError *error, NSDictionary *DOMTree) {
                
                if (DEBUG) {
                    NSLog(@"computed dom: %@", DOMTree);
                }
                
                if (error) {
                    NSLog(@"error: %@", error);
                    return;
                }
                else {
                    [[CSKMainController sharedInstance] layoutLayersWithDOMTree:DOMTree];
                    [[CSKMainController sharedInstance] refreshDocument];
                }
                
                // remove DOM from array
                NSMutableArray *models = [self.domModels mutableCopy];
                [models removeObject:domModel];
                self.domModels = models;
                
            } layerTree:layerTree];
            
            // add dom model to array
            NSMutableArray *models = [self.domModels mutableCopy];
            [models addObject:domModel];
            self.domModels = models;
            
        });
    }];
    
    
}

- (void)saveDebugTree:(NSDictionary *)layerTree {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        NSDictionary *saveableTree = [self saveableTree:layerTree];
        
        BOOL wrote = [saveableTree writeToFile:@"/Users/macbook/Dev/Extensions/Sketch/Sketch-CSS/debug.plist"
                                 atomically:TRUE];
        if (DEBUG) {
            NSLog(@"wrote to file: %d", wrote);
        }
    });
}

- (NSDictionary *)saveableTree:(NSDictionary *)tree {
    NSMutableDictionary *leaf = [tree mutableCopy];
    
    // remove layer so we can serialize this tree
    [leaf removeObjectForKey:@"layer"];
    
    NSMutableArray *children = [NSMutableArray new];
    
    for (NSDictionary *child in leaf[@"children"]) {
        [children addObject:[self saveableTree:child]];
    }
    
    // replace children with saveable children
    leaf[@"children"] = children;
    
    return leaf;
}

- (NSDictionary *)layerTreeFromLayer:(CSK_MSLayer *)layer {
    NSMutableDictionary *leaf = [NSMutableDictionary new];
    
    NSString *name = layer.name;
    
    if (!DEBUG_WriteOutLayerTree) {
        leaf[@"layer"] = layer;
    }
    
    leaf[@"name"] = name;
    leaf[@"objectID"] = layer.objectID;
    
    NSNumber *left =@(layer.rect.origin.x);
    NSNumber *top = @(layer.rect.origin.y);
    if (MSLayerIsArtboard(layer)) {
        left = @(0);
        top = @(0);
    }
    
    if (!MSLayerIsPage(layer))
    {
        NSNumber *width = @(layer.rect.size.width);
        NSNumber *height = @(layer.rect.size.height);
        
        // add size rule
        NSString *styleSheetRule;
        styleSheetRule = [NSString stringWithFormat:@"[objectID=\"%@\"] {\nposition:absolute; left:%@; top:%@; width: %@px; height: %@px;\n}\n",
                          layer.objectID,
                          left, top,
                          width,
                          height];
        
        self.documentStylesheetRules = [self.documentStylesheetRules
                                        stringByAppendingString:styleSheetRule];
    }
    
    if (MSLayerIsGroup(layer)) {
        NSMutableArray *childrenList;
        childrenList = [NSMutableArray new];
        
        NSArray *children = layer.layers;
        
        for (CSK_MSLayer *childLayer in children) {
            NSDictionary *childTree = [self layerTreeFromLayer:childLayer];
            
            if (childTree) {
                [childrenList addObject:childTree];
            }
        }
        
        // reverse order so it's correctly ordered
        leaf[@"children"] = childrenList.reverseObjectEnumerator.allObjects;
    }
    
    return leaf;
}

- (void)layoutLayersWithDOMTree:(NSDictionary *)DOMTree {
    if (![self inSketch]) {
        [self walkDOMTree:DOMTree];
        return;
    }
    
//    NSNumber *CSSOptIn = DOMTree[@"CSSOptIn"];
    
    BOOL hasChildren = FALSE;
    NSArray *children = DOMTree[@"children"];
    
    if (children && children.count) {
        hasChildren = TRUE;
    }
    
    CSK_MSLayer *layer = DOMTree[@"layer"];
    
    // check to see if object should have size & position set
    if (!hasChildren) {
        if (DEBUG) {
            NSLog(@"setting CSS for %@", DOMTree[@"name"]);
        }
    
        // layout
        [CSKLayerCSS handleFrameWithDOMLeaf:DOMTree layer:layer];
        
        // border
        [CSKLayerCSS handleBorderWithDOMLeaf:DOMTree layer:layer];
        
        // shadow
        [CSKLayerCSS handleShadowWithDOMLeaf:DOMTree layer:layer];
        
        // background color
        [CSKLayerCSS handleBackgroundColorWithDOMLeaf:DOMTree layer:layer];
        
        // opacity

    }
    
    
    if (hasChildren) {
        for (NSDictionary *child in children) {
            [self layoutLayersWithDOMTree:child];
        }
        
        // reset group ounds
        if ([layer isKindOfClass:NSClassFromString(@"MSLayerGroup")]) {
            [layer resizeRoot:true];
        }
    }
}



#pragma mark - Debugging

- (void)walkDOMTree:(NSDictionary *)DOMTree {
    NSNumber *CSSOptIn = DOMTree[@"CSSOptIn"];
    
    BOOL hasChildren = FALSE;
    NSArray *children = DOMTree[@"children"];
    
    if (children && children.count) {
        hasChildren = TRUE;
    }
    
    
    // check to see if object should have size & position set
    if (CSSOptIn && !hasChildren) {

    }
    if (DEBUG) {
        NSLog(@"setting CSS for %@", DOMTree[@"name"]);
    }
//    [self handleShadowWithDOMTree:DOMTree layer:nil];
    
    
    if (hasChildren) {
        
        for (NSDictionary *child in children) {
            [self walkDOMTree:child];
        }
    }
}


#pragma mark - Plugin Entrypoints


- (void)selectStylesheetWithContext:(NSDictionary *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        CSK_MSDocument *document = context[@"document"];
        CSK_MSPage *page = document.currentPage;
        CSK_MSPluginCommand *command = context[@"command"];
        
        NSOpenPanel *openPanel = [NSOpenPanel openPanel];
        
        openPanel.canChooseDirectories = false;
        openPanel.canChooseFiles = true;
        openPanel.canCreateDirectories = true;
        openPanel.allowsMultipleSelection = false;
        openPanel.title = @"Choose a stylesheet for this page";
        openPanel.prompt = @"Choose";
        
        // open panel should show Sketch document's folder
        openPanel.directoryURL = [document.fileURL URLByDeletingLastPathComponent];
        
        [openPanel beginWithCompletionHandler:^(NSInteger result) {
            
            if (result == NSFileHandlingPanelOKButton) {
                NSURL *fileURL = openPanel.URLs[0];
                
                // save file URL
                [CSKMainController setStylesheetURL:fileURL
                                            forPage:page
                                      pluginCommand:command];
                
                // layout
                [self layoutLayersWithContext:context];
            }
            
        }];
    });
    
    
}

#pragma mark - Stylesheet Resolving

+ (NSURL *)stylesheetURLForPage:(CSK_MSPage *)page
                  pluginCommand:(CSK_MSPluginCommand *)pluginCommand {

    NSURL *stylesheetURL = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([CSKMainController inSandbox]) {
        
        NSString *bookmarkString = [pluginCommand valueForKey:kCSKStylesheetBookmarkKey
                                              onLayer:page
                                  forPluginIdentifier:kCSKPluginIdentifier];
        
        if (!bookmarkString) {
            NSLog(@"no bookmark found");
            
            return nil;
        }
        
        NSData *bookmark = [[NSData alloc] initWithBase64EncodedString:bookmarkString
                                                               options:0];
        
        NSError *error;
        stylesheetURL = [NSURL URLByResolvingBookmarkData:bookmark
                                                  options:NSURLBookmarkResolutionWithSecurityScope
                                            relativeToURL:nil
                                      bookmarkDataIsStale:NULL
                                                    error:&error];
        
        if (error) {
            NSLog(@"couldn't resolve file bookmark, error: %@", error);
            [self displayError:@"Stylesheet missing, please select another one."];
        }
        else {
            // set a file monitor
            [[self sharedInstance] addFileMonitorAsRequiredForCurrentPageWithFileURL:stylesheetURL bookmark:bookmark];
        }
    }
    else {
        NSString *stylesheetPath = [pluginCommand valueForKey:kCSKStylesheetURLKey
                                           onLayer:page
                               forPluginIdentifier:kCSKPluginIdentifier];
        if (!stylesheetPath) {
            return nil;
        }
        // try relative path first
        NSString *stylesheetRelativePath = [pluginCommand valueForKey:kCSKStylesheetRelativeURLKey
                                                              onLayer:page
                                                  forPluginIdentifier:kCSKPluginIdentifier];
        
        CSK_MSDocument *document = [CSKMainController sharedInstance].document;
        NSString *documentPath = document.fileURL.path;
        
        NSString *resolvedRelativePath = [[documentPath stringByAppendingPathComponent:stylesheetRelativePath] stringByStandardizingPath];

        if ([fileManager fileExistsAtPath:resolvedRelativePath] ) {
            stylesheetURL = [NSURL fileURLWithPath:resolvedRelativePath];
        }
        else {
            // try absolute path
            if ([fileManager fileExistsAtPath:stylesheetPath]) {
                stylesheetURL = [NSURL fileURLWithPath:stylesheetPath];
            }
            
        }
        
        if (stylesheetURL) {
            // set a file monitor
            [[self sharedInstance] addFileMonitorAsRequiredForCurrentPageWithFileURL:stylesheetURL bookmark:nil];
        }
    }
    
    return stylesheetURL;
}

+ (void)setStylesheetURL:(NSURL *)stylesheetURL
                 forPage:(CSK_MSPage *)page
           pluginCommand:(CSK_MSPluginCommand *)pluginCommand {
    
     if ([CSKMainController inSandbox]) {
         NSData *bookmarkData;
         
         NSError *error = nil;
         NSURLBookmarkCreationOptions bookmarkOptions = 0;
         bookmarkOptions = NSURLBookmarkCreationWithSecurityScope;
         bookmarkData = [stylesheetURL bookmarkDataWithOptions:bookmarkOptions
                            includingResourceValuesForKeys:nil relativeToURL:nil error:&error];
         if (error) {
             NSLog(@"error creating bookmark! %@", error);
             [self displayError:@"Couldn't resolve stylesheet bookmark!"];
             return;
         }
         
         NSString *bookmarkString = [bookmarkData base64EncodedStringWithOptions:0];
         
         [pluginCommand setValue:bookmarkString
                          forKey:kCSKStylesheetBookmarkKey
                         onLayer:page
             forPluginIdentifier:kCSKPluginIdentifier];

     }
     else {
         NSString *stylesheetRelativePath;
         CSK_MSDocument *document = [CSKMainController sharedInstance].document;
         NSString *documentPath = document.fileURL.path;
         stylesheetRelativePath = [stylesheetURL.path stringWithPathRelativeTo:documentPath];
         
         // save relative file path
         [pluginCommand setValue:stylesheetURL.path
                          forKey:kCSKStylesheetURLKey
                         onLayer:page
             forPluginIdentifier:kCSKPluginIdentifier];
         
         // save full file path
         [pluginCommand setValue:stylesheetRelativePath
                          forKey:kCSKStylesheetRelativeURLKey
                         onLayer:page
             forPluginIdentifier:kCSKPluginIdentifier];
     }
}


#pragma mark - File Monitoring

- (void)addFileMonitorAsRequiredForCurrentPageWithFileURL:(NSURL *)fileURL bookmark:(NSData *)bookmark {
    CSK_MSPluginCommand *command = self.pluginCommand;
    CSK_MSDocument *document = self.document;
    
    // check if one exists
    if ([self existingFileMonitorForPage:document.currentPage]) {
        return;
    }
    
    NSMutableArray *fileMonitors = self.fileMonitors.mutableCopy;
    
    if (!fileMonitors) {
        fileMonitors = [NSMutableArray array];
    }
    
    CSKFileMonitor *fileMonitor = [[CSKFileMonitor alloc] initWithFileURL:fileURL bookmark:bookmark];
    fileMonitor.document = document;
    fileMonitor.page = document.currentPage;
    fileMonitor.command = command;
    [fileMonitor setChangeBlock:^(CSKFileMonitor *fileMonitor) {
        
        // don't do anything if we're on another page
        if (fileMonitor.page != fileMonitor.document.currentPage) {
            return;
        }
        
        if (DEBUG) {
            NSLog(@"file modified, issuing new layout!");
        }
        NSDictionary *context = @{@"command" : fileMonitor.command, @"document" : fileMonitor.document};
        
        [self layoutLayersWithContext:context];
    }];
    
    [fileMonitor startMonitoring];
    
    [fileMonitors addObject:fileMonitor];
    self.fileMonitors = fileMonitors;
}

- (CSKFileMonitor *)existingFileMonitorForPage:(CSK_MSPage *)page {
    NSArray *fileMonitors = self.fileMonitors;
    
    for (CSKFileMonitor *fileMonitor in fileMonitors) {
        if (fileMonitor.page == page) {
            return fileMonitor;
        }
    }
    
    return nil;
}


#pragma mark - Operating In Unknown Territory

+ (BOOL)inSketch {
    static dispatch_once_t onceToken;
    static BOOL inSketch = FALSE;
    dispatch_once(&onceToken, ^{
        if (NSClassFromString(@"MSLayer")) {
            inSketch = TRUE;
        }
    });
    
    return inSketch;
}

+ (BOOL)inSandbox {
    static dispatch_once_t onceToken;
    static BOOL inSandbox = FALSE;
    dispatch_once(&onceToken, ^{
        NSDictionary* environment = [NSProcessInfo processInfo].environment;
        inSandbox = (nil != environment[@"APP_SANDBOX_CONTAINER_ID"]);
    });
    
    return inSandbox;
}

+ (NSBundle *)pluginBundle {
    static dispatch_once_t onceToken;
    static NSBundle *pluginBundle;
    dispatch_once(&onceToken, ^{
        pluginBundle = [NSBundle bundleForClass:[self class]];
    });
    
    
    return pluginBundle;
}

+ (void)displayError:(NSString *)error {
    [[CSKMainController sharedInstance].document displayMessage:error];
}

- (NSString *)embeddedStylesheet {
    if (_embeddedStylesheet) {
        return _embeddedStylesheet;
    }
    NSString *stylesheetPath = [[self.class pluginBundle] pathForResource:@"embedded" ofType:@"css"];
    NSError *error = nil;
    _embeddedStylesheet = [NSString stringWithContentsOfFile:stylesheetPath encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"CSSketch Error: Couldn't read embedded stylesheet from: %@ - %@", stylesheetPath, error);
        [self.class displayError:@"Couldn't read embedded stylesheet!"];
    }
    
    return _embeddedStylesheet;
}

@end
