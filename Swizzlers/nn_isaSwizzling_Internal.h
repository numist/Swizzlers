//
//  nn_isaSwizzling.h
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

#import "nn_isaSwizzling.h"

static NSString *_prefixForSwizzlingClass(Class aClass) __attribute__((nonnull(1), pure));
static __autoreleasing NSString * _classNameForObjectWithSwizzlingClass(id anObject, Class aClass) __attribute__((nonnull(1, 2), pure));

static BOOL _class_addInstanceMethodsFromClass(Class target, Class source) __attribute__((nonnull(1, 2)));
static BOOL _class_containsNonDynamicProperties(Class aClass) __attribute__((nonnull(1)));
static BOOL _class_containsIvars(Class aClass) __attribute__((nonnull(1)));
static Class _targetClassForObjectWithSwizzlingClass(id anObject, Class aClass) __attribute__((nonnull(1, 2)));
static BOOL _alreadySwizzledObjectWithSwizzlingClass(id anObject, Class aClass) __attribute__((nonnull(1, 2)));
static BOOL _object_swizzleIsa(id anObject, Class aClass) __attribute__((nonnull(1, 2)));
