//
//  CSKToolbarProxy.m
//  CSSketch Helper
//
//  Created by John Coates on 10/5/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import "CSKToolbarProxy.h"
#import "CSKSVGEditorController.h"

@interface CSKToolbarProxy ()

@property (strong) id <NSToolbarDelegate> toolbarDelegate;

@end

@implementation CSKToolbarProxy

- (instancetype)initWithOriginalToolbarDelegate:(id <NSToolbarDelegate>)toolbarDelegate {
    self = [super init];
    
    if (self) {
        self.toolbarDelegate = toolbarDelegate;
    }
    
    return self;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
     itemForItemIdentifier:(NSString *)itemIdentifier
 willBeInsertedIntoToolbar:(BOOL)flag {
    if ([itemIdentifier isEqualToString:@"CSSketch"]) {
        NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
        NSString *imagePath = [currentBundle pathForResource:@"icon-layout24" ofType:@"png"];
        NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"CSSketch"];
        toolbarItem.label = @"CSS Layout";
        toolbarItem.paletteLabel = toolbarItem.label;
        toolbarItem.toolTip = toolbarItem.label;
        toolbarItem.target = self;
        toolbarItem.action = @selector(toolbarClick:);
        toolbarItem.image = [[NSImage alloc] initWithContentsOfFile:imagePath];
        toolbarItem.enabled = true;
        return toolbarItem;
    }
    else if ([itemIdentifier isEqualToString:@"CSSketch-SVG"]) {
        NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
        NSString *imagePath = [currentBundle pathForResource:@"icon-layout24" ofType:@"png"];
        NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"CSSketch-SVG"];
        toolbarItem.label = @"Edit SVG";
        toolbarItem.paletteLabel = toolbarItem.label;
        toolbarItem.toolTip = toolbarItem.label;
        toolbarItem.target = self;
        toolbarItem.action = @selector(svgEditClick:);
        toolbarItem.image = [[NSImage alloc] initWithContentsOfFile:imagePath];
        toolbarItem.enabled = true;
        return toolbarItem;
    }
    NSLog(@"item for identifier: %@", itemIdentifier);
    return [self.toolbarDelegate toolbar:toolbar
                   itemForItemIdentifier:itemIdentifier
               willBeInsertedIntoToolbar:flag];
}

- (void)toolbarClick:(id)item {
    if (!self.document) {
        return;
    }
    
    NSDictionary *context;
    context = @{@"document" : self.document, @"command" : self.command};
    
    [[CSKMainController sharedInstance] layoutLayersWithContext:context];
}

- (void)svgEditClick:(id)item {
    if (!self.document) {
        return;
    }
    
    NSLog(@"SVG edit!");
    [[CSKSVGEditorController sharedInstance] editCurrentlySelectedShape];
}

- (NSArray<NSString *> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return [self.toolbarDelegate toolbarDefaultItemIdentifiers:toolbar];
}

- (NSArray<NSString *> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    NSMutableArray *allowedItems = [[self.toolbarDelegate
                                     toolbarAllowedItemIdentifiers:toolbar] mutableCopy];
    [allowedItems addObject:@"CSSketch"];
    [allowedItems addObject:@"CSSketch-SVG"];
    
    return allowedItems;
}

- (NSArray<NSString *> *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
    NSMutableArray *selectable = [[self.toolbarDelegate
                                   toolbarSelectableItemIdentifiers:toolbar] mutableCopy];
    // check if Edit is selectable
    // if it's not, then SVG edit shouldn't be either!
//    __block BOOL isEditSelectable = FALSE;
    [selectable enumerateObjectsUsingBlock:^(NSString *  _Nonnull identifier, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([identifier isEqualToString:@"])
//        NSLog(@"checking identifier: %@", identifier);
    }];
    
    
    
    return selectable;
}

- (void)toolbarWillAddItem:(NSNotification *)notification {
    if ([self.toolbarDelegate respondsToSelector:@selector(toolbarWillAddItem:)]) {
        [self.toolbarDelegate toolbarWillAddItem:notification];
    }
}

- (void)toolbarDidRemoveItem:(NSNotification *)notification {
    if ([self.toolbarDelegate respondsToSelector:@selector(toolbarDidRemoveItem:)]) {
        [self.toolbarDelegate toolbarDidRemoveItem:notification];
    }
}

@end
