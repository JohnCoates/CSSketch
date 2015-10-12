//
//  NSString+Paths.h
//  CSSketch Helper
//
//  Created by John Coates on 10/11/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Paths)

- (NSString *)stringWithPathRelativeTo:(NSString *)anchorPath;

@end
