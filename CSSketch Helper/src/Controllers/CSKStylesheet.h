//
//  CSKStylesheet.h
//  CSSketch Helper
//
//  Created by John Coates on 10/4/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CSKStylesheetCompiled)(NSError *error, NSString *compiledStylesheet);

@interface CSKStylesheet : NSObject

@property (strong) NSDictionary *layerTree;

- (instancetype)initWithFile:(NSURL *)fileURL;
- (BOOL)parseStylesheet:(CSKStylesheetCompiled)completionBlock;
- (void)parseStylesheet;
@end
