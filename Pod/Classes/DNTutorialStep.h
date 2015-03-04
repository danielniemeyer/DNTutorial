//
//  DNTutorialStep.h
//  DNTutorial
//
//  Created by Daniel Niemeyer on 7/31/14.
//  Copyright (c) 2014 Daniel Niemeyer. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "DNTutorialElement.h"

@protocol DNTutorialStepDelegate;


@interface DNTutorialStep : NSObject <DNTutorialElementDelegate>
{
    @protected
    BOOL                                    _actionCompleted;
    CGFloat                                 _percentageCompleted;
    id<DNTutorialStepDelegate>              _delegate;
}

@property (nonatomic, strong) NSString          *key;
@property (nonatomic, assign) BOOL              isHidden;


// Public method for instantiating a new tutorial step
+ (id)stepWithTutorialElements:(NSArray *)elements
                        forKey:(NSString *)key;


// App Tutorial manager delegate
- (void)setDelegate:(id<DNTutorialStepDelegate>)aDelegate;


// Present tutorial step
- (void)showInView:(UIView *)aView;


// Hide a step
- (void)hideElements;


// Set action completed
- (void)setCompleted:(BOOL)completed;


// Getter
- (BOOL)isCompleted;


// Called when element should animate
- (void)startAnimating;


// Called when user action pauses animations
- (void)stopAnimating;


// Return tutorial elements that repond to given actions
- (NSArray *)tutorialElementsWithAction:(DNTutorialAction)actions;


// Retuns a tutorial element with the given key
- (id)tutorialElementForKey:(NSString *)aKey;


// Check if a certain tutorial element responds to given actions
- (BOOL)tutorialElement:(DNTutorialElement *)tutorialElement respondsToActions:(DNTutorialAction)actions;


// Set percentage completed
- (void)setPercentageCompleted:(CGFloat)percentage;

// Getter for percentage completion
- (CGFloat)percentageCompleted;

// Interface rotation
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

@end

@protocol DNTutorialStepDelegate <NSObject>
@required

- (void)willDismissStep:(DNTutorialStep *)view;
- (void)didDismissStep:(DNTutorialStep *)view;

- (BOOL)shouldDismissStep:(DNTutorialStep *)step;
- (BOOL)shouldAnimateStep:(DNTutorialStep *)step;

- (void)willAnimateElement:(DNTutorialElement *)element toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

@end
