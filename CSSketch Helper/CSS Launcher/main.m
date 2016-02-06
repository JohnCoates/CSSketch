//
//  main.m
//  CSS Launcher
//
//  Created by John Coates on 2/4/16.
//  Copyright © 2016 John Coates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Close Sketch
        NSArray *sketches = [NSRunningApplication
                             runningApplicationsWithBundleIdentifier:@"com.bohemiancoding.sketch3"];
        if (sketches.count) {
            NSRunningApplication *sketch = sketches[0];
            [sketch forceTerminate];
        }
        
        // launch Sketch
        NSString *currentSourcePath = [NSString stringWithFormat:@"%s", __FILE__];
        NSString *launcherFolder =  [currentSourcePath stringByDeletingLastPathComponent];
        NSString *helperFolder = [launcherFolder stringByDeletingLastPathComponent];
        NSString *projectFolder = [helperFolder stringByDeletingLastPathComponent];
        NSString *scriptsfolder = [projectFolder stringByAppendingPathComponent:@"Scripts"];

        NSString *scriptPath = [scriptsfolder stringByAppendingPathComponent:@"CSSketch-remote.coscript"];
        NSLog(@"Launching CSSketch with script: %@", scriptPath);
        NSPipe *pipe = [NSPipe pipe];
        NSFileHandle *file = pipe.fileHandleForReading;
        
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = @"/usr/local/bin/coscript";
        task.arguments = @[scriptPath];
        task.standardOutput = pipe;
        
        [task launch];
        [file closeFile];
    }
    return 0;
}
