//
//  NNISASwizzlingTests.m
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

#import "NNISASwizzlingTests.h"

#import <Swizzlers/Swizzlers.h>
#import <Foundation/Foundation.h>

// Class ISAGood can be used for swizzling any NSObject
@protocol ISAGood <NSObject> - (void)foo; @end
@interface ISAGood : NSObject <ISAGood> @end
@implementation ISAGood - (void)foo { NSLog(@"foooooo! "); } - (void)doesNotRecognizeSelector:(__attribute__((unused)) SEL)aSelector { NSLog(@"FAUX NOES!"); } @end


// Class ISANoSharedAncestor can only be used to swizzle instances that areKindOf NSArray
@protocol ISANoSharedAncestor <NSObject> - (void)foo; @end
@interface ISANoSharedAncestor : NSArray <ISANoSharedAncestor> @end
@implementation ISANoSharedAncestor - (void)foo { NSLog(@"foooooo! "); } @end


// Class ISANoProtocol doesn't have a corersponding protocol and cannot be used for swizzling
@interface ISANoProtocol : NSObject @end
@implementation ISANoProtocol - (void)foo { NSLog(@"foooooo! "); } @end


// Class ISAAddsProperties adds properties to its superclass and thus cannot be used for swizzling
@protocol ISAAddsProperties <NSObject> - (void)foo; @end
@interface ISAAddsProperties : NSObject <ISAAddsProperties> @property (nonatomic, assign) NSUInteger bar; @end
@implementation ISAAddsProperties - (void)foo { NSLog(@"foooooo! "); } @end


// Class ISAAddsProperties adds properties to its superclass and thus cannot be used for swizzling
@protocol ISAAddsLegalProperties <NSObject> @end
@interface ISAAddsLegalProperties : NSObject <ISAAddsLegalProperties> @property (nonatomic, assign) NSUInteger bar; @end
@implementation ISAAddsLegalProperties @dynamic bar; - (NSUInteger)bar { NSLog(@"foooooo! "); return 7; } @end


// Class ISAAddsIvars adds ivars to its superclass and thus cannot be used for swizzling
@protocol ISAAddsIvars <NSObject> - (void)foo; @end
@interface ISAAddsIvars : NSObject <ISAAddsIvars> { NSUInteger bar; } @end
@implementation ISAAddsIvars - (void)foo { NSLog(@"foooooo! "); } @end


// Class ISAExtraProtocol adds an extra protocol that the swizzled object must conform to.
@protocol ISAExtraProtocol <NSObject> - (void)foo; @end
@interface ISAExtraProtocol : NSObject <ISAExtraProtocol, NSCacheDelegate> @end
@implementation ISAExtraProtocol - (void)foo { NSLog(@"foooooo! "); } @end


@implementation NNISASwizzlingTests

- (void)testInteractionWithKVO;
{
    STFail(@"NOT TESTED");
}

- (void)testExtraProtocol;
{
    NSObject *bar = [[NSObject alloc] init];
    
    STAssertFalse([bar conformsToProtocol:@protocol(ISAExtraProtocol)], @"Object is not virgin");
    
    STAssertTrue(nn_object_swizzleIsa(bar, [ISAExtraProtocol class]), @"Failed to swizzle object");
    
    STAssertTrue([bar conformsToProtocol:@protocol(ISAExtraProtocol)], @"Object is not swizzled correctly");
    STAssertTrue([bar conformsToProtocol:@protocol(NSCacheDelegate)], @"Object is missing extra protocol");
}

- (void)testAddsProperties;
{
    NSObject *bar = [[NSObject alloc] init];
    
    STAssertFalse(nn_object_swizzleIsa(bar, [ISAAddsProperties class]), @"Failed to fail to swizzle object");
}

- (void)testAddsLegalProperties;
{
    NSObject *bar = [[NSObject alloc] init];
    
    STAssertTrue(nn_object_swizzleIsa(bar, [ISAAddsLegalProperties class]), @"Failed to swizzle object");
    STAssertEquals(((ISAAddsLegalProperties *)bar).bar, (NSUInteger)7, @"Oops properties");
}

- (void)testAddsIvars;
{
    NSObject *bar = [[NSObject alloc] init];
    
    STAssertFalse(nn_object_swizzleIsa(bar, [ISAAddsIvars class]), @"Failed to fail to swizzle object");
}

- (void)testDoubleSwizzle;
{
    NSObject *bar = [[NSObject alloc] init];
    
    STAssertFalse([bar conformsToProtocol:@protocol(ISAGood)], @"Object is not virgin");
    STAssertFalse([bar respondsToSelector:@selector(foo)], @"Object is not virgin");
    
    STAssertThrows([(id<ISAGood>)bar foo], @"foooooo!");
    STAssertThrows([bar doesNotRecognizeSelector:nil], @"FAUX NOES!");
    
    STAssertTrue(nn_object_swizzleIsa(bar, [ISAGood class]), @"Failed to swizzle object");
    STAssertTrue(nn_object_swizzleIsa(bar, [ISAGood class]), @"Failed to swizzle object");
    
    STAssertTrue([bar conformsToProtocol:@protocol(ISAGood)], @"Object is not swizzled correctly");
    
    STAssertTrue([bar respondsToSelector:@selector(foo)], @"Object is not swizzled correctly");
    
    STAssertNoThrow([(id<ISAGood>)bar foo], @"foooooo!");
    STAssertNoThrow([bar doesNotRecognizeSelector:nil], @"FAUX NOES!");
    
    STAssertEquals([bar class], [NSObject class], @"Object should report itself as still being an NSObject");
}

- (void)testSharedAncestor;
{
    NSObject *bar = [[NSObject alloc] init];
    NSArray *arr = [[NSArray alloc] init];
    
    STAssertFalse(nn_object_swizzleIsa(bar, [ISANoSharedAncestor class]), @"Failed to fail to swizzle object");
    STAssertTrue(nn_object_swizzleIsa(arr, [ISANoSharedAncestor class]), @"Failed to swizzle object");
}

- (void)testNoProto;
{
    NSObject *bar = [[NSObject alloc] init];

    STAssertTrue(nn_object_swizzleIsa(bar, [ISANoProtocol class]), @"Failed to swizzle object");
}

- (void)testImplementationDetails;
{
    NSObject *bar = [[NSObject alloc] init];
    
    STAssertFalse([bar respondsToSelector:@selector(actualClass)], @"Object is not virgin");
    STAssertThrows([bar performSelector:@selector(actualClass)], @"actualClass exists?");
    
    STAssertTrue(nn_object_swizzleIsa(bar, [ISAGood class]), @"Failed to swizzle object");
    
    STAssertTrue([bar respondsToSelector:@selector(_swizzler_actualClass)], @"Object is not swizzled correctly");
    STAssertNoThrow([bar performSelector:@selector(_swizzler_actualClass)], @"Internal swizzle method actualClass not implemented?");
}

- (void)testGood;
{
    NSObject *bar = [[NSObject alloc] init];
    
    STAssertFalse([bar conformsToProtocol:@protocol(ISAGood)], @"Object is not virgin");
    STAssertFalse([bar respondsToSelector:@selector(foo)], @"Object is not virgin");
    
    STAssertThrows([(id<ISAGood>)bar foo], @"foooooo!");
    STAssertThrows([bar doesNotRecognizeSelector:nil], @"FAUX NOES!");
    
    STAssertTrue(nn_object_swizzleIsa(bar, [ISAGood class]), @"Failed to swizzle object");
    
    STAssertTrue([bar conformsToProtocol:@protocol(ISAGood)], @"Object is not swizzled correctly");
    STAssertTrue([bar isKindOfClass:[ISAGood class]], @"Object is not swizzled correctly");
    
    STAssertTrue([bar respondsToSelector:@selector(foo)], @"Object is not swizzled correctly");
    
    STAssertNoThrow([(id<ISAGood>)bar foo], @"foooooo!");
    STAssertNoThrow([bar doesNotRecognizeSelector:nil], @"FAUX NOES!");
    
    STAssertEquals([bar class], [NSObject class], @"Object should report itself as still being an NSObject");
}

@end
