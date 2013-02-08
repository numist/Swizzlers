//
//  nn_isaSwizzling.h
//  Swizzlers
//
//  Created by Scott Perry on 02/07/13.
//  Copyright (c) 2013 Scott Perry. All rights reserved.
//

#import "nn_isaSwizzling.h"

static NSString *_prefixForSwizzlingClass(Class aClass) __attribute__((nonnull(1), pure));
static __autoreleasing NSString * _classNameForObjectWithSwizzlingClass(id anObject, Class aClass) __attribute__((nonnull(1, 2), pure));

static BOOL _class_addInstanceMethodsFromClass(Class target, Class source) __attribute__((nonnull(1, 2)));
static BOOL _class_containsNonDynamicProperties(Class aClass) __attribute__((nonnull(1)));
static BOOL _class_containsIvars(Class aClass) __attribute__((nonnull(1)));
static Class _targetClassForObjectWithSwizzlingClass(id anObject, Class aClass) __attribute__((nonnull(1, 2)));
static BOOL _alreadySwizzledObjectWithSwizzlingClass(id anObject, Class aClass) __attribute__((nonnull(1, 2)));
static BOOL _object_swizzleIsa(id anObject, Class aClass) __attribute__((nonnull(1, 2)));
