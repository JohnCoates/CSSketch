//
//  CocoaSass.h
//  CocoaSass
//
//  Created by John Coates on 1/31/16.
//  Copyright © 2016 John Coates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CocoaSass : NSObject

+ (NSString *)compileSass:(NSString *)contents
                extension:(NSString *)extension // must be sass or scss
                    error:(NSError **)errorOut;

@end
