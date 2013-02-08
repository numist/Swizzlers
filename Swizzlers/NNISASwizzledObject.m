//
//  NNISASwizzledObject.m
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

#import "NNISASwizzledObject.h"

#import <objc/runtime.h>

static void *_NNSwizzleSuperclassKey = (void *)1466409828; // arc4rand(), since the address of _NNSwizzleBaseClass isn't obviously available at compile time.

@implementation NNISASwizzledObject

+ (void)prepareObjectForSwizzling:(NSObject *)anObject;
{
    // Cache the original value of -class so the swizzled object can lie about itself later.
    objc_setAssociatedObject(anObject, _NNSwizzleSuperclassKey, [anObject class], OBJC_ASSOCIATION_ASSIGN);
}

- (Class)class
{
    Class superclass = objc_getAssociatedObject(self, _NNSwizzleSuperclassKey);
    
    if (!superclass) {
        NSLog(@"ERROR: couldn't find stashed superclass for swizzled object, falling back to parent class—if you're using KVO, this might break everything!");
        return class_getSuperclass(object_getClass(self));
    }
    
    return superclass;
}

- (Class)actualClass
{
    return object_getClass(self);
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    if ([[self actualClass] conformsToProtocol:aProtocol]) {
        return YES;
    }
    
    return [super conformsToProtocol:aProtocol];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([[self actualClass] instancesRespondToSelector:aSelector]) {
        return YES;
    }
    
    return [super respondsToSelector:aSelector];
}

@end
