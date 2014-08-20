//
//  DNTutorialGesture.h
//  DNTutorial
//
//  Created by Daniel Niemeyer on 7/24/14.
//  Copyright (c) 2014 Daniel Niemeyer. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "DNTutorialElement.h"

typedef NS_ENUM (NSUInteger, DNTutorialGestureType)
{
    DNTutorialGestureTypeSwipeUp = 0,
    DNTutorialGestureTypeSwipeRight = 1,
    DNTutorialGestureTypeSwipeDown = 2,
    DNTutorialGestureTypeSwipeLeft = 3,
    DNTutorialGestureTypeScrollUp = 4,
    DNTutorialGestureTypeScrollRight = 5,
    DNTutorialGestureTypeScrollDown = 6,
    DNTutorialGestureTypeScrollLeft = 7,
    DNTutorialGestureTypeTap = 8,
    DNTutorialGestureTypeDoubleTap = 9,
};

@interface DNTutorialGesture : DNTutorialElement

@property (nonatomic) CGFloat                          animationDuration;
@property (nonatomic, assign) DNTutorialGestureType    gestureType;


// Instantiate a new gesture tutorial with the given position and animation direction
+ (id)gestureWithPosition:(CGPoint)point
                     type:(DNTutorialGestureType)type
                      key:(NSString *)key;


// Sets the center position
- (void)setPosition:(CGPoint)point;


// Sets the background image
- (void)setBackgroundImage:(UIImage *)image;

@end
