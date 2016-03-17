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
    NSString *stylesheet = [NSString stringWithContentsOfFile:self.fileURL.path encoding:NSUTF8StringEncoding error:&error];
    
    if ([CSKMainController inSandbox]) {
        [self.fileURL stopAccessingSecurityScopedResource];
    }
    
    if (error) {
        NSLog(@"error retrieving contents of stylesheet: %@", error);
        NSString *errorString = [NSString stringWithFormat:@"Couldn't read stylesheet %@", self.fileURL.path];
        [CSKMainController displayError:errorString];
        return FALSE;
    }
    
    // process @import
    // un-escaped regex: @import[\s]+?(\([^)]+\)[\s]+)?['"]?([^'"\n]+)['"]?;?
    // targetting: @import (keyword) "filename";
    NSArray *importMatches = [stylesheet matchesWithDetails:RX(@"@import[\\s]+?(\\([^)]+\\)[\\s]+)?['\"]([^'\"\\n]+)['\"]?;?")];
    
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
                stylesheet = [stylesheet stringByReplacingOccurrencesOfString:wholeMatch.value withString:importContents];
                
            }
            else {
                // TODO: add prompt for file selection or for directory access
                NSString *error = [NSString stringWithFormat:@"@import is not supported in Sandboxed Sketch!"];
                [CSKMainController displayError:error];
            }
            
        }
    }
    
    if (DEBUG) {
        NSLog(@"stylesheet length %d: %@", (int)stylesheet.length, stylesheet);
    }
    if (stylesheet.length == 0) {
        completionBlock(nil, stylesheet);
        return TRUE;
    }
    
    NSString *extension = [self fileURL].path.pathExtension.lowercaseString;
    
    if ([extension isEqualToString:@"less"]) {
        [CSKLess compileLessStylesheet:stylesheet completion:^(NSError *error, NSString *compiledCSS) {
            if (error) {
                NSString *errorMessage = [NSString stringWithFormat:@"CSSketch: Error compiling {less} stylesheet: %@", error];
                [CSKMainController displayError:errorMessage];
                NSLog(@"%@", errorMessage);
            }
            
            if (DEBUG) {
                NSLog(@"compiled less stylesheet: %@", compiledCSS);
            }
            
            completionBlock(error, compiledCSS);
            
        }];
    }
    else if ([extension isEqualToString:@"sass"] || [extension isEqualToString:@"scss"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSError *error = nil;
            NSString *compiledCSS = [CocoaSass compileSass:stylesheet
                                                 extension:extension
                                                     error:&error];
            
            if (error != nil || !compiledCSS) {
                compiledCSS = @"";
            }
            
            
            if (DEBUG) {
                NSLog(@"compiled %@ stylesheet: %@", extension, compiledCSS);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(error, compiledCSS);
            });
        });
    }
    else {
        completionBlock(nil, stylesheet);
    }
    
    return TRUE;
}


@end
