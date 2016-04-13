//
//  CSKMainController.h
//  CSSketch Helper
//
//  Created by John Coates on 10/5/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSKMainController : NSObject

+ (instancetype)sharedInstance;
@property BOOL inSketch;
@property (nonatomic, strong) NSString *embeddedStylesheet;
@property (nonatomic, strong) NSBundle *pluginBundle;
@property (weak) CSK_MSDocument *document;

// Plugin Entry Points
- (void)layoutLayersWithContext:(NSDictionary *)context;


- (void)refreshDocument;

+ (NSBundle *)pluginBundle;
+ (void)displayError:(NSString *)error;

+ (BOOL)inSandbox;
+ (BOOL)inSketch;


@end

static inline BOOL MSLayerIsGroup(id layer) {
    if ([layer isKindOfClass:NSClassFromString(@"MSLayerGroup")] && ![layer isMemberOfClass:NSClassFromString(@"MSShapeGroup")]) {
        return TRUE;
    }
    return FALSE;
}

static inline BOOL MSLayerIsArtboard(id layer) {
    if ([layer isKindOfClass:NSClassFromString(@"MSArtboardGroup")]) {
        return TRUE;
    }
    return FALSE;
}
static inline BOOL MSLayerIsPage(id layer) {
    if ([layer isKindOfClass:NSClassFromString(@"MSPage")]) {
        return TRUE;
    }
    return FALSE;
}