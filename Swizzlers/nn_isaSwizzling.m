//
//  nn_isaSwizzling.m
//  Swizzlers
//
//  Created by Scott Perry on 02/07/13.
//  Copyright (c) 2013 Scott Perry. All rights reserved.
//

#import "nn_isaSwizzling_Internal.h"

#import <objc/runtime.h>

#import "NNISASwizzledObject.h"


static NSString *_prefixForSwizzlingClass(Class aClass)
{
    return [NSString stringWithFormat:@"%s_", class_getName(aClass)];
}

static __autoreleasing NSString * _classNameForObjectWithSwizzlingClass(id anObject, Class aClass)
{
    return [NSString stringWithFormat:@"%@%s", _prefixForSwizzlingClass(aClass), object_getClassName(anObject)];
}

static BOOL _class_addInstanceMethodsFromClass(Class target, Class source)
{
    BOOL success = NO;
    Method *methods = class_copyMethodList(source, NULL);
    
    for (NSUInteger i = 0; methods && methods[i]; i++) {
        Method method = methods[i];
        
        BailWithGotoUnless(class_addMethod(target, method_getName(method), method_getImplementation(method), method_getTypeEncoding(method)), finished);
    }
    
    success = YES;
finished:
    free(methods); methods = NULL;
    return success;
}

static Class _targetClassForObjectWithSwizzlingClass(id anObject, Class aClass)
{
    Class targetClass = objc_getClass(_classNameForObjectWithSwizzlingClass(anObject, aClass).UTF8String);
    
    if (!targetClass) {
        // protocol corresponding to target class must exist
        Protocol *proto = objc_getProtocol(class_getName(aClass));
        if(!proto) {
            NSLog(@"Protocol %s must be defined to swizzle objects using class %@", class_getName(aClass), aClass);
            return NO;
        }
        
        // Source class must conform to the corresponding protocol
        if (!class_conformsToProtocol(aClass, proto)) {
            NSLog(@"Swizzling class %s does not conform to protocol %s", class_getName(aClass), protocol_getName(proto));
            return NO;
        }
        
        // obj must be subclass of class' superclass to guarantee that certain properties are available to the methods being added.
        Class sharedAncestor = class_getSuperclass(aClass);
        if (![anObject isKindOfClass:sharedAncestor]) {
            NSLog(@"Target object %@ must be a subclass of %@.", anObject, sharedAncestor);
            return NO;
        }
        
        // Create new custom class
        targetClass = objc_allocateClassPair(object_getClass(anObject), _classNameForObjectWithSwizzlingClass(anObject, aClass).UTF8String, 0);
        
        // Add methods from source class
        if (!_class_addInstanceMethodsFromClass(targetClass, aClass)) {
            return NO;
        }
        
        // Custom class conforms to protocol
        BailUnless(class_addProtocol(targetClass, proto), NO);
        
        objc_registerClassPair(targetClass);
    }
    
    return targetClass;
}

static BOOL _alreadySwizzledObjectWithSwizzlingClass(id anObject, Class aClass)
{
    NSString *classPrefix = _prefixForSwizzlingClass(aClass);
    
    for(Class candidate = object_getClass(anObject); candidate != nil; candidate = class_getSuperclass(candidate)) {
        if ([[NSString stringWithUTF8String:class_getName(candidate)] hasPrefix:classPrefix]) {
            return YES;
        }
    }
    
    return NO;
}

static BOOL _object_swizzleIsa(id anObject, Class aClass)
{
    if (_alreadySwizzledObjectWithSwizzlingClass(anObject, aClass)) {
        return YES;
    }
    
    Class targetClass = _targetClassForObjectWithSwizzlingClass(anObject, aClass);
    
    if (!targetClass) {
        return NO;
    }
    
    object_setClass(anObject, targetClass);
    
    return YES;
}

BOOL nn_object_swizzleIsa(id anObject, Class aClass) {
    BOOL success = YES;
    
    @autoreleasepool {
        // Bootstrap the object with the necessary lies, like overriding -class to report the original class.
        if (!_alreadySwizzledObjectWithSwizzlingClass(anObject, [NNISASwizzledObject class])) {
            
            [NNISASwizzledObject prepareObjectForSwizzling:anObject];
            
            success = _object_swizzleIsa(anObject, [NNISASwizzledObject class]);
        }
        
        if (success) {
            success = _object_swizzleIsa(anObject, aClass);
        }
    }
    
    return success;
}
