//
//  DNTutorialElement.h
//  DNTutorial
//
//  Created by Daniel Niemeyer on 7/31/14.
//  Copyright (c) 2014 Daniel Niemeyer. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS (NSUInteger, DNTutorialAction)
{
    DNTutorialActionBanner          = 1 << 0,
    DNTutorialActionSwipeGesture    = 1 << 1,
    DNTutorialActionTapGesture      = 1 << 2,
    DNTutorialActionScroll          = 1 << 3,
    DNTutorialActionAny             = ~0UL,
    DNTutorialActionNone            = 1 << 4
};

@protocol DNTutorialElementDelegate;

@interface DNTutorialElement : NSObject
{
    @protected
    BOOL                                        _actionCompleted;
    id<DNTutorialElementDelegate>               _delegate;
}

@property (nonatomic, strong) NSString          *key;


// Called when a new tutorial object is instantiated
- (void)setUpInView:(UIView *)aView;


// Called when tutorial object is destroyed
- (void)tearDown;


// Override this method to customize presentation of tutorial view
- (void)show;


// Override this method to dimiss view
- (void)dismiss;


// App Tutorial manager delegate
- (void)setDelegate:(id<DNTutorialElementDelegate>)aDelegate;


// User completed action indicated by tutorial object
- (void)setCompleted:(BOOL)completed animated:(BOOL)animated;


// Set percentage completed
- (void)setPercentageCompleted:(CGFloat)percentage;


// Getter for tutorial actions
- (DNTutorialAction)tutorialActions;

// Called when element should animate
- (void)startAnimating;

// Called when user pauses animations
- (void)stopAnimating;

@end

@protocol DNTutorialElementDelegate <NSObject>
@required

- (void)willDismissElement:(DNTutorialElement *)element;
- (void)didDismissElement:(DNTutorialElement *)element;

- (BOOL)shouldDismissElement:(DNTutorialElement *)element;

@end

