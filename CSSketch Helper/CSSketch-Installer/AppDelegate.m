//
//  AppDelegate.m
//  CSSketch-Installer
//
//  Created by John Coates on 2/5/16.
//  Copyright © 2016 John Coates. All rights reserved.
//

#import "AppDelegate.h"
#import "CSKInstallButton.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSImageView *buttonView;
@property (weak) IBOutlet NSTextField *redesignLabel;
@property (weak) IBOutlet NSTextField *installLabel;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.window.delegate = self;
    
    // install Button
    CSKInstallButton *installButton = [[CSKInstallButton alloc] initWithFrame:self.buttonView.frame];
    installButton.cursor = [NSCursor pointingHandCursor];
    installButton.target = self;
    installButton.action = @selector(installClick:);
    [installButton setTransparent:true];
    [self.window.contentView addSubview:installButton];
    
    // redesign Button
    CSKInstallButton *redesignButton = [[CSKInstallButton alloc] initWithFrame:self.redesignLabel.frame];
    redesignButton.cursor = [NSCursor pointingHandCursor];
    redesignButton.target = self;
    redesignButton.action = @selector(redesignClick:);
    [redesignButton setTransparent:true];
    [self.window.contentView addSubview:redesignButton];
}

- (void)installClick:(NSButton *)button {
    
    if (![self installPluginResourceWithName:@"CSSketch"]) {
        [self.installLabel setStringValue:@"Install Error"];
        return;
    }
    
    if (![self installPluginResourceWithName:@"SketchKit"]) {
        [self.installLabel setStringValue:@"Install Error"];
        return;
    }
    
    [self.installLabel setStringValue:@"Installed!"];
    
}

- (BOOL)installPluginResourceWithName:(NSString *)name {
    NSString *pluginsPath = @"~/Library/Application Support/com.bohemiancoding.sketch3/Plugins";
    pluginsPath = [pluginsPath stringByExpandingTildeInPath];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *pluginBundlePath = [bundle pathForResource:name ofType:@"sketchplugin"];
    
    if (!pluginBundlePath) {
        NSLog(@"Couldn't find plugin %@", name);
        return FALSE;
    }
    
    NSString *pluginDestinationPath = [pluginsPath stringByAppendingPathComponent:pluginBundlePath.lastPathComponent];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:pluginDestinationPath]) {
        NSError *error = nil;
        [fileManager removeItemAtPath:pluginDestinationPath error:&error];
        
        if (error) {
            NSLog(@"CSSketch Install Error: Couldn't remove %@: %@",
                  pluginDestinationPath, error);
            return FALSE;
        }
    }
    
//    NSLog(@"copying from: %@", pluginBundlePath);
    NSError *error = nil;
    [fileManager copyItemAtPath:pluginBundlePath toPath:pluginDestinationPath error:&error];
    if (error) {
        NSLog(@"CSSketch Install Error: Couldn't copy %@ to %@: %@",
              pluginBundlePath, pluginDestinationPath, error);
        return FALSE;
    }
    
    return TRUE;
}

- (void)redesignClick:(NSButton *)button {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/JohnCoates/CSSketch/issues/19"]];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

- (BOOL)windowShouldClose:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
    return true;
}

@end
