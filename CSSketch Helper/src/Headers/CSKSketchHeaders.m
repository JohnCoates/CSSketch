//
//  CSKSketchHeaders.m
//  CSSketch Helper
//
//  Created by John Coates on 10/5/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import "CSKSketchHeaders.h"

@implementation CSK_MSLayer

- (BOOL)resizeRoot:(BOOL)resize {
    return true;
}

- (void)invalidateLightweightCopy:(id)arg1 {
    
}

- (void)hideSelectionTemporarily {
    
}
@end

@implementation CSK_MSDocument

- (void)displayMessage:(NSString *)message {
    
}
- (CSK_MSPage *)currentPage {
    return nil;
}

- (CSK_MSContentDrawView *)currentView{
    return nil;
}

- (void)reloadInspector {
    
}

@end




@implementation CSK_MSPluginCommand
- (id)valueForKey:(NSString *)key onLayer:(CSK_MSLayer *)layer forPluginIdentifier:(NSString *)identifier {
    return nil;
}
- (void)setValue:(id)value forKey:(NSString *)key onLayer:(CSK_MSLayer *)layer  forPluginIdentifier:(NSString *)pluginIdentifier {
    
}
@end

@implementation CSK_MSContentDrawView
- (void)refresh {}
@end

@implementation CSK_MSColor
+ (id)colorWithRed:(double)arg1 green:(double)arg2 blue:(double)arg3 alpha:(double)arg4 {
    return [NSClassFromString(@"MSColor") colorWithRed:arg1 green:arg2 blue:arg3 alpha:arg4];
}
@end