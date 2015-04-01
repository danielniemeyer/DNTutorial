//
//  DNTutorial.h
//  DNTutorial
//
//  Created by Daniel Niemeyer on 7/24/14.
//  Copyright (c) 2014 Daniel Niemeyer. All rights reserved.
//

// App tutorial manages a set of tutorial messages that interact with the user.
// Once the user completes a task, the tutotial message will never be displayed again.
// If the user interacts with a feature that could toggle a tutorial message, that message
//   should never be displayed to the user.
// App tutorial provides incentives for users to complete tutorials by displaying their progress overall

// Tutorials consist of multiple types.
// DNTutorialBanner displays a banner with an appropriate message and an action that triggers its dismissal.
// DNTutorialGesture displays a gesture motion with a starting location and direction.

//- https://github.com/lostinthepines/TutorialKit
//- https://github.com/kronik/UIViewController-Tutorial

#import <Foundation/Foundation.h>

#import "DNTutorialStep.h"

#import "DNTutorialBanner.h"
#import "DNTutorialGesture.h"
#import "DNTutorialAudio.h"

typedef BOOL (^shouldPresent)();

@class DNTutorial;

@protocol DNTutorialDelegate;

@interface DNTutorial : NSObject <DNTutorialStepDelegate>

// Tells DNTutorial to load the given elements and check if should present them
+ (void)presentTutorialWithSteps:(NSArray *)tutorialSteps
                          inView:(UIView *)aView
                        delegate:(id<DNTutorialDelegate>)delegate;


// Pauses the tutorial, saves the current state and hides all elements
+ (void)showTutorial;
+ (void)hideTutorial;


// Presents step for key
+ (void)presentStepForKey:(NSString *)aKey;


// Hode step for key
+ (void)hideStepForKey:(NSString *)aKey;


// Triggers a user action as completed
+ (void)completedStepForKey:(NSString *)aKey;


// Reset tutorial to factory settings
+ (void)resetProgress;


// Set debug mode so a step is always displayed
+ (void)setDebug;


// Set hidden mode, prevents all tutorial steps from displaying
+ (void)setHidden:(BOOL)hidden;


// Set tutorial elements presentation delay, defaults to 0
+ (void)setPresentationDelay:(NSUInteger)delay;


// Sets the universal should present tutorial elements block
+ (void)shouldPresentElementsWithBlock:(shouldPresent)block;


// Returns the tutorial step corresponding the given key. If no object is found for the given key,
// nil is returned instead.
+ (id)tutorialStepForKey:(NSString *)aKey;


// Returns the tutorial element corresponding the given key. If no object is found for the given key,
// nil is returned instead.
+ (id)tutorialElementForKey:(NSString *)aKey;


// Returns the current tutorial step or nil if not found
+ (DNTutorialStep *)currentStep;

// Used for screen rotation
+ (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

// Used for tutorial gestures
+ (void)touchesBegan:(CGPoint)touchPoint inView:(UIView *)view;
+ (void)touchesMoved:(CGPoint)touchPoint destinationSize:(CGSize)touchSize;
+ (void)touchesEnded:(CGPoint)touchPoint destinationSize:(CGSize)touchSize;
+ (void)touchesCancelled:(CGPoint)touchPoint inView:(UIView *)view;


+ (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
+ (void)scrollViewDidScroll:(UIScrollView *)scrollView;
+ (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

@end

@protocol DNTutorialDelegate <NSObject>

@optional
- (void)willDismissView:(DNTutorialElement *)view;
- (void)didDismissView:(DNTutorialElement *)view;

- (BOOL)shouldPresentStep:(DNTutorialStep *)step forKey:(NSString *)aKey;
- (BOOL)shouldDismissStep:(DNTutorialStep *)step forKey:(NSString *)aKey;

- (BOOL)shouldAnimateStep:(DNTutorialStep *)step forKey:(NSString *)aKey;

- (void)willAnimateElement:(DNTutorialElement *)element toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

@end

@interface DNTutorialDictionary : NSObject

@property (nonatomic, strong) NSMutableDictionary       *dictionary;

+ (instancetype)dictionary;
- (instancetype)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)count;

- (NSUInteger)count;
- (id)objectForKey:(id)aKey;
- (NSEnumerator *)keyEnumerator;
- (void)setObject:(id)anObject forKey:(id < NSCopying >)aKey;
- (void)removeObjectForKey:(id)aKey;

- (void)controller:(NSString *)aController setObject:(id)anObject forKey:(id<NSCopying>)aKey;
- (id)controller:(NSString *)aController getObjectforKey:(id<NSCopying>)aKey;
- (void)controller:(NSString *)aController setCompletion:(BOOL)completion forElement:(id<NSCopying>)aKey;

- (void)removeAllObjects;

@end