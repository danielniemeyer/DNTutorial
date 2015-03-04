//
//  DNTutorialElement.m
//  DNTutorial
//
//  Created by Daniel Niemeyer on 7/31/14.
//  Copyright (c) 2014 Daniel Niemeyer. All rights reserved.
//

#import "DNTutorialElement.h"


@implementation DNTutorialElement

- (void)setUpInView:(UIView *)aView;
{
    return;
}

- (void)tearDown;
{
    return;
}

- (void)show;
{
    return;
}

- (void)dismiss;
{
    return;
}

- (void)setDelegate:(id<DNTutorialElementDelegate>)aDelegate;
{
    _delegate = aDelegate;
}

- (void)setCompleted:(BOOL)completed animated:(BOOL)animated;
{
    _actionCompleted = completed;
}

- (void)setPercentageCompleted:(CGFloat)percentage;
{
    if (percentage < 0)
        return;
    
    _percentageCompleted = percentage;
        
    if (percentage >= 1.0)
        [self setCompleted:YES animated:NO];
}

- (CGFloat)percentageCompleted;
{
    return _percentageCompleted;
}

- (DNTutorialAction)tutorialActions;
{
    return DNTutorialActionNone;
}

- (void)startAnimating;
{
    return;
}


- (void)stopAnimating;
{
    return;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    [self willAnimateElement:self toInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateElement:(DNTutorialElement *)element toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    [_delegate willAnimateElement:element toInterfaceOrientation:toInterfaceOrientation duration:duration];
}

@end
