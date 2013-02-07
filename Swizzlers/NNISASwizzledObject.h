//
//  NNISASwizzledObject.h
//  Swizzlers
//
//  Created by Scott Perry on 02/07/13.
//  Copyright (c) 2013 Scott Perry. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NNISASwizzledObject <NSObject> @end

@interface NNISASwizzledObject : NSObject <NNISASwizzledObject>

+ (void)prepareObjectForSwizzling:(NSObject *)anObject;

@end
