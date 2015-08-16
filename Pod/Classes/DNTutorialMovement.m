//
//  DNTutorialMovement.m
//  Pods
//
//  Created by Daniel Niemeyer on 3/31/15.
//
//

#import "DNTutorialMovement.h"

@interface DNTutorialMovement()

@property (nonatomic, strong) CMMotionManager   *motionManager;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@property (nonatomic, assign) CGFloat           xAcceleration;
@property (nonatomic, assign) CGFloat           yAcceleration;
@property (nonatomic, assign) CGFloat           zAcceleration;

@end

@implementation DNTutorialMovement

#pragma mark --
#pragma mark - Initialization
#pragma mark --

+ (id)movementWithDirection:(DNTutorialMovementDirection)direction
                        key:(NSString *)key;
{
    // Proper initialization
    NSAssert(key != nil, @"DNTutorialMovement: Cannot initialize action with invalid key");
    
    DNTutorialMovement *movement = [DNTutorialMovement new];
    movement.key = key;
    movement.movementDirection = direction;
    return movement;
}

#pragma mark --
#pragma mark - Polimorphic Methods
#pragma mark --

- (void)setUpInView:(UIView *)aView;
{
    // Initialize motion manager
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:2];
    self.numberFormatter = numberFormatter;
    
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

- (void)tearDown;
{
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopGyroUpdates];
    self.motionManager = nil;
}

- (void)show;
{
    _actionCompleted = NO;
}

- (void)dismiss;
{
    // Will dismiss element
    [_delegate willDismissElement:self];
    

    
    [_delegate didDismissElement:self];
}

- (void)startAnimating;
{
    return;
}

- (void)stopAnimating;
{
    return;
}

- (void)setCompleted:(BOOL)completed animated:(BOOL)animated;
{
    if (_actionCompleted && completed) {
        return;
    }
    
    _actionCompleted = completed;
    
    if (completed)
    {
        // Should dismiss
        [self dismiss];
    }
}

- (void)setPercentageCompleted:(CGFloat)percentage;
{
    // percentage alpha and position based on position
    if (percentage < 0 || _actionCompleted)
    {
        return;
    }
    
    _percentageCompleted = percentage;
    
    if (percentage >= 1.0)
    {
        // User action completed
        [self setCompleted:YES animated:NO];
    }
}

#pragma mark --
#pragma mark - Private Methods
#pragma mark --

- (void)outputAccelerometerData:(CMAcceleration)acceleration;
{
    // Check accelerometer direction
    switch (self.movementDirection)
    {
        case DNTutorialMovementDirectionUp:
        {
            
            NSString* formattedNumber = [NSString stringWithFormat:@"%.02f", acceleration.x];
            CGFloat roundedAcceleration = atof([formattedNumber UTF8String]);
            
            if (self.xAcceleration != roundedAcceleration)
            {
                self.xAcceleration = roundedAcceleration;
                NSLog(@"Acceleration.x %f", roundedAcceleration);
            }
        }
        break;
        case DNTutorialMovementDirectionDown:
        {
            
        }
        break;
        case DNTutorialMovementDirectionLeft:
        {
            
        }
        break;
        case DNTutorialMovementDirectionRight:
        {
            
        }
        break;
            
        default:
            break;
    }
}

- (void)outputRotationData:(CMRotationRate)rotation;
{
    //NSLog(@"rX: %.2fr/s",rotation.x);
    //NSLog(@"rY %.2fr/s",rotation.y);
    //NSLog(@"rZ %.2fr/s",rotation.z);
}

@end
