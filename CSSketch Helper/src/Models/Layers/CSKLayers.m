//
//  CSKLayers.m
//  CSSketch Helper
//
//  Created by John Coates on 10/12/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import "CSKLayers.h"

static const BOOL DEBUG_WriteOutLayerTree = TRUE;
@implementation CSKLayers


+ (NSDictionary *)layerTreeFromLayer:(CSK_MSLayer *)layer stylesheetOuput:(NSString **)stylesheetOutput {
    NSMutableDictionary *leaf = [NSMutableDictionary new];
    
    NSString *stylesheet = *stylesheetOutput;
    
    BOOL topOfTree = FALSE;
    
    if (!stylesheet) { // top of tree
        stylesheet = @"\n";
        topOfTree = TRUE;
        
    }
    
    NSString *name = layer.name;
    leaf[@"layer"] = layer;
    
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
        
        stylesheet = [stylesheet stringByAppendingString:styleSheetRule];
    }
    
    if (MSLayerIsGroup(layer)) {
        NSMutableArray *childrenList;
        childrenList = [NSMutableArray new];
        
        NSArray *children = layer.layers;
        
        for (CSK_MSLayer *childLayer in children) {
            NSDictionary *childTree = [self layerTreeFromLayer:childLayer stylesheetOuput:&stylesheet];
            
            if (childTree) {
                [childrenList addObject:childTree];
            }
        }
        
        // reverse order so it's correctly ordered
        leaf[@"children"] = childrenList.reverseObjectEnumerator.allObjects;
    }
    
    
    *stylesheetOutput = stylesheet;
    
    if (DEBUG && topOfTree && DEBUG_WriteOutLayerTree && [CSKMainController inSandbox] == FALSE) {
        [self saveDebugTree:leaf];
    }
    
    return leaf;
}

#pragma mark - DEBUG

+ (void)saveDebugTree:(NSDictionary *)layerTree {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        NSDictionary *saveableTree = [self saveableTree:layerTree];
        
        BOOL wrote = [saveableTree writeToFile:@"/Users/macbook/Dev/Extensions/Sketch/CSSketch/debug.plist"
                                    atomically:TRUE];
        if (DEBUG) {
            NSLog(@"wrote to file: %d", wrote);
        }
    });
}

+ (NSDictionary *)saveableTree:(NSDictionary *)tree {
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

@end
