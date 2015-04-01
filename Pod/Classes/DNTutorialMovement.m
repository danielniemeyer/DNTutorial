//
//  DNTutorialMovement.m
//  Pods
//
//  Created by Daniel Niemeyer on 3/31/15.
//
//

#import "DNTutorialMovement.h"

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
    return movement;
}

#pragma mark --
#pragma mark - Polimorphic Methods
#pragma mark --


@end
