//
//  CSKFileMonitor.m
//  CSSketch Helper
//
//  Created by John Coates on 10/3/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import "CSKFileMonitor.h"

@interface CSKFileMonitor ()

@property (strong) NSURL *fileURL;
@property (strong) NSData *fileBookmark;
@property BOOL isMonitoring;
@property (strong) dispatch_source_t source;

// last change in milliseconds since 1970
@property int64_t lastChangeMS;

@end

@implementation CSKFileMonitor

- (id)initWithFileURL:(NSURL *)fileURL bookmark:(NSData *)bookmark {
    self = [super init];
    
    if (self) {
        self.fileURL = fileURL;
        
        if (!bookmark) {
        
            NSError *error = nil;
            NSURLBookmarkCreationOptions bookmarkOptions = 0;
            self.fileBookmark = [fileURL bookmarkDataWithOptions:bookmarkOptions
                               includingResourceValuesForKeys:nil relativeToURL:nil error:&error];
            if (error) {
                NSLog(@"error creating bookmark! %@", error);
            }
        }
        
        self.fileBookmark = bookmark;
        self.isMonitoring = false;
    }
    
    return self;
}

- (void)dealloc {
    if (DEBUG) {
        NSLog(@"filemonitor dealloc");
    }
    [self stopMonitoring];
}

- (BOOL)startMonitoring {
    if (self.isMonitoring) {
        return true;
    }
    
    self.lastChangeMS = 0;
    self.isMonitoring = true;
    
    if ([CSKMainController inSandbox]) {
        [self.fileURL startAccessingSecurityScopedResource];
    }
    
    int fileDescriptor = open(self.fileURL.path.UTF8String, O_RDONLY);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fileDescriptor,
                                                      DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_ATTRIB | DISPATCH_VNODE_RENAME,
                                                      queue);
    self.source = source;
    
    CSKFileMonitor * __weak weakSelf = self;
    dispatch_source_set_event_handler(source, ^
    {
        if (DEBUG) {
            NSLog(@"file monitor changes detected");
        }
        dispatch_source_vnode_flags_t flags = dispatch_source_get_data(source);
        
        
        if (flags & DISPATCH_VNODE_RENAME) {
            if (DEBUG) {
                NSLog(@"renamed!");
            }
            
            NSURLBookmarkResolutionOptions bookmarkOptions = 0;
            if ([CSKMainController inSandbox]) {
                bookmarkOptions = NSURLBookmarkResolutionWithSecurityScope;
            }
            
            NSURL *currentURL = weakSelf.fileURL;
            NSError *error;
            NSURL *newURL = [NSURL URLByResolvingBookmarkData:weakSelf.fileBookmark
                                                      options:bookmarkOptions relativeToURL:nil bookmarkDataIsStale:NULL error:&error];
            if (error) {
                NSLog(@"couldn't resolve file bookmark, error: %@", error);
            }
            else {
                weakSelf.fileURL = newURL;
                if (DEBUG) {
                    NSLog(@"%@ renamed to %@", currentURL, newURL);
                }
                weakSelf.renameBlock(weakSelf, currentURL, newURL);
            }
        }
        else {
            NSTimeInterval timestamp = [NSDate date].timeIntervalSince1970;
            int64_t timestampMS = timestamp * 1000;
            
            // wait at least 200 MS between change notifications
            
            int64_t minimumTimePassed = 200;
            
            if (timestampMS - weakSelf.lastChangeMS >= minimumTimePassed) {
                weakSelf.lastChangeMS = timestampMS;
                weakSelf.changeBlock(weakSelf);
            }
        }
        
        // cancel
        [weakSelf stopMonitoring];
        // re-start
        [weakSelf startMonitoring];
    });
    
    dispatch_source_set_cancel_handler(source, ^
    {
        close(fileDescriptor);
        [weakSelf.fileURL stopAccessingSecurityScopedResource];
    });
    
    dispatch_resume(source);
    return true;
}

- (void)stopMonitoring {
    self.isMonitoring = false;
    dispatch_source_cancel(self.source);
}

@end
