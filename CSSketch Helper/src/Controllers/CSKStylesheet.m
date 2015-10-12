//
//  CSKStylesheet.m
//  CSSketch Helper
//
//  Created by John Coates on 10/4/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import "CSKStylesheet.h"
#import "CSKLess.h"
#import "CSKDOM.h"

@interface CSKStylesheet ()



@property (strong) NSURL *fileURL;
@property (strong) CSKDOM *domModel;
// Callback
@property (strong) id target;
@property SEL action;

@end

@implementation CSKStylesheet

- (instancetype)initWithFile:(NSURL *)fileURL {
    self = [super init];
    
    if (self) {
        _fileURL = fileURL;
        // to-do: monitor file
    }
    
    return self;
}


// parses stylesheet
- (void)parseStylesheet {
    [self parseStylesheet:^(NSError *error, NSString *compiledStylesheet) {
        dispatch_async(dispatch_get_main_queue(), ^{
    
        self.domModel = [[CSKDOM alloc] initWithStylesheet:compiledStylesheet callback:^(NSError *error, NSDictionary *DOMTree) {
            if (DEBUG) {
                NSLog(@"computed dom: %@", DOMTree);
            }
            
            if (error) {
                NSLog(@"error: %@", error);
                return;
            }
            else {
                [[CSKMainController sharedInstance] layoutLayersWithDOMTree:DOMTree];
                [[CSKMainController sharedInstance] refreshDocument];
            }
            
        } layerTree:self.layerTree];
        });
    }];
}
- (BOOL)parseStylesheet:(CSKStylesheetCompiled)completionBlock {
    
    NSError *error = nil;
    if ([CSKMainController inSandbox]) {
        [self.fileURL startAccessingSecurityScopedResource];
    }
    NSString *lessStylesheet = [NSString stringWithContentsOfFile:self.fileURL.path encoding:NSUTF8StringEncoding error:&error];
    
    if ([CSKMainController inSandbox]) {
        [self.fileURL stopAccessingSecurityScopedResource];
    }
    
    if (error) {
        NSLog(@"error retrieving contents of Less stylesheet: %@", error);
        return FALSE;
    }
    
    if (DEBUG) {
        NSLog(@"less stylesheet: %@", lessStylesheet);
    }
    
    [CSKLess compileLessStylesheet:lessStylesheet completion:^(NSError *error, NSString *compiledCSS) {
        if (error) {
            return;
        }
        
        if (DEBUG) {
            NSLog(@"css stylesheet: %@", compiledCSS);
        }
        
        completionBlock(error, compiledCSS);
        
    }];
    
    return TRUE;
}


@end
