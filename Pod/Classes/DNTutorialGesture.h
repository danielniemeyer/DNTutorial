//
//  DNTutorialGesture.h
//  DNTutorial
//
//  Created by Daniel Niemeyer on 7/24/14.
//  Copyright (c) 2014 Daniel Niemeyer. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "DNTutorialElement.h"

typedef NS_ENUM (NSUInteger, DNTutorialGestureDirection)
{
    DNTutorialGestureDirectionUp = 0,
    DNTutorialGestureDirectionRight = 1,
    DNTutorialGestureDirectionDown = 2,
    DNTutorialGestureDirectionLeft = 3
};

@interface DNTutorialGesture : DNTutorialElement

@property (nonatomic) CGFloat                               animationDuration;
@property (nonatomic, assign) DNTutorialGestureDirection    gestureDirection;


// Instantiate a new gesture tutorial with the given position and animation direction
+ (id)gestureWithPosition:(CGPoint)point
              direction:(DNTutorialGestureDirection)direction
                    key:(NSString *)key;

@end
