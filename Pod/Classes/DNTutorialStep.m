//
//  DNTutorialStep.m
//  DNTutorial
//
//  Created by Daniel Niemeyer on 7/31/14.
//  Copyright (c) 2014 Daniel Niemeyer. All rights reserved.
//

#import "DNTutorialStep.h"

@interface DNTutorialStep()
{
    BOOL    isDismissingElement;
}

@property (nonatomic, strong) NSMutableArray           *elements;

@end

@implementation DNTutorialStep

#pragma mark --
#pragma mark Initialization
#pragma mark --

+ (id)stepWithTutorialElements:(NSArray *)elements
                        forKey:(NSString *)key;
{
    DNTutorialStep *tutorialStep = [DNTutorialStep new];
    tutorialStep.elements = [elements mutableCopy];
    tutorialStep.key = key;
    return tutorialStep;
}

#pragma mark --
#pragma mark Public Methods
#pragma mark --

- (void)setDelegate:(id<DNTutorialStepDelegate>)aDelegate;
{
    _delegate = aDelegate;
    
    for (DNTutorialElement *element in self.elements)
    {
        [element setDelegate:self];
    }
}

- (void)showInView:(UIView *)aView;
{
    // Check if hidden
    self.isHidden = NO;
    
    // Present elements
    for (DNTutorialElement *tutorialElement in self.elements)
    {
        // Assert type conforms to tutorial type
        NSAssert([[tutorialElement class] isSubclassOfClass:[DNTutorialElement class]], @"AppTutorial:   Presenting objects must be a subclass of DNTutorialElement");

        [tutorialElement setUpInView:aView];
        [tutorialElement setDelegate:self];
        [tutorialElement show];
    }
}

- (NSArray *)tutorialElementsWithAction:(DNTutorialAction)actions;
{
    // Return first occurence of object
    NSMutableArray *toReturn = [NSMutableArray array];
    
    for (DNTutorialElement *tutorialElement in _elements)
    {
        if ([self tutorialElement:tutorialElement respondsToActions:actions])
        {
            [toReturn addObject:tutorialElement];
        }
    }
    
    // Mot found
    return [NSArray arrayWithArray:toReturn];
}

- (id)tutorialElementForKey:(NSString *)aKey;
{
    for (DNTutorialElement *element in self.elements)
    {
        if ([element.key isEqualToString:aKey])
        {
            return element;
        }
    }
    
    return nil;
}

- (BOOL)tutorialElement:(DNTutorialElement *)tutorialElement respondsToActions:(DNTutorialAction)actions;
{
    if (actions & [tutorialElement tutorialActions])
    {
        return YES;
    }
    
    return NO;
}

- (void)setPercentageCompleted:(CGFloat)percentage;
{
    // Set percentage completion of child elements
    if (percentage < 0)
        return;
    
    _percentageCompleted = percentage;
    
    for (DNTutorialElement *tutorialElement in self.elements)
    {
        [tutorialElement setPercentageCompleted:percentage];
    }
    
    if (percentage >= 1.0)
    {
        _actionCompleted = YES;
    }
}

- (CGFloat)percentageCompleted;
{
    return _percentageCompleted;
}

- (void)setCompleted:(BOOL)completed;
{
    if (_actionCompleted && completed)
    {
        return;
    }
    
    _actionCompleted = completed;
    
    if (_actionCompleted)
    {
        // Execute completed block
        for (DNTutorialElement *element in self.elements)
        {
            [element setCompleted:YES animated:YES];
        }
    }
}

- (BOOL)isCompleted;
{
    return _actionCompleted;
}

- (void)startAnimating;
{
    if (self.isHidden)
        return;
    
    for (DNTutorialElement *tutorialElement in self.elements)
    {
        [tutorialElement startAnimating];
    }
}

- (void)stopAnimating;
{
    for (DNTutorialElement *tutorialElement in self.elements)
    {
        [tutorialElement stopAnimating];
    }
}

- (void)hideElements;
{
    self.isHidden = YES;
    [self dismiss];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    for (DNTutorialElement *tutorialElement in self.elements)
    {
        [tutorialElement willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

#pragma mark --
#pragma mark Private
#pragma mark --

- (void)dismiss;
{
    if (_delegate && [_delegate respondsToSelector:@selector(willDismissStep:)])
    {
        [_delegate willDismissStep:self];
    }
    
    for (DNTutorialElement *element in self.elements)
    {
        [element dismiss];
    }
}

#pragma mark --
#pragma mark DNTutorialElementDelegate
#pragma mark --


- (BOOL)shouldDismissElement:(DNTutorialElement *)element;
{
    return [_delegate shouldDismissStep:self];
}

- (BOOL)shouldAnimateElement:(DNTutorialElement *)element;
{
    return [_delegate shouldAnimateStep:self];
}

- (void)userDismissedElement:(DNTutorialElement *)element;
{
    [self setCompleted:YES];
}

- (void)willDismissElement:(DNTutorialElement *)element;
{
    // Called when element is about to be animated out of the parent view
    if (isDismissingElement || self.isHidden)
    {
        return;
    }
    
    // Check if there are other objects associated with this one that should be dismissed
    isDismissingElement = YES;
}

- (void)didDismissElement:(DNTutorialElement *)element;
{
    // Dealloc
    [element tearDown];
    
    // Check if done hiding
    if (self.isHidden)
    {
        return;
    }
    
    // Element dismissed!
    [self.elements removeObject:element];
    
    // Check if step is completed
    if ([self.elements count] == 0)
    {
        isDismissingElement = NO;
        
        // Mark as completed
        [self dismiss];
        [_delegate didDismissStep:self];
    }
}

- (void)willAnimateElement:(DNTutorialElement *)element toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    // Called when an element is about to animate view rotation
    [_delegate willAnimateElement:element toInterfaceOrientation:toInterfaceOrientation duration:duration];
}

@end
