//
//  CSKFileMonitor.h
//  CSSketch Helper
//
//  Created by John Coates on 10/3/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSKFileMonitor;

typedef void (^CSKFileMonitorChangeDetected)(CSKFileMonitor *fileMonitor);
typedef void (^CSKFileMonitorRenameDetected)(CSKFileMonitor *fileMonitor, NSURL *oldFileURL, NSURL *newFileURL);

@interface CSKFileMonitor : NSObject

@property (weak) CSK_MSDocument *document;
@property (weak) CSK_MSPage *page;
@property (strong) CSK_MSPluginCommand *command;
@property (copy) CSKFileMonitorChangeDetected changeBlock;
@property (copy) CSKFileMonitorRenameDetected renameBlock;

- (id)initWithFileURL:(NSURL *)fileURL bookmark:(NSData *)bookmark;
- (BOOL)startMonitoring;
@end
