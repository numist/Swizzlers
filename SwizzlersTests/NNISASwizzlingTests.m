//
//  NNISASwizzlingTests.m
//  Swizzlers
//
//  Created by Scott Perry on 02/07/13.
//  Copyright (c) 2013 Scott Perry. All rights reserved.
//

#import "NNISASwizzlingTests.h"

#import <Swizzlers/Swizzlers.h>

// Class ISANoComply doesn't comply to its protocol and cannot be used for swizzling
@protocol ISANoComply <NSObject> - (void)foo; @end
@interface ISANoComply : NSObject @end
@implementation ISANoComply - (void)foo { NSLog(@"foooooo! "); } @end


// Class ISAGood can be used for swizzling any NSObject
@protocol ISAGood <NSObject> - (void)foo; @end
@interface ISAGood : NSObject <ISAGood, ISANoComply> @end // Complies to ISANoComply to prevent the protocol from being culled by the compiler as a dead symbol
@implementation ISAGood - (void)foo { NSLog(@"foooooo! "); } - (void)doesNotRecognizeSelector:(__attribute__((unused)) SEL)aSelector { NSLog(@"FAUX NOES!"); } @end


// Class ISANoSharedAncestor can only be used to swizzle instances that areKindOf NSArray
@protocol ISANoSharedAncestor <NSObject> - (void)foo; @end
@interface ISANoSharedAncestor : NSArray <ISANoSharedAncestor> @end
@implementation ISANoSharedAncestor - (void)foo { NSLog(@"foooooo! "); } @end


// Class ISANoProtocol doesn't have a corersponding protocol and cannot be used for swizzling
@interface ISANoProtocol : NSObject @end
@implementation ISANoProtocol - (void)foo { NSLog(@"foooooo! "); } @end


@implementation NNISASwizzlingTests

- (void)testInteractionWithKVO;
{
    STFail(@"NOT TESTED");
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

- (void)testNoComply;
{
    NSObject *bar = [[NSObject alloc] init];
    
    STAssertFalse(nn_object_swizzleIsa(bar, [ISANoComply class]), @"Failed to fail to swizzle object");
}

- (void)testNoProto;
{
    NSObject *bar = [[NSObject alloc] init];

    STAssertFalse(nn_object_swizzleIsa(bar, [ISANoProtocol class]), @"Failed to fail to swizzle object");
}

- (void)testImplementationDetails;
{
    NSObject *bar = [[NSObject alloc] init];
    
    STAssertFalse([bar respondsToSelector:@selector(actualClass)], @"Object is not virgin");
    STAssertThrows([bar performSelector:@selector(actualClass)], @"actualClass exists?");
    
    STAssertTrue(nn_object_swizzleIsa(bar, [ISAGood class]), @"Failed to swizzle object");
    
    STAssertTrue([bar respondsToSelector:@selector(actualClass)], @"Object is not swizzled correctly");
    STAssertNoThrow([bar performSelector:@selector(actualClass)], @"Internal swizzle method actualClass not implemented?");
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
    
    STAssertTrue([bar respondsToSelector:@selector(foo)], @"Object is not swizzled correctly");
    
    STAssertNoThrow([(id<ISAGood>)bar foo], @"foooooo!");
    STAssertNoThrow([bar doesNotRecognizeSelector:nil], @"FAUX NOES!");
    
    STAssertEquals([bar class], [NSObject class], @"Object should report itself as still being an NSObject");
}

@end
