//
//  DNTutorialGesture.m
//  DNTutorial
//
//  Created by Daniel Niemeyer on 7/24/14.
//  Copyright (c) 2014 Daniel Niemeyer. All rights reserved.
//

#import "DNTutorialGesture.h"

@interface DNTutorialGesture()

@property (nonatomic) CGPoint                               startPosition;
@property (nonatomic, weak) CAShapeLayer                    *circleLayer;

@end

@implementation DNTutorialGesture

#pragma mark --
#pragma mark - Initialization
#pragma mark --

+ (id)gestureWithPosition:(CGPoint)point
              direction:(DNTutorialGestureDirection)direction
                    key:(NSString *)key;
{
    // Proper initialization
    NSAssert(key != nil, @"DNTutorialGesture: Cannot initialize action with invalid key");
    
    // Init view
    DNTutorialGesture *view = [DNTutorialGesture new];
    view.key = key;
    view.startPosition = point;
    view.gestureDirection = direction;
    view.animationDuration = 1.5;
    return view;
}

- (void)setUpInView:(UIView *)aView;
{
    // Initialize container view
    CGRect frame = CGRectMake(0, 0, 50, 50);
    
    UIView *view = [UIView new];
    view.frame = frame;
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.bounds = frame;
    layer.path = [UIBezierPath bezierPathWithOvalInRect:frame].CGPath;
    layer.fillColor = [UIColor lightGrayColor].CGColor;
    layer.opacity = 0.0;
    layer.position = self.startPosition;
    layer.shadowColor = [UIColor blueColor].CGColor;
    layer.shadowOpacity = 0.75f;
    layer.shadowRadius = 5;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowPath = layer.path;
    
    // Add layer
    self.circleLayer = layer;
    [view.layer addSublayer:layer];
    [aView addSubview:view];
    
    // Override view
    _containerView = view;    
}

- (void)tearDown;
{
    _circleLayer = nil;
    _containerView = nil;
}

#pragma mark --
#pragma mark - Polimorphic Methods
#pragma mark --

- (void)show;
{
    // Start animation
    _containerView.alpha = 1.0f;
    _actionCompleted = NO;

    [self startAnimating];
}

- (void)dismiss;
{
    // Check if already dismissed
    if (!_containerView.superview) {
        return;
    }
    
    // Notify delegate of dismissal
    if ([_delegate respondsToSelector:@selector(willDismissElement:)])
    {
        [_delegate willDismissElement:self];
    }
    
    // Animate removal
    [UIView animateWithDuration:0.2 animations:^{
        _containerView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if ([_delegate respondsToSelector:@selector(didDismissElement:)])
        {
            [_delegate didDismissElement:self];
        }
    }];
    
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if ([_delegate shouldDismissElement:self])
            {
                [self dismiss];
            }
        });
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
    return DNTutorialActionGesture;
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
    switch (self.gestureDirection) {
        case DNTutorialGestureDirectionUp:
            origin.y -= delta;
            break;
        case DNTutorialGestureDirectionRight:
            origin.x += delta;
            break;
        case DNTutorialGestureDirectionDown:
            origin.y += delta;
            break;
        case DNTutorialGestureDirectionLeft:
            origin.x -= delta;
            break;
    }
    
    return origin;
}

@end
