//
//  DNViewController.m
//  DNTutorial
//
//  Created by Daniel Niemeyer on 7/24/14.
//  Copyright (c) 2014 Daniel Niemeyer. All rights reserved.
//

#import "DNViewController.h"

#import "DNTutorial.h"

@interface DNViewController ()
{
    BOOL isMovingSquare;
}

@property (nonatomic, strong) CMMotionManager   *motionManager;

@end

@implementation DNViewController

#pragma mark --
#pragma mark Initialization
#pragma mark --

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.imageView.image = [UIImage imageNamed:@"backgroundImage"];
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = 0.2f;
    self.motionManager.gyroUpdateInterval = 0.2f;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 [self outputAccelerometerData:accelerometerData.acceleration];
                                                 if (error)
                                                 {
                                                     NSLog(@"DNTutorialMovement:  Accelerometer queue error: %@", error);
                                                 }
                                             }];
    
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                                    withHandler:^(CMGyroData *gyroData, NSError *error) {
                                        [self outputRotationData:gyroData.rotationRate];
                                    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopGyroUpdates];
    self.motionManager = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    // [DNTutorial advanceTutorialSequenceWithName:@"example"];
}

#pragma mark --
#pragma mark Private Methods
#pragma mark --

- (IBAction)investButtonAction:(id)sender
{
    [DNTutorial completedStepForKey:@"secondStep"];
}

- (IBAction)dismissTutorial:(id)sender
{
    [DNTutorial hideTutorial];
}

- (IBAction)showTutorial:(id)sender
{
    [DNTutorial showTutorial];
}

- (IBAction)resetAction:(id)sender
{
    [DNTutorial resetProgress];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [(UITouch *)[touches anyObject] locationInView:self.view];
    [DNTutorial touchesBegan:touchPoint inView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [(UITouch *)[touches anyObject] locationInView:self.view];
    [DNTutorial touchesMoved:touchPoint destinationSize:CGSizeMake(0, -100)];
    self.square.center = touchPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [(UITouch *)[touches anyObject] locationInView:self.view];
    [DNTutorial touchesEnded:touchPoint destinationSize:CGSizeMake(0, -100)];
}

- (void)outputAccelerometerData:(CMAcceleration)acceleration;
{
    
}

- (void)outputRotationData:(CMRotationRate)rotation;
{
    CGFloat centerX = self.view.center.x + 50*rotation.y;
    CGFloat centerY = self.view.center.y + 50*rotation.x;
    
    CGPoint center = CGPointMake(centerX, centerY);
    
    [UIView animateWithDuration:0.24f animations:^{
        self.imageView.center = center;
    }];
}

@end
