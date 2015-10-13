//
//  RS_MSTextLayer.m
//  CSSketch Helper
//
//  Created by John Coates on 10/12/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import "RS_MSTextLayer.h"
#import <MonolithOSX/MONCallHandler.h>

@implementation RS_MSTextLayer

#pragma mark - Hook

+ (NSArray *)targetClasses {
    return @[@"MSTextLayer"];
}

+ (void)installedHooksForClass:(NSString *)targetClass {
    NSLog(@"woo, isntalled hooks for: %@", targetClass);
}

- (void)markLayerDirtyOfType:(unsigned long long)arg1 hook:(MONCallHandler *)callHandler {
    NSLog(@"markLayerDirtyOfType:%d", (int)arg1);
    [callHandler callOriginalMethod];
}

@end
