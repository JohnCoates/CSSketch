//
//  CSKSketchHeaders.h
//  CSSketch Helper
//
//  Created by John Coates on 10/5/15.
//  Copyright © 2015 John Coates. All rights reserved.
//
//  Description:    This file stubs out headers for Sketch classes used. The're prefixed with CSK_ so we don't have
//                  to actually link to the Sketch binary, we just implement stub classes.

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class CSK_MSLayer, CSK_MSContentDrawView, CSK_MSStyle, CSK_MSStyleBorder, CSK_MSColor;
@class CSK_MSStyleShadow, CSK_MSPage, CSK_MSStyleFill, CSK_MSTextLayer;

@interface CSK_MSColor : NSObject
@property(readonly, nonatomic) double red;
@property(readonly, nonatomic) double green;
@property(readonly, nonatomic) double blue;
@property(readonly, nonatomic) double alpha;
    + (id)colorWithRed:(double)arg1 green:(double)arg2 blue:(double)arg3 alpha:(double)arg4;
@end

@interface CSK_MSStylePartCollection : NSArray
- (id)addNewStylePart;
@end

@interface CSK_MSStyle
    @property (readonly) CSK_MSStyleBorder *border;
    @property (readonly) CSK_MSStyleShadow *shadow;
    @property (readonly) CSK_MSStyleShadow *innerShadow;
    @property(retain, nonatomic) CSK_MSStyleFill *fill;
    @property(retain, nonatomic) CSK_MSStylePartCollection *borders;
    @property(retain, nonatomic) CSK_MSStylePartCollection *shadows;
    @property(retain, nonatomic) CSK_MSStylePartCollection *fills;
@end


@interface CSK_MSStyleFill
    @property(nonatomic) unsigned long long fillType;
    @property(copy, nonatomic) CSK_MSColor *color;
@end

@interface CSK_MSStyleBorder
    @property(nonatomic) double thickness;
    @property(nonatomic) long long position;
    @property(copy, nonatomic) CSK_MSColor *color;
typedef NS_ENUM(long long, MSStyleBorderPosition) {
    MSStyleBorderPositionCenter = 0,
    MSStyleBorderPositionInside = 1,
    MSStyleBorderPositionOutside = 2,
};
@end

@interface CSK_MSStyleShadow
@property(nonatomic) double spread;
@property(nonatomic) double offsetY;
@property(nonatomic) double offsetX;
@property(nonatomic) double blurRadius;
@property(copy, nonatomic) CSK_MSColor *color;

@end

@interface CSK_MSDocument : NSDocument
    @property(retain, nonatomic) NSWindow *documentWindow;
- (CSK_MSPage *)currentPage;
- (CSK_MSContentDrawView *)currentView;
- (void)displayMessage:(NSString *)message;
- (void)reloadInspector;
@end


@interface CSK_MSLayer : NSObject
    @property (readonly) NSString *name;
    @property (readonly) NSArray *layers;
    @property (readonly) NSString *objectID;
    @property(nonatomic) struct CGRect frameInArtboard;
    @property(nonatomic) struct CGRect rect;
    @property (readonly) CSK_MSStyle *style;


    - (void)invalidateLightweightCopy:(id)arg1;
    // groups only
    - (BOOL)resizeRoot:(BOOL)resize;

    - (void)hideSelectionTemporarily;
@end

@interface CSK_MSArtboardGroup : CSK_MSLayer
@property(nonatomic) BOOL hasBackgroundColor;
@property(copy, nonatomic) CSK_MSColor *backgroundColor;
@end

static const long long CSKMSLayerDirtyTypeTextColor = 3;

@interface CSK_MSTextLayer : CSK_MSLayer
    @property(copy, nonatomic) NSString *stringValue;
    @property(copy, nonatomic) CSK_MSColor *textColor;
    @property(retain, nonatomic) NSTextStorage *storage;
    - (void)markLayerDirtyOfType:(unsigned long long)arg1;
    - (void)layerDidChange;
    - (void)syncTextStyleAttributes;
    - (void)prepareForUndo;
@end

@interface CSK_MSPage : CSK_MSLayer

@end

@interface CSK_MSPluginCommand : NSObject
- (id)valueForKey:(NSString *)key
          onLayer:(CSK_MSLayer *)layer
forPluginIdentifier:(NSString *)identifier;
- (void)setValue:(id)value
          forKey:(NSString *)key
         onLayer:(CSK_MSLayer *)layer
forPluginIdentifier:(NSString *)pluginIdentifier;

@end

@interface CSK_MSContentDrawView : NSObject

- (void)refresh;
@end