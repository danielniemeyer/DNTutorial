//
//  DNTutorialBanner.m
//  DNTutorial
//
//  Created by Daniel Niemeyer on 7/24/14.
//  Copyright (c) 2014 Daniel Niemeyer. All rights reserved.
//

#import "DNTutorialBanner.h"


@interface DNTutorialBanner()

@property (nonatomic, weak) CAShapeLayer                    *circleLayer;
@property (nonatomic, weak) UILabel                         *messagelabel;
@property (nonatomic, weak) UIButton                        *closeButton;

@property (nonatomic, strong) UIView                        *containerView;
@property (nonatomic, strong) NSString                      *message;
@property (nonatomic, strong) NSString                      *completedMessage;

@property (nonatomic, strong,setter = setBannerFont:)UIFont *messageFont;
@property (nonatomic, setter = setBannerColor:) UIColor     *backgroundColor;
@property (nonatomic, strong) UIColor                       *completedColor;
@property (nonatomic, setter = setBannerOpacity:) CGFloat   opacity;

@end

@implementation DNTutorialBanner

#pragma mark --
#pragma mark - Initialization
#pragma mark --

+ (id)bannerWithMessage:(NSString *)message
      completionMessage:(NSString *)completionMessage
                  key:(NSString *)key;
{
    // Proper initialization
    NSAssert(key != nil, @"DNTutorialGesture: Cannot initialize action with invalid key");
    
    // Init view
    DNTutorialBanner *banner = [DNTutorialBanner new];
    banner.opacity = 0.85;
    banner.backgroundColor = [UIColor lightGrayColor];
    banner.completedColor = [UIColor greenColor];
    banner.key = key;
    banner.message = message;
    banner.completedMessage = completionMessage;
    banner.messageFont = [UIFont systemFontOfSize:17];
    
    return banner;
}

#pragma mark --
#pragma mark - Polimorphic Methods
#pragma mark --

- (void)setUpInView:(UIView *)aView;
{
    // Initialize container view
    UIView *view = [UIView new];
    
    // Default banner size
    CGFloat screenHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
    CGFloat screenWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    CGRect frame = CGRectMake(0, screenHeight, screenWidth, 80);
    
    view.frame = frame;
    view.alpha = _opacity;
    view.backgroundColor = _backgroundColor;
    view.layer.masksToBounds = YES;
    
    // Shape layer
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.fillColor = [self.completedColor CGColor];
    circleLayer.opacity = 0.0;
    [view.layer addSublayer:circleLayer];
    self.circleLayer = circleLayer;
    
    // Message label
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, screenWidth-60, CGRectGetHeight(frame))];
    messageLabel.text = self.message;
    messageLabel.font = self.messageFont;
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.numberOfLines = 0;
    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [view addSubview:messageLabel];
    self.messagelabel = messageLabel;
    
    // Close button
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(CGRectGetWidth(messageLabel.frame) + 20, 0, 40, CGRectGetHeight(frame));
    [closeButton setImage:[UIImage imageNamed:@"bannerClose"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:closeButton];
    self.closeButton = closeButton;
    
    // Add subview
    [aView addSubview:view];
    _containerView = view;
    
    // Check completed
    if (_actionCompleted)
    {
        [self setCompleted:YES animated:NO];
    }
}

- (void)tearDown;
{
    [_containerView removeFromSuperview];
    
    _message = nil;
    _messagelabel = nil;
    _closeButton = nil;
    _circleLayer = nil;
    _containerView = nil;
}

- (void)show;
{
    _actionCompleted = NO;
    
    // Animate entrance
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _containerView.frame = CGRectOffset(_containerView.frame, 0, -CGRectGetHeight(_containerView.frame));
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)dismiss;
{
    // Check if already dismissed
    if (!_containerView.superview) {
        return;
    }
    
    // Notify delegate of dismissal
    [_delegate willDismissElement:self];
    
    // Animate removal
    [UIView animateWithDuration:0.2 animations:^{
        _containerView.frame = CGRectOffset(_containerView.frame, 0, CGRectGetHeight(_containerView.frame));
    } completion:^(BOOL finished)
     {
        [_delegate didDismissElement:self];
    }];

}

- (void)setCompleted:(BOOL)completed animated:(BOOL)animated;
{
    // Animate to completed state
    if (_actionCompleted && completed && animated) {
        return;
    }
    
    _actionCompleted = completed;
    
    if (completed)
    {
        if (animated) {
            [self animateToCompletedState];
        }
        else
        {
            _containerView.backgroundColor = _completedColor;
            self.circleLayer.opacity = 0.0;
        }
        
        if (!_completedMessage || _completedMessage.length > 0)
        {
            [self.messagelabel setText:_completedMessage];
        }
        [self.closeButton setImage:[UIImage imageNamed:@"bannerCheck"] forState:UIControlStateNormal];
        
        // Should dismiss
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if ([_delegate shouldDismissElement:self])
            {
                [self dismiss];
            }
        });
    }
    else
    {
        _containerView.backgroundColor = _backgroundColor;
        self.circleLayer.opacity = 0.0f;
    }
}

- (void)setPercentageCompleted:(CGFloat)percentage;
{
    if (percentage < 0 || _actionCompleted)
    {
        return;
    }
    
    // Load percentage indicator
    CGRect frame = CGRectZero;
    frame.origin.x = -10.0;
    frame.origin.y = CGRectGetHeight(_containerView.bounds) / 2.0;
    frame.size.height = 400;
    frame.size.width = CGRectGetWidth(_containerView.bounds) * (percentage + 0.1);
    frame.origin.y -= CGRectGetHeight(frame)/2.0;
    
    self.circleLayer.opacity = (0.2 + percentage*0.8);
    
    self.circleLayer.path = [UIBezierPath bezierPathWithOvalInRect:frame].CGPath;

    if (percentage >= 1.0)
    {
        // User action completed
        [self setCompleted:YES animated:NO];
    }
}

- (DNTutorialAction)tutorialActions;
{
    return DNTutorialActionBanner;
}


#pragma mark --
#pragma mark Public Methods
#pragma mark --

- (void)styleWithColor:(UIColor *)color
        completedColor:(UIColor *)completedColor
               opacity:(CGFloat)opacity
                  font:(UIFont *)font;
{
    [self setBannerColor:color];
    [self setCompletedColor:completedColor];
    [self setBannerOpacity:opacity];
    [self setBannerFont:font];
}

- (void)setBannerColor:(UIColor *)bannerColor;
{
    _backgroundColor = bannerColor;
    _containerView.backgroundColor = bannerColor;
}

- (void)setCompletedColor:(UIColor *)completedColor
{
    _completedColor = completedColor;
    _circleLayer.fillColor = [_completedColor CGColor];
}

- (void)setBannerOpacity:(CGFloat)opacity;
{
    _opacity = opacity;
    _containerView.alpha = _opacity;
}

- (void)setBannerFont:(UIFont *)font;
{
    _messageFont = font;
    _messagelabel.font = font;
}

#pragma mark --
#pragma mark Private Methods
#pragma mark --

- (void)animateToCompletedState;
{
    // Expand circle
    [self expandCircleInView:_containerView];
    
    CGRect frame = CGRectZero;
    frame.size.width = 600;
    frame.size.height = 400;
    frame.origin.x = CGRectGetMidX(_containerView.bounds)-CGRectGetMidX(frame);
    frame.origin.y = CGRectGetMidY(_containerView.bounds)-CGRectGetMidY(frame);
    
    self.circleLayer.opacity = 0.8;
    self.circleLayer.path = [UIBezierPath bezierPathWithOvalInRect:frame].CGPath;
}

- (void)expandCircleInView:(UIView *)view
{
    
    CGFloat duration = 0.8;
    CGRect startRect = self.closeButton.frame;
    
    CGRect endRect = CGRectZero;
    endRect.size.width = 600;
    endRect.size.height = 400;
    endRect.origin.x = CGRectGetMidX(view.bounds)-CGRectGetMidX(endRect);
    endRect.origin.y = CGRectGetMidY(view.bounds)-CGRectGetMidY(endRect);
    
    [CATransaction begin];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.duration = duration;
    pathAnimation.fromValue = (id)[[UIBezierPath bezierPathWithOvalInRect:startRect] CGPath];
    pathAnimation.toValue = (id)[[UIBezierPath bezierPathWithOvalInRect:endRect] CGPath];
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.circleLayer addAnimation:pathAnimation forKey:@"path"];
    
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.duration = duration/2;
    fadeAnimation.autoreverses = YES;
    fadeAnimation.fromValue = @(0.0);
    fadeAnimation.toValue = @(0.8);
    fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.circleLayer addAnimation:fadeAnimation forKey:@"opacity"];
    
    [CATransaction commit];
}

- (void)setMessage:(NSString *)message;
{
    _message = message;
    self.messagelabel.text = message;
}

- (void)closeAction:(id)sender;
{
    // Should never show banner again
    if (_delegate && [_delegate respondsToSelector:@selector(userDismissedElement:)])
    {
        [_delegate userDismissedElement:self];
    }
    
    [self dismiss];
}

@end
