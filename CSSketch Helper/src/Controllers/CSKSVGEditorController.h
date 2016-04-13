//
//  CSKSVGEditorController.h
//  CSSketch Helper
//
//  Created by John Coates on 4/11/16.
//  Copyright © 2016 John Coates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSKSVGEditorController : NSObject

+ (instancetype)sharedInstance;

- (BOOL)editCurrentlySelectedShape;

@end
