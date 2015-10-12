//
//  CSKDocumentController.h
//  CSSketch Helper
//
//  Created by John Coates on 10/12/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSKDocumentController : NSObject

@property (weak) CSK_MSDocument *document;

- (instancetype)initWithDocument:(CSK_MSDocument *)document;
- (void)layoutCurrentPageWithStylesheetURL:(NSURL *)stylesheetURL;

@end
