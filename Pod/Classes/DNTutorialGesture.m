//
//  DNTutorialGesture.m
//  DNTutorial
//
//  Created by Daniel Niemeyer on 7/24/14.
//  Copyright (c) 2014 Daniel Niemeyer. All rights reserved.
//

#import "DNTutorialGesture.h"

NSInteger const sGesturePositionDelta = 150;

@interface DNTutorialGesture()

@property (nonatomic) CGPoint                                           startPosition;
@property (nonatomic, weak) CAShapeLayer                                *circleLayer;
@property (nonatomic, weak, setter = setBackgroundImage:) UIImage     *circleImage;

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
    
    // Check for backgroundImage
    if (_circleImage == nil)
    {
        // Add shadow
        layer.shadowColor = [UIColor blueColor].CGColor;
        layer.shadowOpacity = 0.75f;
        layer.shadowRadius = 5;
        layer.shadowOffset = CGSizeMake(0, 0);
        layer.shadowPath = layer.path;
    }
    else
    {
        layer.fillColor = nil;
        layer.contents = (id)_circleImage.CGImage;
    }
    
    // Add layer
    self.circleLayer = layer;
    [aView.layer addSublayer:layer];
}

- (void)tearDown;
{
    // Check if already dismissed
    if (_circleLayer.superlayer)
    {
        [_circleLayer removeFromSuperlayer];
    }
    _circleImage = nil;
    _circleLayer = nil;
}

#pragma mark --
#pragma mark - Polimorphic Methods
#pragma mark --

- (void)show;
{
    // Start animation
    _actionCompleted = NO;
    
    // Test
    //UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    //[_delegate willAnimateElement:self toInterfaceOrientation:interfaceOrientation duration:0.0];

    [self startAnimating];
}

- (void)dismiss;
{
    // Will dismiss element
    [_delegate willDismissElement:self];
    
    // Animate removal
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration = 0.2;
    opacityAnimation.fromValue = @(_circleLayer.opacity);
    opacityAnimation.toValue = @(0.0);
    opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [self stopAnimating];
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
    
    _percentageCompleted = percentage;
    
    if (percentage >= 1.0)
    {
        // User action completed
        [self setCompleted:YES animated:NO];
    }
}

- (DNTutorialAction)tutorialActions;
{
    if (self.gestureType >= DNTutorialGestureTypeSwipeUp && self.gestureType < DNTutorialGestureTypeScrollUp)
    {
        return DNTutorialActionSwipeGesture;
    }
    
    if (self.gestureType >= DNTutorialGestureTypeScrollUp && self.gestureType < DNTutorialGestureTypeTap)
    {
        return DNTutorialActionScroll;
    }
    
    return DNTutorialActionTapGesture | DNTutorialActionScroll | DNTutorialActionSwipeGesture;
}

- (void)startAnimating;
{
    // Check if can animate
    if (_actionCompleted || ![_delegate shouldAnimateElement:self])
    {
        return;
    }
    
    // Animations
    NSArray *animations;
    CGFloat multiplier = 1.2;
    
    // Calculate end point based on origin and direction
    CGPoint startPoint = self.startPosition;
    CGPoint endPoint = [self DNPointOffSet:startPoint delta:sGesturePositionDelta];
    
    CGRect startRect = self.circleLayer.bounds;
    CGRect endRect = CGRectZero;
    
    // Center function
    endRect.size.height = endRect.size.width = startRect.size.height * multiplier;
    endRect.origin.x = startRect.origin.x - (endRect.size.width - startRect.size.width)/2.0;
    endRect.origin.y = startRect.origin.y - (endRect.size.height - startRect.size.height)/2.0;
    
    // Animate path
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.duration = self.animationDuration*0.3;
    pathAnimation.fromValue = (id)[[UIBezierPath bezierPathWithOvalInRect:endRect] CGPath];
    pathAnimation.toValue = (id)[[UIBezierPath bezierPathWithOvalInRect:startRect] CGPath];
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    // Animate position
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimation.beginTime = self.animationDuration*0.4;
    positionAnimation.duration = self.animationDuration*0.6;
    positionAnimation.fromValue = [NSValue valueWithCGPoint:startPoint];
    positionAnimation.toValue = [NSValue valueWithCGPoint:endPoint];
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // Animate opacity
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration = self.animationDuration * 0.4;
    opacityAnimation.fromValue = @(0.0);
    opacityAnimation.toValue = @(1.0);
    opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOut.beginTime = opacityAnimation.duration;
    fadeOut.duration = self.animationDuration * 0.6;
    fadeOut.fromValue = @(1.0);
    fadeOut.toValue = @(0.0);
    fadeOut.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    animations = [NSArray arrayWithObjects:pathAnimation, positionAnimation, opacityAnimation, fadeOut, nil];
    
    // Animate tap
    if (self.gestureType == DNTutorialGestureTypeTap)
    {
        multiplier = 1.1;
        
        // Animate size
        pathAnimation.duration = self.animationDuration*0.4;
        pathAnimation.fromValue = (id)[[UIBezierPath bezierPathWithOvalInRect:startRect] CGPath];
        pathAnimation.toValue = (id)[[UIBezierPath bezierPathWithOvalInRect:endRect] CGPath];
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        shadowAnimation.duration = pathAnimation.duration;
        shadowAnimation.fromValue = pathAnimation.fromValue;
        shadowAnimation.toValue = pathAnimation.toValue;
        shadowAnimation.timingFunction = pathAnimation.timingFunction;
        
        CABasicAnimation *pathAnimation1 = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation1.duration = self.animationDuration*0.6;
        pathAnimation1.beginTime = pathAnimation.duration;
        pathAnimation1.fromValue = (id)[[UIBezierPath bezierPathWithOvalInRect:endRect] CGPath];
        pathAnimation1.toValue = (id)[[UIBezierPath bezierPathWithOvalInRect:startRect] CGPath];
        pathAnimation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CABasicAnimation *shadowAnimation1 = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        shadowAnimation1.beginTime = pathAnimation1.beginTime;
        shadowAnimation1.duration = pathAnimation1.duration;
        shadowAnimation1.fromValue = pathAnimation1.fromValue;
        shadowAnimation1.toValue = pathAnimation1.toValue;
        shadowAnimation1.timingFunction = pathAnimation1.timingFunction;
        
        animations = [NSArray arrayWithObjects:pathAnimation, shadowAnimation, pathAnimation1, shadowAnimation1, opacityAnimation, fadeOut, nil];
    }
    
    CAAnimationGroup *opacityGroup = [CAAnimationGroup animation];
    opacityGroup.animations = animations;
    opacityGroup.repeatCount = HUGE_VALF;
    opacityGroup.duration = self.animationDuration*multiplier;
    [self.circleLayer addAnimation:opacityGroup forKey:@"gestureAnimation"];
}

- (void)stopAnimating;
{
    // Stop animating
    [_circleLayer removeAnimationForKey:@"gestureAnimation"];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    
}

#pragma mark --
#pragma mark - Public Methods
#pragma mark --

- (void)setPosition:(CGPoint)point;
{
    if (!CGPointEqualToPoint(_startPosition, point))
    {
        _startPosition = point;
        _circleLayer.position = point;
        
        if ([_circleLayer animationForKey:@"gestureAnimation"])
        {
            [self stopAnimating];
            [self startAnimating];
        }
    }
}

- (void)setBackgroundImage:(UIImage *)image;
{
    _circleImage = image;
    _circleLayer.fillColor = nil;
    _circleLayer.contents = (id)image.CGImage;
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
        case DNTutorialGestureTypeScrollUp:
            origin.y -= delta;
            break;
        case DNTutorialGestureTypeScrollRight:
            origin.x += delta;
            break;
        case DNTutorialGestureTypeScrollDown:
            origin.y += delta;
            break;
        case DNTutorialGestureTypeScrollLeft:
            origin.x -= delta;
            break;
        default:
            break;
    }
    
    return origin;
}

@end
