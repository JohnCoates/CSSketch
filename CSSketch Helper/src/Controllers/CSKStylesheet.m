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
    }
    
    return self;
}


- (void)dealloc {
    if (DEBUG) {
        NSLog(@"CSKStylesheet dealloc");
    }
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
                [CSKLayers layoutLayersWithDOMTree:DOMTree];
                [[CSKMainController sharedInstance] refreshDocument];
            }
         
            self.domModel = nil;
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
        NSString *errorString = [NSString stringWithFormat:@"Couldn't read stylesheet %@", self.fileURL.path];
        [CSKMainController displayError:errorString];
        return FALSE;
    }
    
    // process @import
    // un-escaped regex: @import[\s]+?(\([^)]+\)[\s]+)?['"]([^'"]+)['"];
    // targetting: @import (keyword) "filename";
    NSArray *importMatches = [lessStylesheet matchesWithDetails:RX(@"@import[\\s]+?(\\([^)]+\\)[\\s]+)?['\"]([^'\"]+)['\"];")];
    
    if (importMatches.count) {
        for (RxMatch *match in importMatches) {
            RxMatchGroup *wholeMatch = match.groups[0];
//            RxMatchGroup *keywordMatch = match.groups[1];
            RxMatchGroup *filenameMatch = match.groups[2];
            NSString *filename = filenameMatch.value;
            
            NSString *pathComponent = [NSString stringWithFormat:@"/../%@", filename];
            NSString *filenamePath = [[self.fileURL.path stringByAppendingPathComponent:pathComponent] stringByStandardizingPath];
            
            if ([CSKMainController inSandbox] == FALSE) {
                NSString *importContents = [NSString stringWithContentsOfFile:filenamePath
                                                                     encoding:NSUTF8StringEncoding
                                                                        error:&error];
                
                if (error) {
                    NSString *errorString = [NSString stringWithFormat:@"Couldn't import stylesheet %@", filenamePath];
                    [CSKMainController displayError:errorString];
                    return FALSE;
                }
                lessStylesheet = [lessStylesheet stringByReplacingOccurrencesOfString:wholeMatch.value withString:importContents];
                
            }
            else {
                // TODO: add prompt for file selection or for directory access
                NSString *error = [NSString stringWithFormat:@"@import is not supported in Sandboxed Sketch!"];
                [CSKMainController displayError:error];
            }
            
        }
    }
    
    if (DEBUG) {
        NSLog(@"less stylesheet: %@", lessStylesheet);
    }
    
    [CSKLess compileLessStylesheet:lessStylesheet completion:^(NSError *error, NSString *compiledCSS) {
        if (error) {
            NSLog(@"error compiling stylesheet: %@", error);
        }
        
        if (DEBUG) {
            NSLog(@"css stylesheet: %@", compiledCSS);
        }
        
        completionBlock(error, compiledCSS);
        
    }];
    
    return TRUE;
}


@end
