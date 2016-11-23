//
//  CSKMainController.m
//  CSSketch Helper
//
//  Created by John Coates on 10/5/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import "CSKMainController.h"
#import "CSKToolbarProxy.h"
#import <objc/runtime.h>

static NSString * const kCSKPluginIdentifier = @"sketchCSSPlugin";
static NSString * const kCSKStylesheetURLKey = @"sketchCSS-StylesheetURL";
static NSString * const kCSKStylesheetRelativeURLKey = @"sketchCSS-StylesheetRelativeURL";
static NSString * const kCSKStylesheetBookmarkKey = @"sketchCSS-StylesheetBookmark";
static const char * kCSKDocumentControllerAssociatedObjectKey = "kCSKDocumentControllerAssociatedObjectKey";

@interface CSKMainController ()

@property (strong) CSKStylesheet *stylesheetController;
@property (strong) NSArray *toolbarProxies;
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
    NSDictionary *copyContext = [context mutableCopy];
    CSK_MSPluginCommand *command = copyContext[@"command"];
    CSK_MSDocument *document = copyContext[@"document"];
    
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
    
    if (toolbar.visibleItems.count > 0) {
        [toolbar insertItemWithItemIdentifier:@"CSSketch"
                                      atIndex:toolbar.visibleItems.count - 1];
//        [toolbar insertItemWithItemIdentifier:@"CSSketch-SVG"
//                                      atIndex:toolbar.visibleItems.count - 1];
    }
}

- (void)refreshDocument {
    
    if ([self.document.currentView respondsToSelector:@selector(refresh)]) {
        [self.document.currentView refresh];
    }
    else if([self.document.currentView respondsToSelector:@selector(refreshTiles)]) {
        [self.document.currentView refreshTiles];
    }
    else if([self.document.currentView respondsToSelector:@selector(refreshOverlayOfViews)]) {
        [self.document.currentView refreshOverlayOfViews];
    }
    else {
        NSLog(@"Error: Can't refresh current view, missing refresh method!");
    }
    
    [self.document reloadInspector];
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
    NSDictionary *copyContext = [context mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        CSK_MSDocument *document = copyContext[@"document"];
        CSK_MSPage *page = document.currentPage;
        CSK_MSPluginCommand *command = copyContext[@"command"];
        
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
                [self layoutLayersWithContext:copyContext];
            }
            
        }]; // Open Panel file callback
    }); // async dispatch
}

- (void)layoutLayersWithContext:(NSDictionary *)context {
    NSDictionary *copyContext = [context mutableCopy];
    self.domModels = [NSArray array];
    
    if (DEBUG) {
        NSLog(@"context (%@): %@", NSStringFromClass([copyContext class]), copyContext);
    }
    CSK_MSPluginCommand *command = copyContext[@"command"];
    CSK_MSDocument *document = copyContext[@"document"];
    CSK_MSPage *page = document.currentPage;
    self.document = document;
    self.pluginCommand = command;
    
    // add toolbar icon on UI Thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addToolbarAsRequired:copyContext];
        
    });
    
    NSURL *stylesheetURL = [CSKMainController stylesheetURLForPage:page
                                                     pluginCommand:command];
    
    if (!stylesheetURL) {
        // No URL, select stylesheet!
        [self selectStylesheetWithContext:copyContext];
        
        return;
    }
    
    if (DEBUG) {
        NSLog(@"stylesheet: %@", stylesheetURL);
    }
    
    
    CSKDocumentController *documentController;
    documentController = [self documentControllerForDocument:document];
    
    if (!documentController) {
        [self.class displayError:@"Couldn't get document controller!"];
        return;
    }
    
    [documentController layoutCurrentPageWithStylesheetURL:stylesheetURL];
}

#pragma mark - Document Controllers

- (CSKDocumentController *)documentControllerForDocument:(CSK_MSDocument *)document {
    
    CSKDocumentController *documentController;
    
    // try for associated object first
    documentController = objc_getAssociatedObject(document, kCSKDocumentControllerAssociatedObjectKey);
    
    if (documentController) {
        return documentController;
    }
    
    documentController = [[CSKDocumentController alloc] initWithDocument:document];
    
    // associate controller with document
    objc_setAssociatedObject(document,
                             kCSKDocumentControllerAssociatedObjectKey,
                             documentController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return documentController;
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
        if (DEBUG) {
            NSLog(@"page: %@, document: %@", fileMonitor.page, fileMonitor.document);
        }
        
        // remove file monitor if page doesn't exist anymore
        if (fileMonitor.page == nil || fileMonitor.document == nil || fileMonitor.command == nil) {
            
            if (DEBUG) {
                NSLog(@"removing filemonitors from: %@", self.fileMonitors);
            }
            NSMutableArray *newFileMonitors = self.fileMonitors.mutableCopy;
            [newFileMonitors removeObject:fileMonitor];
            self.fileMonitors = newFileMonitors;
            
            return;
        }
        
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
    // avoid warning about performing UI op from background thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self displayErrorFromMainThread:error];
    });
}
+ (void)displayErrorFromMainThread:(NSString *)error {
    NSString *prefixedMessage = [@"CSSketch: " stringByAppendingString:error];
    
    // message only shows if app is active
    [[CSKMainController sharedInstance].document displayMessage:prefixedMessage];
    
    // NSUserNotification only shows if app is inactive
    NSUserNotification *notification =  [[NSUserNotification alloc] init];
    notification.title = @"CSSketch";
    notification.informativeText = error;
    notification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
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
