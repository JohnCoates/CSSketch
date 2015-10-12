//
//  CSKDocumentController.m
//  CSSketch Helper
//
//  Created by John Coates on 10/12/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import "CSKDocumentController.h"

@interface CSKDocumentController ()


// holds all the stylesheet rules applied to the current page
@property (strong) NSString *pageStylesheetRules;

@property (strong) CSKStylesheet *stylesheetController;
@property (strong) CSKDOM *domModel;
@end

@implementation CSKDocumentController

#pragma mark - Init

- (instancetype)initWithDocument:(CSK_MSDocument *)document {
    self = [super init];
    
    if (self) {
        self.document = document;
    }
    
    return self;
}

#pragma mark - Entry Point

- (void)layoutCurrentPageWithStylesheetURL:(NSURL *)stylesheetURL {
    self.pageStylesheetRules = @"\n";
    
    CSK_MSPage *page = self.document.currentPage;
    
    NSString *stylesheet = nil;
    NSDictionary *layerTree = [CSKLayers layerTreeFromLayer:page stylesheetOuput:&stylesheet];
    NSLog(@"layer tree: %@", layerTree);
    
    self.stylesheetController = [[CSKStylesheet alloc] initWithFile:stylesheetURL];
    
    [self.stylesheetController parseStylesheet:^(NSError *error, NSString *compiledStylesheet) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // add stylesheet rules
            // prior so their precedence is worst
            NSString *mergedStylesheet = [stylesheet stringByAppendingString:compiledStylesheet];
            
            CSKDOM *domModel = [[CSKDOM alloc] initWithStylesheet:mergedStylesheet callback:^(NSError *error, NSDictionary *DOMTree) {
                
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
                

                self.domModel = nil;
                
            } layerTree:layerTree];
            
            self.domModel = domModel;
        }); // DOM completion
        
        
        self.stylesheetController = nil;
    }]; // stylesheet compile completion
}



@end
