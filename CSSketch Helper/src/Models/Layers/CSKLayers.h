//
//  CSKLayers.h
//  CSSketch Helper
//
//  Created by John Coates on 10/12/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSKLayers : NSObject

+ (void)layoutLayersWithDOMTree:(NSDictionary *)DOMTree;

+ (NSDictionary *)layerTreeFromLayer:(CSK_MSLayer *)layer stylesheetOuput:(NSString **)stylesheetOutput;

@end
