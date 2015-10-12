//
//  CSK_Tests.m
//  CSK Tests
//
//  Created by John Coates on 10/4/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CSKLess.h"
#import "CSKDOM.h"
#import "CSKStylesheet.h"

@interface CSK_Tests : XCTestCase

@end

@implementation CSK_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCSSparsing {
    [CSKLess compileLessStylesheet:@".class { width: (1 + 1) }" completion:^(NSError *error, NSString *compiledCSS) {
        if (error) {
            NSLog(@"error: %@", error);
            return;
        }
        NSLog(@"compiled CSS: %@", compiledCSS);
    }];
}


//- (void)testDOM {
//    [CSKLess compileLessStylesheet:@".widthTest { width: (1 + 1) }" completion:^(NSError *error, NSString *compiledCSS) {
//        if (error) {
//            NSLog(@"error: %@", error);
//            return;
//        }
//        NSLog(@"compiled CSS: %@", compiledCSS);
//        [[CSKDOM alloc] initWithStylesheet:compiledCSS callback:^(NSError *error, NSArray *computedDOM) {
//           
//        }];
//    }];
////    [CSKDOM new];
//}

- (void)testStylesheet {
//    NSString *stylesheetPath = @"/Users/macbook/Dev/Extensions/Sketch/Sketch-CSS/Examples/flexBox.css";
    NSString *stylesheetPath = @"/Users/macbook/Dev/Extensions/Sketch/CSSketch/Examples/Less - Netflix Player Redesign.less";
    NSURL *stylesheetURL = [NSURL fileURLWithPath:stylesheetPath];
    CSKStylesheet *stylesheetController = [[CSKStylesheet alloc] initWithFile:stylesheetURL];

    NSString *plistPath = @"/Users/macbook/Dev/Extensions/Sketch/CSSketch/debug.plist";
    NSData *treeData = [NSData dataWithContentsOfFile:plistPath];
    
    NSMutableDictionary *layerTree = [NSPropertyListSerialization propertyListWithData:treeData
                                                                          options:NSPropertyListMutableContainers format:NULL error:NULL];
    stylesheetController.layerTree = layerTree;
    
    [stylesheetController parseStylesheet];
//    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
    
    // let DOM load
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    

}


- (void)testInSketch {
    // Close Sketch
    NSArray *sketches = [NSRunningApplication
                         runningApplicationsWithBundleIdentifier:@"com.bohemiancoding.sketch3"];
    if (sketches.count) {
        NSRunningApplication *sketch = sketches[0];
        [sketch forceTerminate];
    }
    
    // launch Sketch
    // TODO: change to relative path
    [[NSWorkspace sharedWorkspace] openFile:@"/Users/macbook/Dev/Extensions/Sketch/CSSketch/Examples/Less - Netflix Player Redesign.sketch"];
//    [[NSWorkspace sharedWorkspace] openFile:@"/Users/macbook/Dev/Extensions/Sketch/CSSketch/Examples/flexBox.sketch"];
    
    // sleep for a bit while Sketch launches
    sleep(2);
    
    NSString *scriptPath = @"/Users/macbook/Dev/Extensions/Sketch/CSSketch/CSSketch-remote.coscript";
    
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/local/bin/coscript";
    task.arguments = @[scriptPath];
    task.standardOutput = pipe;
    
    [task launch];
    [file closeFile];
    
}

@end
