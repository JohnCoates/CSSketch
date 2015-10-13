//
//  MONCallHandler.h
//  Monolith
//
//  Created by John Coates on 4/21/15.
//  Copyright (c) 2015 John Coates. All rights reserved.
//

#import <Foundation/Foundation.h>

// Constants

extern NSUInteger MONRegisterSize; // Size of regular register (32-bit: 4 bytes, 64-bit: 8 bytes)
extern NSUInteger MONVFPRegisterSize; // Size of VFP registers (8 bytes)
extern NSUInteger MONOriginalStackStride; // How many bytes seperate the original stack from the end of our pushed registers

extern NSUInteger MONRegisterArguments; // how many method arguments can be stored in registers
extern NSUInteger MONVFPRegisterArguments; // how many VFP arguments can be stored in registers
extern NSUInteger MONStoredGeneralRegisters; // how many registers are stored in the stack
extern NSUInteger MONStoredVFPRegisters; // how many VFP registers are in the stack

@interface MONCallHandler : NSObject

/// Calls original method and returns an NSObject encapsulating the return value
- (id)callOriginalMethod;

@end


@interface MONCallHandler (Setters)

/// Sets and argument before a call to -callOriginalMethod
/// Pass an NSObject encapsulating the original format.
- (BOOL)setArgument:(NSUInteger)argumentIndex toValue:(id)object;

@end
