//
//  CSKInstallButton.m
//  CSSketch Helper
//
//  Created by John Coates on 2/5/16.
//  Copyright © 2016 John Coates. All rights reserved.
//

#import "CSKInstallButton.h"

@implementation CSKInstallButton

- (void)resetCursorRects
{
    if (self.cursor) {
        [self addCursorRect:[self bounds] cursor: self.cursor];
    } else {
        [super resetCursorRects];
    }
}

@end
