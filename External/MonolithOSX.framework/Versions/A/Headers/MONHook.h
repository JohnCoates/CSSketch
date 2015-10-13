//
//  MONHook.h
//  Monolith
//
//  Created by John Coates on 5/29/14.
//  Copyright (c) 2014 John Coates. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 MONHook is protocol used for hooking other classes.

### Implementation Notes
 
You must implement + (NSArray <NSString *> *)targetClasses;

## How To Hook a Class
 
If your target method is:

@code
- (BOOL)shouldPlayInline;
@endcode
 
Your hook would look like this:

@code
- (BOOL)shouldPlayInline_hook:(MONCallHandler *)callHandler {
	NSNumber *originalReturnValue = [callHandler callOriginalMethod];
	NSLog(@"[%@ %@] originally returned: %@, replacing return value with TRUE",
		NSStringFromClass([self class]),
		NSStringFromSelector(_cmd),
		originalReturnValue
		);
 
	return TRUE;
}
@endcode
 
If the method you're hooking takes arguments, simply postfix this to the method: hook:(MONCallHandler *)callHandler
 
*/

@protocol MONHook <NSObject>
@required

/** @name targetClasses */

/**
 *  This method must be implemented.
 *
 *  @warning `targetClasses` must not return `nil`.
 *  @return The class or classes that you're setting hooks for.
 */
#ifdef __IPHONE_9_0
+ (NSArray <NSString *> *)targetClasses;
#else
+ (NSArray *)targetClasses;
#endif
@optional

/**
	Whether hooks should be automatically installed.
 
	This is the preferred way to handle hooks. A manual hooking method will be added in the future.
	@return Whether this class should automatically install hooks on load. Defaults to YES
 */
+ (BOOL)shouldAutomaticallyInstallHooks;


/**
	When this method is implemented, it will be called to notify a class
	that its hooks have been installed.
 */

+ (void)installedHooksForClass:(NSString *)targetClass;

@end


// Subclassing MONHook is deprecated
__attribute((unavailable("Use MONHook as a protocol instead of subclassing."))) @interface MONHook : NSObject
@end
