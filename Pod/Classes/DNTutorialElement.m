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
        
    if (percentage >= 1.0)
        [self setCompleted:YES animated:NO];
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

@end
