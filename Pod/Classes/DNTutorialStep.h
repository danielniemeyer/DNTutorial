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
    id<DNTutorialStepDelegate>              _delegate;
}

@property (nonatomic, strong) NSString          *key;


// Public method for instantiating a new tutorial step
+ (id)stepWithTutorialElements:(NSArray *)elements
                        forKey:(NSString *)key;


// App Tutorial manager delegate
- (void)setDelegate:(id<DNTutorialStepDelegate>)aDelegate;


// Present tutorial step
- (void)showInView:(UIView *)aView;


// Return tutorial elements that repond to given actions
- (NSArray *)tutorialElementsWithAction:(DNTutorialAction)actions;


// Check if a certain tutorial element responds to given actions
- (BOOL)tutorialElement:(DNTutorialElement *)tutorialElement respondsToActions:(DNTutorialAction)actions;


// Set percentage completed
- (void)setPercentageCompleted:(CGFloat)percentage;


// Set action completed
- (void)setCompleted:(BOOL)completed;

// Called when element should animate
- (void)startAnimating;

// Called when user action pauses animations
- (void)stopAnimating;

@end

@protocol DNTutorialStepDelegate <NSObject>
@required

- (void)willDismissStep:(DNTutorialStep *)view;
- (void)didDismissStep:(DNTutorialStep *)view;

- (BOOL)shouldDismissElement:(DNTutorialElement *)element;

@end
