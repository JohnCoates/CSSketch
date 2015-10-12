//
//  CSKLayerCSS.h
//  CSSketch Helper
//
//  Created by John Coates on 10/9/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSKLayerCSS : NSObject

+ (void)handleBorderWithDOMLeaf:(NSDictionary *)leaf layer:(CSK_MSLayer *)layer;
+ (void)handleFrameWithDOMLeaf:(NSDictionary *)leaf layer:(CSK_MSLayer *)layer;
+ (void)handleShadowWithDOMLeaf:(NSDictionary *)DOMLeaf layer:(CSK_MSLayer *)layer;
+ (void)handleBackgroundColorWithDOMLeaf:(NSDictionary *)DOMLeaf layer:(CSK_MSLayer *)layer;

@end
