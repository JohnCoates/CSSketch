//
//  CSKDOM.h
//  CSSketch Helper
//
//  Created by John Coates on 10/4/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

typedef void (^CSKDOMComputedCallback)(NSError *error, NSDictionary *computedDOM);

@interface CSKDOM : NSObject <WebFrameLoadDelegate, WebPolicyDelegate>

- (instancetype)initWithStylesheet:(NSString *)stylesheet
                          callback:(CSKDOMComputedCallback)callbackBlock
                         layerTree:(NSDictionary *)layerTree
                        NS_DESIGNATED_INITIALIZER;

@end
