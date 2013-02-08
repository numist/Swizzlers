//
//  nn_isaSwizzling.m
//  Swizzlers
//
//  Created by Scott Perry on 02/07/13.
//  Copyright © 2013 Scott Perry.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "nn_isaSwizzling_Private.h"

#import <objc/runtime.h>

#import "NNISASwizzledObject.h"


static NSString *_prefixForSwizzlingClass(Class aClass) __attribute__((nonnull(1), pure));
static __autoreleasing NSString * _classNameForObjectWithSwizzlingClass(id anObject, Class aClass) __attribute__((nonnull(1, 2), pure));
static BOOL _class_addInstanceMethodsFromClass(Class target, Class source) __attribute__((nonnull(1, 2)));
static BOOL _class_addProtocolsFromClass(Class targetClass, Class aClass) __attribute__((nonnull(1,2)));
static BOOL _class_containsNonDynamicProperties(Class aClass) __attribute__((nonnull(1)));
static BOOL _class_containsIvars(Class aClass) __attribute__((nonnull(1)));
static Class _targetClassForObjectWithSwizzlingClass(id anObject, Class aClass) __attribute__((nonnull(1, 2)));
static BOOL _object_swizzleIsa(id anObject, Class aClass) __attribute__((nonnull(1, 2)));


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
    Method method;
    
    for (NSUInteger i = 0; methods && (method = methods[i]); i++) {
        // targetClass is a brand new shiny class, so this should never fail because it already implements a method (even though its superclass(es) might).
        BailWithGotoUnless(class_addMethod(target, method_getName(method), method_getImplementation(method), method_getTypeEncoding(method)), finished);
    }
    
    success = YES;
finished:
    free(methods); methods = NULL;
    return success;
}

static BOOL _class_addProtocolsFromClass(Class targetClass, Class aClass)
{
    BOOL success = NO;
    Protocol * __unsafe_unretained *protocols = class_copyProtocolList(aClass, NULL);
    Protocol __unsafe_unretained *protocol;
    
    for (NSUInteger i = 0; protocols && (protocol = protocols[i]); i++) {
        // targetClass is a brand new shiny class, so this should never fail because it already conforms to a protocol (even though its superclass(es) might).
        BailWithGotoUnless(class_addProtocol(targetClass, protocol), finished);
    }
    
    success = YES;
finished:
    free(protocols);
    return success;
}

static BOOL _class_containsNonDynamicProperties(Class aClass)
{
    objc_property_t *properties = class_copyPropertyList(aClass, NULL);
    BOOL propertyIsDynamic = NO;
    
    for (unsigned i = 0; properties && properties[i]; i++) {
        char *attributes = strdup(property_getAttributes(properties[i]));
        char *token;
        
        // For more information about the property type string, see the Declared Properties section of the Objective-C Runtime Programming Guide
        while ((token = strsep(&attributes, ",")) != NULL) {
            if (strlen(token) > 1) continue;
            
            NSLog(@"%s", token);
            if (!strcmp(token, "D")) { // The property is dynamic (@dynamic).
                propertyIsDynamic = YES;
                break;
            }
        }
        
        free(attributes); attributes = NULL;
        
        if (!propertyIsDynamic) {
            NSLog(@"Swizzling class %s cannot contain non-dynamic properties", class_getName(aClass));
            free(properties);
            return YES;
        }
    }
    
    free(properties); properties = NULL;
    return NO;
}

static BOOL _class_containsIvars(Class aClass)
{
    unsigned ivars;
    free(class_copyIvarList(aClass, &ivars));
    return ivars != 0;
}

static Class _targetClassForObjectWithSwizzlingClass(id anObject, Class aClass)
{
    Class targetClass = objc_getClass(_classNameForObjectWithSwizzlingClass(anObject, aClass).UTF8String);
    
    if (!targetClass) {
        // obj must be subclass of class' superclass to guarantee that certain properties are available to the methods being added.
        Class sharedAncestor = class_getSuperclass(aClass);
        if (![anObject isKindOfClass:sharedAncestor]) {
            NSLog(@"Target object %@ must be a subclass of %@.", anObject, sharedAncestor);
            return NO;
        }
        
        // Swizzling class must not contain any uninherited properties
        if (_class_containsNonDynamicProperties(aClass)) {
            NSLog(@"Swizzling class %s cannot contain non-dynamic properties", class_getName(aClass));
            return NO;
        }
        
        // Swizzling class must not contain any uninherited ivars
        if (_class_containsIvars(aClass)) {
            NSLog(@"Swizzling class %s cannot contain ivars not inherited from its superclass", class_getName(aClass));
            return NO;
        }
        
        // Create new custom class
        targetClass = objc_allocateClassPair(object_getClass(anObject), _classNameForObjectWithSwizzlingClass(anObject, aClass).UTF8String, 0);
        
        // Add methods from source class
        if (!_class_addInstanceMethodsFromClass(targetClass, aClass)) {
            return NO;
        }
        
        // Custom class conforms to protocol
        if (!_class_addProtocolsFromClass(targetClass, aClass)) {
            return NO;
        }
        
        objc_registerClassPair(targetClass);
    }
    
    return targetClass;
}

static BOOL _object_swizzleIsa(id anObject, Class aClass)
{
    if (nn_alreadySwizzledObjectWithSwizzlingClass(anObject, aClass)) {
        return YES;
    }
    
    Class targetClass = _targetClassForObjectWithSwizzlingClass(anObject, aClass);
    
    if (!targetClass) {
        return NO;
    }
    
    object_setClass(anObject, targetClass);
    
    return YES;
}

#pragma mark Privately-exported functions

BOOL nn_alreadySwizzledObjectWithSwizzlingClass(id anObject, Class aClass)
{
    NSString *classPrefix = _prefixForSwizzlingClass(aClass);
    
    for(Class candidate = object_getClass(anObject); candidate != nil; candidate = class_getSuperclass(candidate)) {
        if ([[NSString stringWithUTF8String:class_getName(candidate)] hasPrefix:classPrefix]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark Publicly-exported funtions

BOOL nn_object_swizzleIsa(id anObject, Class aClass) {
    BOOL success = YES;
    
    @autoreleasepool {
        // Bootstrap the object with the necessary lies, like overriding -class to report the original class.
        if (!nn_alreadySwizzledObjectWithSwizzlingClass(anObject, [NNISASwizzledObject class])) {
            [NNISASwizzledObject prepareObjectForSwizzling:anObject];
            
            success = _object_swizzleIsa(anObject, [NNISASwizzledObject class]);
        }
        
        if (success) {
            success = _object_swizzleIsa(anObject, aClass);
        }
    }
    
    return success;
}
