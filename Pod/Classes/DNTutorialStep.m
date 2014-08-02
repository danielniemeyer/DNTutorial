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
}

- (void)showInView:(UIView *)aView;
{
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
    for (DNTutorialElement *tutorialElement in self.elements)
    {
        [tutorialElement setPercentageCompleted:percentage];
    }
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

- (void)startAnimating;
{
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

#pragma mark --
#pragma mark Private Methods
#pragma mark --

- (void)dismiss
{
    if ([_delegate respondsToSelector:@selector(willDismissStep:)])
    {
        [_delegate willDismissStep:self];
    }
    
    if ([_delegate respondsToSelector:@selector(didDismissStep:)]) {
        [_delegate didDismissStep:self];
    }
}

#pragma mark --
#pragma mark DNTutorialElementDelegate
#pragma mark --


- (BOOL)shouldDismissElement:(DNTutorialElement *)element;
{
    return [_delegate shouldDismissStep:self];
}

- (void)willDismissElement:(DNTutorialElement *)element;
{
    // Called when element is about to be animated out of the parent view
    if (isDismissingElement)
    {
        return;
    }
    
    // Check if there are other objects associated with this one that should be dismissed
    isDismissingElement = YES;

    if ([self.elements count] > 1)
    {
        for (DNTutorialElement *object in self.elements)
        {
            if (object != element) {
                [object dismiss];
            }
        }
    }
}

- (void)didDismissElement:(DNTutorialElement *)element;
{
    // Element dismissed!
    [self.elements removeObject:element];
    
    // Dealloc
    [element tearDown];
    
    isDismissingElement = NO;
    
    // Check if step is completed
    if ([self.elements count] == 0)
    {
        // Mark as completed
        [self dismiss];
    }
}

@end
