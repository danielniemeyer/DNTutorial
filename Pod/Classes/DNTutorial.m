//
//  DNTutorial.m
//  DNTutorial
//
//  Created by Daniel Niemeyer on 7/24/14.
//  Copyright (c) 2014 Daniel Niemeyer. All rights reserved.
//

#import "DNTutorial.h"

NSString* const sUserDefaultsKey = @"DNTutorialDefaults";

NSString* const sTutorialObjectsCountKey = @"tutorialObjectCount";
NSString* const sTutorialRemainingCountKey = @"tutorialRemainingCount";

@interface DNTutorialDictionary : NSMutableDictionary

@property (nonatomic, strong) NSMutableDictionary       *dictionary;

- (void)controller:(NSString *)aController setObject:(id)anObject forKey:(id<NSCopying>)aKey;
- (id)controller:(NSString *)aController getObjectforKey:(id<NSCopying>)aKey;

@end

@implementation DNTutorialDictionary

- (instancetype)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)count;
{
    DNTutorialDictionary *tutorialDictionary = [DNTutorialDictionary new];
    tutorialDictionary.dictionary = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys count:count];

    // Populate data from user defaults
    if ([[NSUserDefaults standardUserDefaults] dictionaryForKey:sUserDefaultsKey] != nil)
    {
        tutorialDictionary.dictionary = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:sUserDefaultsKey] mutableCopy];
    }
    
    return tutorialDictionary;
}

- (NSUInteger)count;
{
    return [_dictionary count];
}

- (id)objectForKey:(id)aKey;
{
    return [_dictionary objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator;
{
    return [_dictionary keyEnumerator];
}

- (void)setObject:(id)anObject forKey:(id < NSCopying >)aKey;
{
    [_dictionary setObject:anObject forKey:aKey];
    
    [[NSUserDefaults standardUserDefaults] setObject:_dictionary forKey:sUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeObjectForKey:(id)aKey;
{
    [_dictionary removeObjectForKey:aKey];
    
    [[NSUserDefaults standardUserDefaults] setObject:_dictionary forKey:sUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)controller:(NSString *)aController setObject:(id)anObject forKey:(id<NSCopying>)aKey;
{
    NSMutableDictionary *controllerDictionary = [self dictionaryForController:aController];
    [controllerDictionary setObject:anObject forKey:aKey];
    [self setObject:controllerDictionary forKey:aController];
}

- (id)controller:(NSString *)aController getObjectforKey:(id<NSCopying>)aKey;
{
    NSMutableDictionary *controllerDictionary = [self dictionaryForController:aController];
    return [controllerDictionary objectForKey:aKey];
}

- (NSMutableDictionary *)dictionaryForController:(NSString *)aController;
{
    // Check for existing entry in user defaults dictionary, create one if needed
    NSMutableDictionary *controllerDictionary = nil;
    
    if (_dictionary[aController] == nil)
    {
        controllerDictionary = [NSMutableDictionary dictionary];
        [_dictionary setObject:controllerDictionary forKey:aController];
    }
    else
    {
        controllerDictionary = [_dictionary[aController] mutableCopy];
    }
    
    return controllerDictionary;
}

@end

@interface DNTutorial()

@property (nonatomic, strong) NSMutableArray            *tutorialSteps;
@property (nonatomic, strong) DNTutorialStep            *currentStep;
@property (nonatomic) CGPoint                           initialGesturePoint;
@property (nonatomic, strong) UIView                    *parentView;

@property (nonatomic, strong) DNTutorialDictionary      *userDefaults;

@end

@implementation DNTutorial

#pragma mark --
#pragma mark - Initiation
#pragma mark --

+ (DNTutorial *)sharedInstance;
{
    static DNTutorial *appTutorial = nil;
    if (appTutorial == nil)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            appTutorial = [[DNTutorial alloc] init];
            appTutorial.tutorialSteps = [NSMutableArray array];
            appTutorial.userDefaults = [DNTutorialDictionary dictionary];
        });
    }
    
    return appTutorial;
}

#pragma mark --
#pragma mark Public Methods
#pragma mark --

+ (void)presentTutorialWithSteps:(NSArray *)tutorialSteps
                            inView:(UIView *)aView
                          delegate:(id<DNTutorialDelegate>)delegate;
{
    // Cannot init a null tutorial
    NSAssert(tutorialSteps != nil, @"AppTutorial: Cannot presnet tutorial with nil objetcs");
    NSAssert(aView != nil, @"AppTutorial: Cannot presnet tutorial with nil view");
    NSAssert(delegate != nil, @"AppTutorial: Cannot presnet tutorial with nil delegate");
    
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    
    // Remember tutorial objects
    tutorial.tutorialSteps = [tutorialSteps mutableCopy];
    tutorial.delegate = delegate;
    tutorial.parentView = aView;
    
    // Restore state
    [tutorial loadData];
    
    if ([tutorial.tutorialSteps count] == 0)
    {
        // Nothing to present dismiss
        return;
    }
    
    [tutorial presentTutorialStep:tutorial.tutorialSteps[0] inView:aView];
}

+ (void)presentStepForKey:(NSString *)akey;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];

    DNTutorialStep *step = [tutorial tutorialStepForKey:akey];
    
    if (step == nil) {
        return;
    }
    
    [tutorial presentTutorialStep:step inView:tutorial.parentView];
}

+ (void)completedStepForKey:(NSString *)aKey;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    
    // Complete approprate step
    DNTutorialStep *toComplete = nil;
    
    for (DNTutorialStep *step in tutorial.tutorialSteps)
    {
        if ([step.key isEqualToString:aKey])
        {
            toComplete = step;
            break;
        }
    }
    
    if (toComplete == nil)
    {
        toComplete = tutorial.currentStep;
    }
    
    if (toComplete != nil)
    {
        [toComplete setCompleted:YES];
    }
}

+ (void)resetProgress;
{
    // Restore to factory settings
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:sUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];    
}

+ (void)setDebug;
{
    [DNTutorial resetProgress];
}

+ (void)touchesBegan:(CGPoint)touchPoint inView:(UIView *)view;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    [tutorial swipeBeganWithPoint:touchPoint];
}

+ (void)touchesMoved:(CGPoint)touchPoint destinationSize:(CGSize)touchSize;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    [tutorial swipeMovedWithPoint:touchPoint size:touchSize];
}

+ (void)touchesEnded:(CGPoint)touchPoint destinationSize:(CGSize)touchSize;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    [tutorial swipeEndedWithPoint:touchPoint size:touchSize];
}

+ (void)touchesCancelled:(CGPoint)touchPoint inView:(UIView *)view;
{
    // Retrive DNTutorial instance
    //DNTutorial *tutorial = [DNTutorial sharedInstance];
    //[tutorial swipeEndedWithPoint:touchPoint size:view.bounds.size];
}

#pragma mark --
#pragma mark Gesture recognizers
#pragma mark --

- (void)swipeBeganWithPoint:(CGPoint)point;
{
    // Register initial position
    NSArray *tutorialElements = [self.currentStep tutorialElementsWithAction:DNTutorialActionSwipeGesture | DNTutorialActionTapGesture];
    
    if ([tutorialElements count] == 0)
    {
        // Ignore
        return;
    }
    
    // Register initial point
    self.initialGesturePoint = point;
    
    // Stop Animating
    [self.currentStep stopAnimating];
}

- (void)swipeMovedWithPoint:(CGPoint)point size:(CGSize)size;
{
    // Should base on direction of current presenting gesture action
    NSArray *tutorialElements = [self.currentStep tutorialElementsWithAction:(DNTutorialActionScroll)];
    
    if ([tutorialElements count] == 0)
    {
        // Ignore
        return;
    }
    
    CGFloat delta = 0.0f;
    
    // Calculate delta based on target direction
    for (DNTutorialElement *tutorialElement in tutorialElements)
    {
        if ([self.currentStep tutorialElement:tutorialElement respondsToActions:DNTutorialActionSwipeGesture])
        {
            delta = [self point:point deltaPositionForElement:tutorialElement withSize:size];
            break;
        }
    }
    
    // Track current position in relation to initial point
    [self.currentStep setPercentageCompleted:delta];
}

- (void)swipeEndedWithPoint:(CGPoint)point size:(CGSize)size;
{
    // Check if currently presenting a gesture animation
    NSArray *tutorialElements = [self.currentStep tutorialElementsWithAction:DNTutorialActionSwipeGesture | DNTutorialActionTapGesture];
    
    if ([tutorialElements count] == 0)
    {
        // Ignore
        return;
    }
    
    CGFloat delta = 0.0f;
    
    for (DNTutorialElement *tutorialElement in tutorialElements)
    {
        if ([self.currentStep tutorialElement:tutorialElement respondsToActions:DNTutorialActionSwipeGesture])
        {
            delta = [self point:point deltaPositionForElement:tutorialElement withSize:size];
            break;
        }
    }
    
    // Start animating
    if (delta <= 0.7)
    {
        [self.currentStep startAnimating];
    }
}

#pragma mark --
#pragma mark UIScrollView
#pragma mark --

+ (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    
    [tutorial swipeBeganWithPoint:scrollView.contentOffset];
}

+ (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    
    [tutorial swipeMovedWithPoint:scrollView.contentOffset size:scrollView.bounds.size];
}

+ (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    
    [tutorial swipeEndedWithPoint:scrollView.contentOffset size:scrollView.bounds.size];
}

- (CGFloat)point:(CGPoint)point deltaPositionForElement:(DNTutorialElement *)tutorialElement withSize:(CGSize)size;
{
    CGFloat delta = 0.0f;
    
    DNTutorialGestureType direction = [(DNTutorialGesture *)tutorialElement gestureType];
    
    switch (direction) {
        case DNTutorialGestureTypeSwipeUp:
            delta = (point.y - self.initialGesturePoint.y)/size.height;
            break;
        case DNTutorialGestureTypeSwipeRight:
            delta = (self.initialGesturePoint.x - point.x)/size.width;
            break;
        case DNTutorialGestureTypeSwipeDown:
            delta = (self.initialGesturePoint.y - point.y)/size.height;
            break;
        case DNTutorialGestureTypeSwipeLeft:
            delta = (point.x - self.initialGesturePoint.x)/size.width;
            break;
            
        default:
            break;
    }
    
    return delta;
}

#pragma mark --
#pragma mark Private Methods
#pragma mark --

- (void)loadData;
{
    // Load data from user defaults
    NSUInteger objectCount = [[self.userDefaults controller:[self currentController] getObjectforKey:sTutorialObjectsCountKey] integerValue];
    NSInteger remainingCount = [[self.userDefaults controller:[self currentController] getObjectforKey:sTutorialRemainingCountKey] integerValue];

    // If no data found, save it
    if (objectCount == 0)
    {
        // Save current
        objectCount = remainingCount = [self.tutorialSteps count];
        [self.userDefaults controller:[self currentController] setObject:@(objectCount) forKey:sTutorialObjectsCountKey];
        [self.userDefaults controller:[self currentController] setObject:@(objectCount) forKey:sTutorialRemainingCountKey];
    }
    
    // Advance tutorial
    if (objectCount == [_tutorialSteps count])
    {
        // Advance tutorial
        NSUInteger toDelete = objectCount - remainingCount;
        
        if (remainingCount < objectCount && toDelete > 0)
        {
            [self.tutorialSteps removeObjectsInRange:NSMakeRange(0, toDelete)];
        }
    }
}

- (void)presentTutorialStep:(DNTutorialStep *)step inView:(UIView *)aView;
{
    // Check if can present step
    if (self.currentStep == step)
    {
        return;
    }
    
    BOOL shouldPresent = YES;
    
    if ([_delegate respondsToSelector:@selector(shouldPresentStep:forKey:)])
    {
        shouldPresent = [_delegate shouldPresentStep:step forKey:step.key];
    }
    
    if (!shouldPresent)
    {
        // Skip current step
        [self skipTutorialStep:step];
        return;
    }
    
    // Present step
    [step setDelegate:self];
    [step showInView:aView];
    
    // Current object
    self.currentStep = step;
    
    // Dequeue
    [self.tutorialSteps removeObjectAtIndex:0];
}

- (void)skipTutorialStep:(DNTutorialStep *)step;
{
    // Save step for later
    [self.userDefaults controller:[self currentController] setObject:@(NO) forKey:step.key];
    
    // Dequeue
    [self.tutorialSteps removeObjectAtIndex:0];
    
    // Advance sequence
    if ([self.tutorialSteps count] > 0)
    {
        // Next
        [self presentTutorialStep:self.tutorialSteps[0] inView:self.parentView];
    }
    
    // Add it to the end of queue
    [self.tutorialSteps addObject:step];
}

- (NSString *)currentController
{
    
    return NSStringFromClass([self.delegate class]);
}

- (BOOL)containsStepForKey:(NSString *)key
{
    // Check for key present in presenting queue
    return [self tutorialStepForKey:key];
}

- (id)tutorialStepForKey:(NSString *)key
{
    // Iterate objects and check for present key
    for (DNTutorialStep *tutorialStep in self.tutorialSteps)
    {
        if ([tutorialStep.key isEqualToString:key])
        {
            return tutorialStep;
        }
    }
    
    // Nothing found
    return nil;
}

#pragma mark --
#pragma mark Banner Delegate Methods
#pragma mark --

- (void)willDismissStep:(DNTutorialStep *)tutorialStep;
{
    // Save state
    [self.userDefaults controller:[self currentController] setObject:@(YES) forKey:tutorialStep.key];
    [self.userDefaults controller:[self currentController] setObject:@([self.tutorialSteps count]) forKey:sTutorialRemainingCountKey];
}

- (void)didDismissStep:(DNTutorialStep *)tutorialStep;
{
    self.currentStep = nil;
    
    // Check if there are more steps to present and if so show it.
    if ([self.tutorialSteps count] == 0)
    {
        return;
    }
    
    // Present next step
    [self presentTutorialStep:self.tutorialSteps[0] inView:self.parentView];
}

- (BOOL)shouldDismissStep:(DNTutorialStep *)step;
{
    BOOL toReturn;
    
    if ([_delegate respondsToSelector:@selector(shouldDismissStep:forKey:)])
    {
        toReturn = [_delegate shouldDismissStep:step forKey:step.key];
    }
    else
        toReturn = YES;
    
    return toReturn;
}

@end