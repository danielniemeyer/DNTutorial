//
//  DNTutorialMovement.h
//  Pods
//
//  Created by Daniel Niemeyer on 3/31/15.
//
//

#import "DNTutorialElement.h"

typedef NS_ENUM (NSUInteger, DNTutorialMovementDirection)
{
    DNTutorialMovementDirectionUp = 0,
    DNTutorialMovementDirectionRight = 1,
    DNTutorialMovementDirectionDown = 2,
    DNTutorialMovementDirectionLeft = 3,
};

@interface DNTutorialMovement : DNTutorialElement

// Public method for instantiating a new DNTutorialMovement with the appropriate direction
+ (id)movementWithDirection:(DNTutorialMovementDirection)direction
                    key:(NSString *)key;

@end
