//
//  CSKToolbarProxy.h
//  CSSketch Helper
//
//  Created by John Coates on 10/5/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/Appkit.h>

@interface CSKToolbarProxy : NSObject <NSToolbarDelegate>

@property (weak) NSWindow *window;
@property (weak) CSK_MSDocument *document;
@property (strong) CSK_MSPluginCommand *command;

- (instancetype)initWithOriginalToolbarDelegate:(id <NSToolbarDelegate>)toolbarDelegate;

@end
