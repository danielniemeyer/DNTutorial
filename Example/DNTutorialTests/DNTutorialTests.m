//
//  DNTutorialTests.m
//  DNTutorialTests
//
//  Created by Daniel Niemeyer on 7/24/14.
//  Copyright (c) 2014 Daniel Niemeyer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DNTutorial.h"

NSInteger const sTutorialGestureAll = DNTutorialActionTapGesture | DNTutorialActionScroll | DNTutorialActionSwipeGesture;

@interface DNAppTutorialTests : XCTestCase <DNTutorialDelegate>

@property (nonatomic, strong) UIView        *containerView;
@property (nonatomic, assign) CGPoint       center;

@end

@implementation DNAppTutorialTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.center = containerView.center;
    self.containerView = containerView;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.containerView = nil;
    [super tearDown];
}

- (void)testTutorialSingleton;
{
    DNTutorialBanner *banner1 = [DNTutorialBanner bannerWithMessage:@"Test 1" completionMessage:@"Test 1 Passed!" key:@"bannerTest1"];
    DNTutorialGesture *gesture1 = [DNTutorialGesture gestureWithPosition:self.center type:DNTutorialGestureTypeScrollLeft key:@"gestureTest1"];
    DNTutorialGesture *gesture2 = [DNTutorialGesture gestureWithPosition:self.center type:DNTutorialGestureTypeTap key:@"gestureTest2"];

    DNTutorialStep *step1 = [DNTutorialStep stepWithTutorialElements:@[banner1, gesture1] forKey:@"stepTest1"];
    DNTutorialStep *step2 = [DNTutorialStep stepWithTutorialElements:@[banner1, gesture2] forKey:@"stepTest2"];
    DNTutorialStep *step3 = [DNTutorialStep stepWithTutorialElements:@[gesture1, banner1] forKey:@"stepTest3"];
    DNTutorialStep *step4 = [DNTutorialStep stepWithTutorialElements:@[gesture1, gesture2] forKey:@"stepTest4"];
    DNTutorialStep *step5 = [DNTutorialStep stepWithTutorialElements:@[gesture2, banner1] forKey:@"stepTest5"];
    DNTutorialStep *step6 = [DNTutorialStep stepWithTutorialElements:@[gesture2, gesture1] forKey:@"stepTest6"];

    [DNTutorial presentTutorialWithSteps:@[step1, step2, step3, step4, step5, step6] inView:self.containerView delegate:self];
    [DNTutorial presentStepForKey:@"stepTest4"];
    
    XCTAssertEqualObjects([DNTutorial currentStep], step1, @"DNAppTutorialTests:   Presenting wrong current step");
    XCTAssertEqualObjects([DNTutorial tutorialStepForKey:@"stepTest4"], step4, @"DNAppTutorialTests:   Presenting wrong current step");
    XCTAssertNotEqualObjects([DNTutorial tutorialStepForKey:@"stepTest1"], step3, @"DNAppTutorialTests:   Presenting wrong current step");
    XCTAssertEqualObjects([DNTutorial tutorialElementForKey:@"gestureTest2"], gesture2, @"DNAppTutorialTests:   Returning the wrong tutorial element");
    XCTAssertNotEqualObjects([DNTutorial tutorialElementForKey:@"gestureTest1"], banner1, @"DNAppTutorialTests:   Returning the wrong tutorial element");
    XCTAssertNil([DNTutorial tutorialElementForKey:@"gestureTest4"], @"DNAppTutorialTests:   Returning the wrong tutorial element");
}

- (void)testResetProgress;
{
    DNTutorialBanner *banner1 = [DNTutorialBanner bannerWithMessage:@"Test 1" completionMessage:@"Test 1 Passed!" key:@"bannerTest1"];
    DNTutorialGesture *gesture1 = [DNTutorialGesture gestureWithPosition:self.center type:DNTutorialGestureTypeScrollLeft key:@"gestureTest1"];
    DNTutorialGesture *gesture2 = [DNTutorialGesture gestureWithPosition:self.center type:DNTutorialGestureTypeTap key:@"gestureTest2"];
    
    DNTutorialStep *step1 = [DNTutorialStep stepWithTutorialElements:@[banner1, gesture1] forKey:@"stepTest1"];
    DNTutorialStep *step2 = [DNTutorialStep stepWithTutorialElements:@[banner1, gesture2] forKey:@"stepTest2"];
    DNTutorialStep *step3 = [DNTutorialStep stepWithTutorialElements:@[gesture1, banner1] forKey:@"stepTest3"];
    DNTutorialStep *step4 = [DNTutorialStep stepWithTutorialElements:@[gesture1, gesture2] forKey:@"stepTest4"];
    DNTutorialStep *step5 = [DNTutorialStep stepWithTutorialElements:@[gesture2, banner1] forKey:@"stepTest5"];
    DNTutorialStep *step6 = [DNTutorialStep stepWithTutorialElements:@[gesture2, gesture1] forKey:@"stepTest6"];
    
    [DNTutorial presentTutorialWithSteps:@[step1, step2, step3, step4, step5, step6] inView:self.containerView delegate:self];
    
    [step1 setCompleted:YES];
    [step4 setCompleted:YES];
    [step3 setCompleted:NO];
    [DNTutorial completedStepForKey:@"stepTest2"];
    
    XCTAssertTrue(step2.isCompleted, @"DNAppTutorialTests:   Step returning the wrong completion status");
    
    [DNTutorial resetProgress];
    
    XCTAssertFalse(step2.isCompleted, @"DNAppTutorialTests:   Step returning the wrong completion status");
}

- (void)testTutorialBanners;
{
    DNTutorialBanner *banner1 = [DNTutorialBanner bannerWithMessage:@"Test 1" completionMessage:@"Test 1 Passed!" key:@"bannerTest1"];
    DNTutorialBanner *banner2 = [DNTutorialBanner bannerWithMessage:@"Test 2" completionMessage:@"Test 2 Passed!" key:@"bannerTest2"];

    XCTAssertNotNil(banner1, @"DNAppTutorialTests:   Cannot present a nil banner");
    XCTAssertEqual(banner1.tutorialActions, DNTutorialActionBanner, @"DNAppTutorialTests:   Tutorial element returning the wrong actions");
    XCTAssertNotEqual(banner1.tutorialActions, DNTutorialActionNone, @"DNAppTutorialTests:   Tutorial element returning the wrong actions");
    XCTAssertNotEqual(banner2.tutorialActions, sTutorialGestureAll, @"DNAppTutorialTests:   Tutorial element returning the wrong actions");
}

- (void)testTutorialGestures;
{
    DNTutorialGesture *gesture1 = [DNTutorialGesture gestureWithPosition:self.center type:DNTutorialGestureTypeScrollLeft key:@"gestureTest1"];
    DNTutorialGesture *gesture2 = [DNTutorialGesture gestureWithPosition:self.center type:DNTutorialGestureTypeSwipeRight key:@"gestureTest2"];
    DNTutorialGesture *gesture3 = [DNTutorialGesture gestureWithPosition:self.center type:DNTutorialGestureTypeTap key:@"gestureTest3"];
    DNTutorialGesture *gesture4 = [DNTutorialGesture gestureWithPosition:self.center type:DNTutorialGestureTypeDoubleTap key:@"gestureTest4"];
    
    XCTAssertNotNil(gesture1, @"DNAppTutorialTests:   Cannot present a nil gesture");
    XCTAssertNotEqual(gesture1.gestureType, 0, @"DNAppTutorialTests:   Cannot present a gesture with nil direction");
    
    XCTAssertEqual(gesture1.tutorialActions, DNTutorialActionScroll, @"DNAppTutorialTests:   Tutorial element returning the wrong actions");
    XCTAssertEqual(gesture2.tutorialActions, DNTutorialActionSwipeGesture, @"DNAppTutorialTests:   Tutorial element returning the wrong actions");
    XCTAssertEqual(gesture3.tutorialActions, sTutorialGestureAll, @"DNAppTutorialTests:   Tutorial element returning the wrong actions");
    XCTAssertEqual(gesture4.tutorialActions, sTutorialGestureAll, @"DNAppTutorialTests:   Tutorial element returning the wrong actions");
}

- (void)testPresentTutorial;
{
    DNTutorialBanner *banner1 = [DNTutorialBanner bannerWithMessage:@"Test 1" completionMessage:@"Test 1 Passed!" key:@"bannerTest1"];
    DNTutorialBanner *banner2 = [DNTutorialBanner bannerWithMessage:@"Test 2" completionMessage:@"Test 2 Passed!" key:@"bannerTest2"];
    DNTutorialBanner *banner3 = [DNTutorialBanner bannerWithMessage:@"Test 3" completionMessage:@"Test 3 Passed!" key:@"bannerTest3"];
    
    DNTutorialGesture *gesture1 = [DNTutorialGesture gestureWithPosition:self.center type:DNTutorialGestureTypeScrollLeft key:@"gestureTest1"];
    DNTutorialGesture *gesture2 = [DNTutorialGesture gestureWithPosition:self.center type:DNTutorialGestureTypeTap key:@"gestureTest2"];
    DNTutorialGesture *gesture3 = [DNTutorialGesture gestureWithPosition:self.center type:DNTutorialGestureTypeSwipeDown key:@"gestureTest3"];
    
    DNTutorialStep *step1 = [DNTutorialStep stepWithTutorialElements:@[banner1, gesture1] forKey:@"stepTest1"];
    DNTutorialStep *step2 = [DNTutorialStep stepWithTutorialElements:@[banner2, gesture2] forKey:@"stepTest2"];
    DNTutorialStep *step3 = [DNTutorialStep stepWithTutorialElements:@[banner3, gesture3] forKey:@"stepTest3"];
    
    [DNTutorial presentTutorialWithSteps:@[step1, step2, step3] inView:self.containerView delegate:self];
    
    XCTAssertEqual([DNTutorial currentStep], step1, @"DNAppTutorialTests:   Presenting the wrong tutorial step");
    XCTAssertNotEqual([DNTutorial currentStep], step2, @"DNAppTutorialTests:   Presenting the wrong tutorial step");
}

- (void)testTutorialStep;
{
    DNTutorialBanner *banner1 = [DNTutorialBanner bannerWithMessage:@"Test 1" completionMessage:@"Test 1 Passed!" key:@"bannerTest1"];
    DNTutorialGesture *gesture1 = [DNTutorialGesture gestureWithPosition:self.center type:DNTutorialGestureTypeScrollLeft key:@"gestureTest1"];
    DNTutorialStep *step1 = [DNTutorialStep stepWithTutorialElements:@[banner1, gesture1] forKey:@"stepTest1"];

    // Step testing
    XCTAssertEqual([step1 tutorialElementForKey:@"bannerTest1"], banner1, @"DNAppTutorialTests:   Step returning the wrong tutorial element");
    XCTAssertEqual([step1 tutorialElementForKey:@"gestureTest1"], gesture1, @"DNAppTutorialTests:   Step returning the wrong tutorial element");
    XCTAssertNil([step1 tutorialElementForKey:@"gestureTest2"], @"DNAppTutorialTests:   Step returning the wrong tutorial element");
    
    // Action testing
    XCTAssertEqualObjects([step1 tutorialElementsWithAction:DNTutorialActionSwipeGesture], @[], @"DNAppTutorialTests:   Step returning the wrong tutorial action");
    XCTAssertNotNil([step1 tutorialElementsWithAction:DNTutorialActionScroll], @"DNAppTutorialTests:   Step returning the wrong tutorial action");
    XCTAssertEqualObjects([step1 tutorialElementsWithAction:DNTutorialActionBanner], @[banner1], @"DNAppTutorialTests:   Step returning the wrong tutorial action");
    XCTAssertEqualObjects([step1 tutorialElementsWithAction:DNTutorialActionScroll], @[gesture1], @"DNAppTutorialTests:   Step returning the wrong tutorial action");
    
    // Element actions
    XCTAssertFalse([step1 tutorialElement:banner1 respondsToActions:DNTutorialActionNone], @"DNAppTutorialTests:   Step returning the wrong element action");
    XCTAssertTrue([step1 tutorialElement:banner1 respondsToActions:DNTutorialActionBanner], @"DNAppTutorialTests:   Step returning the wrong element action");
    XCTAssertFalse([step1 tutorialElement:banner1 respondsToActions:DNTutorialActionSwipeGesture], @"DNAppTutorialTests:   Step returning the wrong element action");
    XCTAssertTrue([step1 tutorialElement:gesture1 respondsToActions:DNTutorialActionScroll], @"DNAppTutorialTests:   Step returning the wrong element action");
    XCTAssertFalse([step1 tutorialElement:gesture1 respondsToActions:DNTutorialActionSwipeGesture], @"DNAppTutorialTests:   Step returning the wrong element action");

    // Completion testing
    [step1 setCompleted:YES];
    XCTAssertTrue(step1.isCompleted, @"DNAppTutorialTests:   Step returning the wrong completion status");
    
    [step1 setCompleted:NO];
    XCTAssertFalse(step1.isCompleted, @"DNAppTutorialTests:   Step returning the wrong completion status");
}

- (void)testPercentageCompletion;
{
    DNTutorialBanner *banner1 = [DNTutorialBanner bannerWithMessage:@"Test 1" completionMessage:@"Test 1 Passed!" key:@"bannerTest1"];
    DNTutorialGesture *gesture1 = [DNTutorialGesture gestureWithPosition:self.center type:DNTutorialGestureTypeScrollLeft key:@"gestureTest1"];
    DNTutorialStep *step1 = [DNTutorialStep stepWithTutorialElements:@[banner1, gesture1] forKey:@"stepTest1"];
    DNTutorialStep *step2 = [DNTutorialStep stepWithTutorialElements:@[gesture1, banner1] forKey:@"stepTest2"];
    DNTutorialStep *step3 = [DNTutorialStep stepWithTutorialElements:@[banner1, banner1] forKey:@"stepTest3"];
    
    [step1 setPercentageCompleted:0.5];
    [step2 setPercentageCompleted:0.5];
    [step3 setPercentageCompleted:-0.5];
    XCTAssertFalse(step1.isCompleted, @"DNAppTutorialTests:   Step returning the wrong completion status");
    
    [step1 setPercentageCompleted:1.0];
    XCTAssertTrue(step1.isCompleted, @"DNAppTutorialTests:   Step returning the wrong completion status");
    
    // Percentage completion
    XCTAssertEqual(banner1.percentageCompleted, 1.0, @"DNAppTutorialTests:   Step returning the wrong percentage status");
    XCTAssertEqual(gesture1.percentageCompleted, 1.0, @"DNAppTutorialTests:   Step returning the wrong percentage status");
    XCTAssertEqual(step1.percentageCompleted, 1.0, @"DNAppTutorialTests:   Step returning the wrong percentage status");
    XCTAssertEqual(step2.percentageCompleted, 0.5, @"DNAppTutorialTests:   Step returning the wrong percentage status");
    XCTAssertEqual(step3.percentageCompleted, 0.0, @"DNAppTutorialTests:   Step returning the wrong percentage status");
}

@end
