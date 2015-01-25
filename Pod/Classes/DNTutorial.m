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
NSString* const sTutorialElementsKey = @"tutorialSteps";

NSInteger const sTutorialTrackingDistance = 100;

@interface DNTutorial()

@property (nonatomic, copy) shouldPresent               shouldPresentBlock;
@property (nonatomic, assign) NSUInteger                presentationDelay;
@property (nonatomic, weak) id<DNTutorialDelegate>      delegate;
@property (nonatomic, strong) UIView                      *parentView;

@property (nonatomic, strong) NSMutableArray            *tutorialSteps;
@property (nonatomic, strong) DNTutorialStep            *currentStep;
@property (nonatomic, assign) BOOL                      hidden;
@property (nonatomic) NSValue                           *initialGesturePoint;

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
            appTutorial.presentationDelay = 0;
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
    
    // Check if should present
    if (tutorial.hidden)
    {
        return;
    }
    
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

+ (void)showTutorial;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    
    if ([tutorial.tutorialSteps count] == 0 || tutorial.currentStep != nil)
        return;

    [tutorial presentTutorialStep:tutorial.tutorialSteps[0] inView:tutorial.parentView];
}

+ (void)hideTutorial;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    
    // Dequeue current step
    if (tutorial.currentStep == nil)
        return;
    
    // Enqueue current step
    [tutorial.tutorialSteps insertObject:tutorial.currentStep atIndex:0];
    
    // Hide it
    [tutorial.currentStep hideElements];
    tutorial.currentStep = nil;
}

+ (void)presentStepForKey:(NSString *)aKey;
{
    NSAssert(aKey != nil, @"AppTutorial: Cannot present tutorial with nil key");
    
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    
    DNTutorialStep *step = [tutorial tutorialStepForKey:aKey];
    
    if (step == nil || tutorial.currentStep != nil) {
        return;
    }
    
    [tutorial presentTutorialStep:step inView:tutorial.parentView];
}

+ (void)hideStepForKey:(NSString *)aKey;
{
    NSAssert(aKey != nil, @"AppTutorial: Cannot hide tutorial with nil key");
    
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    
    DNTutorialStep *step = [tutorial tutorialStepForKey:aKey];
    
    if (step == nil) {
        return;
    }
    
    // Hide it
    [step hideElements];
}

+ (void)completedStepForKey:(NSString *)aKey;
{
    NSAssert(aKey != nil, @"AppTutorial: Cannot complete step with nil key");
    
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
    
    if (toComplete != nil && [toComplete.key isEqualToString:aKey])
    {
        [toComplete setCompleted:YES];
        
        // Save state
        if (tutorial.delegate != nil)
        {
            [tutorial.userDefaults controller:[tutorial currentController] setCompletion:YES forElement:toComplete.key];
        }
    }
}

+ (void)resetProgress;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];

    // Restore to factory settings
    [tutorial.userDefaults removeAllObjects];
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:sUserDefaultsKey];
    //[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setDebug;
{
    [DNTutorial resetProgress];
}

+ (void)setHidden:(BOOL)hidden;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];

    tutorial.hidden = hidden;
}

+ (void)setPresentationDelay:(NSUInteger)delay;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    
    tutorial.presentationDelay = delay;
}

+ (void)shouldPresentElementsWithBlock:(shouldPresent)block;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    
    tutorial.shouldPresentBlock = block;
}

+ (void)touchesBegan:(CGPoint)touchPoint inView:(UIView *)view;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    [tutorial swipeBegan:DNTutorialActionSwipeGesture withPoint:touchPoint];
}

+ (void)touchesMoved:(CGPoint)touchPoint destinationSize:(CGSize)touchSize;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    [tutorial swipeMoved:DNTutorialActionSwipeGesture withPoint:touchPoint size:touchSize];
}

+ (void)touchesEnded:(CGPoint)touchPoint destinationSize:(CGSize)touchSize;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    [tutorial swipeEnded:DNTutorialActionSwipeGesture withPoint:touchPoint size:touchSize];
}

+ (void)touchesCancelled:(CGPoint)touchPoint inView:(UIView *)view;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    [tutorial swipeEnded:DNTutorialActionSwipeGesture withPoint:touchPoint size:view.bounds.size];
}

+ (id)tutorialStepForKey:(NSString *)aKey;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    
    DNTutorialStep *step = tutorial.currentStep;
    
    for (int i = 0; step == nil;)
    {
        step = tutorial.tutorialSteps[i];
    }
    
    return step;
}

+ (id)tutorialElementForKey:(NSString *)aKey;
{
    NSAssert(aKey != nil, @"AppTutorial: Cannot get tutorial element with nil key");
    
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    
    DNTutorialElement *element = [tutorial.currentStep tutorialElementForKey:aKey];
    
    for (int i = 0; element == nil;)
    {
        element = [tutorial.tutorialSteps[i] tutorialElementForKey:aKey];
    }
    
    return element;
}

+ (DNTutorialStep *)currentStep;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    
    return tutorial.currentStep;
}

#pragma mark --
#pragma mark Gesture recognizers
#pragma mark --

- (void)swipeBegan:(DNTutorialAction)action withPoint:(CGPoint)point;
{
    if (self.currentStep == nil || self.initialGesturePoint != nil)
        return;
    
    // Stop Animating
    [self.currentStep stopAnimating];
    
    // Register initial position
    NSArray *tutorialElements = [self.currentStep tutorialElementsWithAction:action | DNTutorialActionTapGesture];
    
    if ([tutorialElements count] == 0)
    {
        // Ignore
        return;
    }
    
    // Register initial point
    self.initialGesturePoint = [NSValue valueWithCGPoint:point];
}

- (void)swipeMoved:(DNTutorialAction)action withPoint:(CGPoint)point size:(CGSize)size;
{
    if (self.currentStep == nil)
        return;
    
    // Should base on direction of current presenting gesture action
    NSArray *tutorialElements = [self.currentStep tutorialElementsWithAction:(action)];
    
    if ([tutorialElements count] == 0)
    {
        // Ignore
        return;
    }
    
    CGFloat delta = 0.0f;
    
    // Calculate delta based on target direction
    for (DNTutorialElement *tutorialElement in tutorialElements)
    {
        if ([self.currentStep tutorialElement:tutorialElement respondsToActions:action])
        {
            delta = [self point:point deltaPositionForElement:tutorialElement withSize:size];
            break;
        }
    }
    
    // Track current position in relation to initial point
    [self.currentStep setPercentageCompleted:delta];
    
    if (delta >= 1.0) {
        self.initialGesturePoint = nil;
    }
}

- (void)swipeEnded:(DNTutorialAction)action withPoint:(CGPoint)point size:(CGSize)size;
{
    if (self.currentStep == nil)
        return;
    
    // Check if currently presenting a gesture animation
    NSArray *tutorialElements = [self.currentStep tutorialElementsWithAction:action | DNTutorialActionTapGesture];
    
    CGFloat delta = 0.0f;
    
    for (DNTutorialElement *tutorialElement in tutorialElements)
    {
        if ([self.currentStep tutorialElement:tutorialElement respondsToActions:action])
        {
            delta = [self point:point deltaPositionForElement:tutorialElement withSize:size];
            break;
        }
    }
    
    // Start animating
    if (delta < 1.0)
    {
        self.initialGesturePoint = nil;
        
        [self.currentStep startAnimating];
        
        [self.currentStep setPercentageCompleted:0];
    }
}

#pragma mark --
#pragma mark UIScrollView
#pragma mark --

+ (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    [tutorial swipeBegan:DNTutorialActionScroll withPoint:scrollView.contentOffset];
}

+ (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    [tutorial swipeMoved:DNTutorialActionScroll withPoint:scrollView.contentOffset size:scrollView.bounds.size];
}

+ (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    // Retrive DNTutorial instance
    DNTutorial *tutorial = [DNTutorial sharedInstance];
    [tutorial swipeEnded:DNTutorialActionScroll withPoint:scrollView.contentOffset size:scrollView.bounds.size];
}

- (CGFloat)point:(CGPoint)point deltaPositionForElement:(DNTutorialElement *)tutorialElement withSize:(CGSize)size;
{
    CGFloat delta = 0.0f;
    CGPoint initialPoint = [self.initialGesturePoint CGPointValue];
    
    DNTutorialGestureType direction = [(DNTutorialGesture *)tutorialElement gestureType];
    
    switch (direction) {
        case DNTutorialGestureTypeSwipeUp:
            delta = (point.y - initialPoint.y)/size.height;
            break;
        case DNTutorialGestureTypeSwipeRight:
            delta = (point.x - initialPoint.x)/size.width;
            break;
        case DNTutorialGestureTypeSwipeDown:
            delta = (initialPoint.y - point.y)/size.height;
            break;
        case DNTutorialGestureTypeSwipeLeft:
            delta = (initialPoint.x - point.x)/size.width;
            break;
        case DNTutorialGestureTypeScrollUp:
            delta = (point.y - initialPoint.y)/size.height;
            break;
        case DNTutorialGestureTypeScrollRight:
            delta = (initialPoint.x - point.x)/size.width;
            break;
        case DNTutorialGestureTypeScrollDown:
            delta = (initialPoint.y - point.y)/size.height;
            break;
        case DNTutorialGestureTypeScrollLeft:
            delta = (point.x - initialPoint.x)/size.width;
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
    
    // If no data found, save it
    if (objectCount == 0)
    {
        // Save current
        objectCount = [self.tutorialSteps count];
        [self.userDefaults controller:[self currentController] setObject:@(objectCount) forKey:sTutorialObjectsCountKey];
        [self.userDefaults controller:[self currentController] setObject:@(objectCount) forKey:sTutorialRemainingCountKey];
    }
    
    // Advance tutorial
    if (objectCount != [_tutorialSteps count])
    {
        NSLog(@"DNTutorial: Detected different number of banners being presented than those previously saved.");
    }
    
    // Advance tutorial
    NSDictionary *elementsDict = [self.userDefaults controller:[self currentController] getObjectforKey:sTutorialElementsKey];
    
    [elementsDict enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop)
     {
         for (DNTutorialStep *step in [self.tutorialSteps copy])
         {
             if ([key isEqualToString:step.key] && [value boolValue])
             {
                 [self.tutorialSteps removeObject:step];
             }
         }
     }];
}

- (void)saveData;
{
    NSUInteger remainingCount = [self.tutorialSteps count];
    
    if (!self.currentStep.isCompleted)
    {
        remainingCount++;
    }
    
    // Amount remaining
    [self.userDefaults controller:[self currentController] setObject:@(remainingCount) forKey:sTutorialRemainingCountKey];
}

- (void)presentTutorialStep:(DNTutorialStep *)step inView:(UIView *)aView;
{
    // Check if can present step
    if (self.currentStep == step)
    {
        return;
    }
    
    // Check for global variable
    if (self.shouldPresentBlock && !self.shouldPresentBlock())
    {
        [self skipTutorialStep:step];
        return;
    }
    
    BOOL shouldPresent = YES;
    
    if ([_delegate respondsToSelector:@selector(shouldPresentStep:forKey:)])
    {
        shouldPresent = [_delegate shouldPresentStep:step forKey:step.key];
    }
    
    if (step.isCompleted)
    {
        shouldPresent = NO;
    }
    
    if (!shouldPresent)
    {
        // Skip current step
        [self skipTutorialStep:step];
        return;
    }
    
    // Present step
    [step setDelegate:self];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.presentationDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Present
        [step showInView:aView];
    });
    
    // Current object
    self.currentStep = step;
    
    // Dequeue
    [self.tutorialSteps removeObjectAtIndex:0];
}

- (void)hideTutorialStep:(DNTutorialStep *)step;
{
    [self skipTutorialStep:step];
}

- (void)skipTutorialStep:(DNTutorialStep *)step;
{
    // Save step for later
    if (_delegate)
    {
        [self.userDefaults controller:[self currentController] setCompletion:NO forElement:step.key];
    }
    
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

- (void)setDelegate:(id<DNTutorialDelegate>)delegate
{
    if (_delegate == delegate)
        return;

    // Reset current step
    _delegate = delegate;
    _currentStep = nil;
}

- (NSString *)currentController
{
    
    return NSStringFromClass([self.delegate class]);
}

- (BOOL)containsStepForKey:(NSString *)key
{
    // Check for key present in presenting queue
    return [self tutorialStepForKey:key] != nil;
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
#pragma mark Step Delegate Methods
#pragma mark --

- (void)willDismissStep:(DNTutorialStep *)tutorialStep;
{
    // Save state
    if (_delegate != nil)
    {
        [self.userDefaults controller:[self currentController] setCompletion:tutorialStep.isCompleted forElement:tutorialStep.key];
        
        [self saveData];
    }
}

- (void)didDismissStep:(DNTutorialStep *)tutorialStep;
{
    // Check if there are more steps to present and if so show it.
    self.currentStep = nil;
    
    if ([self.tutorialSteps count] == 0)
    {
        return;
    }
    
    // Present next step
    [self presentTutorialStep:self.tutorialSteps[0] inView:self.parentView];
}

- (BOOL)shouldDismissStep:(DNTutorialStep *)step;
{
    BOOL toReturn = YES;
    
    if ([_delegate respondsToSelector:@selector(shouldDismissStep:forKey:)])
    {
        toReturn = [_delegate shouldDismissStep:step forKey:step.key];
    }
    
    return toReturn;
}

- (BOOL)shouldAnimateStep:(DNTutorialStep *)step;
{
    BOOL toReturn = YES;
    
    if ([_delegate respondsToSelector:@selector(shouldAnimateStep:forKey:)])
    {
        toReturn = [_delegate shouldAnimateStep:step forKey:step.key];
    }
    
    return toReturn;
}

@end

#pragma mark --
#pragma mark DNTutorialDictionary Subclass
#pragma mark --

@implementation DNTutorialDictionary

+ (instancetype)dictionary;
{
    DNTutorialDictionary *tutorialDictionary = [DNTutorialDictionary new];
    [tutorialDictionary setupWithObjects:nil forKeys:nil count:0];
    return tutorialDictionary;
}

- (instancetype)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)count;
{
    DNTutorialDictionary *tutorialDictionary = [DNTutorialDictionary new];
    [tutorialDictionary setupWithObjects:objects forKeys:keys count:count];
    return tutorialDictionary;
}

- (void)setupWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)count;
{
    self.dictionary = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys count:count];
    
    // Populate data from user defaults
    if ([[NSUserDefaults standardUserDefaults] dictionaryForKey:sUserDefaultsKey] != nil)
    {
        self.dictionary = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:sUserDefaultsKey] mutableCopy];
    }
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
    NSAssert(aKey != nil, @"DNTutorialTutorial: Cannot get dictionary for a nil key");
    
    [_dictionary setObject:anObject forKey:aKey];
    
    [[NSUserDefaults standardUserDefaults] setObject:_dictionary forKey:sUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeObjectForKey:(id)aKey;
{
    NSAssert(aKey != nil, @"DNTutorialTutorial: Cannot get dictionary for a nil key");
    
    [_dictionary removeObjectForKey:aKey];
    
    [[NSUserDefaults standardUserDefaults] setObject:_dictionary forKey:sUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)controller:(NSString *)aController setObject:(id)anObject forKey:(id<NSCopying>)aKey;
{
    NSAssert(aKey != nil, @"DNTutorialTutorial: Cannot get dictionary for a nil key");

    NSMutableDictionary *controllerDictionary = [self dictionaryForController:aController];
    [controllerDictionary setObject:anObject forKey:aKey];
    [self setObject:controllerDictionary forKey:aController];
}

- (id)controller:(NSString *)aController getObjectforKey:(id<NSCopying>)aKey;
{
    NSAssert(aKey != nil, @"DNTutorialTutorial: Cannot get dictionary for a nil key");
    
    NSMutableDictionary *controllerDictionary = [self dictionaryForController:aController];
    return [controllerDictionary objectForKey:aKey];
}

- (void)controller:(NSString *)aController setCompletion:(BOOL)completion forElement:(id<NSCopying>)aKey;
{
    NSAssert(aKey != nil, @"DNTutorialTutorial: Cannot set dictionary for a nil element.");
    NSAssert(aController != nil, @"DNTutorialTutorial: Cannot set dictionary for a nil controller, this generaly occurs when the tutorial delegate is nil.");
    
    NSMutableDictionary *controllerDictionary = [self dictionaryForController:aController];
    NSMutableDictionary *elementsDictionary = [controllerDictionary[sTutorialElementsKey] mutableCopy];
    [elementsDictionary setObject:@(completion) forKey:aKey];
    [controllerDictionary setObject:elementsDictionary forKey:sTutorialElementsKey];
    
    [_dictionary setObject:controllerDictionary forKey:aController];
    [[NSUserDefaults standardUserDefaults] setObject:_dictionary forKey:sUserDefaultsKey];
}

- (BOOL)controller:(NSString *)aController getCompletionforElement:(id<NSCopying>)aKey;
{
    NSAssert(aKey != nil, @"DNTutorialTutorial: Cannot set dictionary for a nil element.");
    NSAssert(aController != nil, @"DNTutorialTutorial: Cannot set dictionary for a nil controller, this generaly occurs when the tutorial delegate is nil.");
    
    NSMutableDictionary *controllerDictionary = [self dictionaryForController:aController];
    return [[controllerDictionary objectForKey:controllerDictionary[sTutorialElementsKey]] boolValue];
}

- (NSMutableDictionary *)dictionaryForController:(NSString *)aController;
{
    // Check for existing entry in user defaults dictionary, create one if needed
    NSMutableDictionary *controllerDictionary = nil;
    
    if (_dictionary[aController] == nil)
    {
        controllerDictionary = [NSMutableDictionary dictionary];
        [controllerDictionary setObject:[NSDictionary dictionary] forKey:sTutorialElementsKey];
        [_dictionary setObject:controllerDictionary forKey:aController];
    }
    else
    {
        controllerDictionary = [_dictionary[aController] mutableCopy];
    }
    
    return controllerDictionary;
}

- (void)removeAllObjects;
{
    // Remove all objects
    [_dictionary removeAllObjects];
    [[NSUserDefaults standardUserDefaults] setObject:_dictionary forKey:sUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end