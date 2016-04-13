//
//  CSKSVGEditorController.m
//  CSSketch Helper
//
//  Created by John Coates on 4/11/16.
//  Copyright © 2016 John Coates. All rights reserved.
//

#import "CSKSVGEditorController.h"
#import "CSKMainController.h"

@implementation CSKSVGEditorController

+ (instancetype)sharedInstance {
    static CSKSVGEditorController *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [CSKSVGEditorController new];
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}


- (BOOL)editCurrentlySelectedShape {
    CSKMainController *mainController = [CSKMainController sharedInstance];
    CSK_MSDocument *document = mainController.document;
    if (!document) {
        return NO;
    }
    NSArray *selectedLayers = document.selectedLayers;
    NSLog(@"selected layers: %@", selectedLayers);
    if (selectedLayers.count != 1) {
        return NO;
    }
    
    Class MSShapePathLayer = NSClassFromString(@"MSShapePathLayer");
    if (!MSShapePathLayer) {
        NSLog(@"error, couldn't get class: %@", @"MSShapePathLayer");
        return NO;
    }
    id layer = selectedLayers.firstObject;
    
    if ([layer isKindOfClass:MSShapePathLayer] == NO) {
        return NO;
    }
    
    SKK_MSShapePathLayer *shapePathLayer = [[SKK_MSShapePathLayer alloc] initWithShapePathLayer:layer];
    
    if (!shapePathLayer) {
        return NO;
    }
    
    NSLog(@"shape path layer: %@", shapePathLayer);
    SKK_MSShapePath *shapePath = shapePathLayer.path;
    if (!shapePath) {
        return NO;
    }
    NSLog(@"shape path: %@", shapePath);
    
    NSArray *points = shapePath.points;
    NSLog(@"points: %@", points);
    int count = (int)points.count;
    
    for (int index = 0; index < count; index += 1) {
        STUB_MSCurvePoint *point = points[index];
//        NSLog(@"point: %@", point);
//        NSLog(@"point: %@, curveMode: %lld curveFrom (%d): %@, curveTo (%d): %@",
//              NSStringFromPoint(point.point),
//              point.curveMode,
//              point.hasCurveFrom,
//              NSStringFromPoint(point.curveFrom),
//              point.hasCurveTo,
//              NSStringFromPoint(point.curveTo)
//              );
        
        
        NSString *output = [NSString stringWithFormat:@"polygonManager.addPointEntry(polygon, [%.21Lg, %.21Lg], %lld, %d, [%.21Lg, %.21Lg], %d, [%.21Lg, %.21Lg]);",
              (long double)point.point.x, (long double)point.point.y,
              point.curveMode,
              point.hasCurveFrom,
              (long double)point.curveFrom.x, (long double)point.curveFrom.y,
              point.hasCurveTo,
              (long double)point.curveTo.x, (long double)point.curveTo.y
              ];
        CFShow((__bridge CFStringRef)output);
        
    }
    
    
    
    return YES;
}

@end
