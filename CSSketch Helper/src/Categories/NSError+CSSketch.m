//
//  NSError+CSSketch.m
//  CSSketch Helper
//
//  Created by John Coates on 3/17/16.
//  Copyright © 2016 John Coates. All rights reserved.
//

#import "NSError+CSSketch.h"

@implementation NSError (CSSketch)

+ (instancetype)errorWithMessage:(NSString *)message {
    NSError *error;
    NSDictionary *userInfo;
    
    userInfo = @{
                 NSLocalizedDescriptionKey : message
                 };
    error = [NSError errorWithDomain:@"CSK"
                                code:801
                            userInfo:userInfo];
    
    return error;
}

@end
