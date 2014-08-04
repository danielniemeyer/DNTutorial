//
//  DNTutorialGesture.m
//  DNTutorial
//
//  Created by Daniel Niemeyer on 7/24/14.
//  Copyright (c) 2014 Daniel Niemeyer. All rights reserved.
//

#import "DNTutorialGesture.h"

@interface DNTutorialGesture()

@property (nonatomic) CGPoint                   startPosition;
@property (nonatomic, weak) CAShapeLayer        *circleLayer;

@end

@implementation DNTutorialGesture

#pragma mark --
#pragma mark - Initialization
#pragma mark --

+ (id)gestureWithPosition:(CGPoint)point
                     type:(DNTutorialGestureType)type
                    key:(NSString *)key;
{
    // Proper initialization
    NSAssert(key != nil, @"DNTutorialGesture: Cannot initialize action with invalid key");
    
    // Init view
    DNTutorialGesture *view = [DNTutorialGesture new];
    view.key = key;
    view.startPosition = point;
    view.gestureType = type;
    view.animationDuration = 1.5;
    return view;
}

- (void)setUpInView:(UIView *)aView;
{
    // Initialize container view
    CGRect frame = CGRectMake(0, 0, 50, 50);
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.bounds = frame;
    layer.path = [UIBezierPath bezierPathWithOvalInRect:frame].CGPath;
    layer.fillColor = [UIColor whiteColor].CGColor;
    layer.opacity = 0.0;
    layer.position = self.startPosition;
    layer.shadowColor = [UIColor blueColor].CGColor;
    layer.shadowOpacity = 0.75f;
    layer.shadowRadius = 5;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowPath = layer.path;
    
    // Add layer
    self.circleLayer = layer;
    [aView.layer addSublayer:layer];
}

- (void)tearDown;
{
    [_circleLayer removeFromSuperlayer];
    _circleLayer = nil;
}

#pragma mark --
#pragma mark - Polimorphic Methods
#pragma mark --

- (void)show;
{
    // Start animation
    _actionCompleted = NO;

    [self startAnimating];
}

- (void)dismiss;
{
    // Check if already dismissed
    if (!_circleLayer.superlayer) {
        return;
    }
    
    // Animate removal
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration = 0.2;
    opacityAnimation.fromValue = @(_circleLayer.opacity);
    opacityAnimation.toValue = @(0.0);
    opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [_circleLayer addAnimation:opacityAnimation forKey:@"opacity"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, opacityAnimation.duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_delegate didDismissElement:self];
    });
}

- (void)setCompleted:(BOOL)completed animated:(BOOL)animated;
{
    if (_actionCompleted && completed) {
        return;
    }
    
    _actionCompleted = completed;
    
    if (completed)
    {
        // Should dismiss
        [self dismiss];
    }
}

- (void)setPercentageCompleted:(CGFloat)percentage;
{
    // percentage alpha and position based on position
    if (percentage < 0 || _actionCompleted)
    {
        return;
    }
    
    if (percentage >= 1.0)
    {
        // User action completed
        [self setCompleted:YES animated:NO];
    }
}

- (DNTutorialAction)tutorialActions;
{
    if (self.gestureType == DNTutorialGestureTypeTap || self.gestureType == DNTutorialGestureTypeDoubleTap)
    {
        return DNTutorialActionTapGesture | DNTutorialActionScroll;
    }
    
    return DNTutorialActionSwipeGesture | DNTutorialActionScroll;
}


#pragma mark --
#pragma mark - Public Methods
#pragma mark --

- (void)startAnimating;
{
    // Check if can animate
    if (_actionCompleted)
    {
        return;
    }
    
    // Calculate end point based on origin and direction
    CGPoint startPoint = self.startPosition;
    CGPoint endPoint = [self DNPointOffSet:startPoint delta:100];

    // Animate position
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    pathAnimation.duration = self.animationDuration;
    pathAnimation.fromValue = [NSValue valueWithCGPoint:startPoint];
    pathAnimation.toValue = [NSValue valueWithCGPoint:endPoint];
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // Animate opacity
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration = self.animationDuration * 0.9;
    opacityAnimation.fromValue = @(0.0);
    opacityAnimation.toValue = @(1.0);
    opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOut.duration = self.animationDuration * 0.1;
    fadeOut.fromValue = @(1.0);
    fadeOut.toValue = @(0.0);
    fadeOut.beginTime = opacityAnimation.duration;
    fadeOut.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CAAnimationGroup *opacityGroup = [CAAnimationGroup animation];
    opacityGroup.animations = @[pathAnimation, opacityAnimation, fadeOut];
    opacityGroup.repeatCount = HUGE_VALF;
    opacityGroup.duration = self.animationDuration;
    [self.circleLayer addAnimation:opacityGroup forKey:@"gestureAnimation"];
}

- (void)stopAnimating;
{
    // Stop animating
    [self.circleLayer removeAnimationForKey:@"gestureAnimation"];
}

#pragma mark --
#pragma mark - Private Methods
#pragma mark --

- (CGPoint)DNPointOffSet:(CGPoint)origin delta:(CGFloat)delta;
{
    switch (self.gestureType) {
        case DNTutorialGestureTypeSwipeUp:
            origin.y -= delta;
            break;
        case DNTutorialGestureTypeSwipeRight:
            origin.x += delta;
            break;
        case DNTutorialGestureTypeSwipeDown:
            origin.y += delta;
            break;
        case DNTutorialGestureTypeSwipeLeft:
            origin.x -= delta;
            break;
        default:
            break;
    }
    
    return origin;
}

@end
