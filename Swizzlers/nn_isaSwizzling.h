//
//  nn_isaSwizzling.h
//  Swizzlers
//
//  Created by Scott Perry on 02/07/13.
//  Copyright (c) 2013 Scott Perry. All rights reserved.
//
//  This module implements generic isa swizzling assuming the following conditions are met:
//  • A protocol with the same name as the swizzling class exists and is implemented by the swizzling class.
//  • The object is an instance of the swizzling class's superclass, or a subclass of the swizzling class's superclass.
//  • The swizzling class does not add any ivars or non-dynamic properties.
//
//  An object has been swizzled by a class if it conforms to that class's complementing protocol, allowing you to cast the object (after checking!) to a type that explicitly implements the protocol.
//

#import <objc/objc.h>

BOOL nn_object_swizzleIsa(id obj, Class swizzlingClass) __attribute__((nonnull(1, 2)));
