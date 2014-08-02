//
//  DNTutorialTests.m
//  DNTutorialTests
//
//  Created by Daniel Niemeyer on 7/24/14.
//  Copyright (c) 2014 Daniel Niemeyer. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "DNTutorial.h"

@interface DNAppTutorialTests : XCTestCase <DNTutorialDelegate>

@property (nonatomic, strong) UIView        *containerView;

@end

@implementation DNAppTutorialTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.containerView = containerView;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.containerView = nil;
    [super tearDown];
}

- (void)testTutorialBanner
{
    DNTutorialBanner *banner = [DNTutorialBanner bannerWithMessage:@"A test banner" key:@"testBanner"];
    XCTAssertNotNil(banner, @"DNAppTutorialTests:   Cannot present a nil banner");
}

- (void)testTutorialGesture
{
    DNTutorialGesture *gesture = [DNTutorialGesture gestureWithPosition:CGPointZero direction:DNTutorialGestureDirectionDown key:@"testGesture"];
    //[[DNAppTutorial sharedInstance] presentTutorialWithObjects:@[gesture] inView:self.containerView delegate:self];
    XCTAssertNotNil(gesture, @"DNAppTutorialTests:   Cannot present a nil gesture");
    XCTAssertNotEqual(gesture.gestureDirection, 0, @"DNAppTutorialTests:   Cannot present a gesture with nil direction");
}

@end
