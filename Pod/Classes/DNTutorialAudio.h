//
//  DNTutorialAudio.h
//  Pods
//
//  Created by Daniel Niemeyer on 3/31/15.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "DNTutorialElement.h"

@interface DNTutorialAudio : DNTutorialElement

// Instantiate a new audio tutorial with the given audio URL
+ (id)audioWithURL:(NSURL *)URL
               key:(NSString *)key;

// Instantiate a new audio tutorial with the given audio file
+ (id)audioWithPath:(NSString *)path
             ofType:(NSString *)type
               key:(NSString *)key;

@end
