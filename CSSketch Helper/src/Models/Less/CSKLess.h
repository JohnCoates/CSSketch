//
//  CSKLess.h
//  CSSketch Helper
//
//  Created by John Coates on 10/4/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSKLess : NSObject

typedef void (^LessCompileCompletionBlock)(NSError *error, NSString *compiledCSS);

+ (void)compileLessStylesheet:(NSString *)script completion:(LessCompileCompletionBlock)completionBlock;

@end
