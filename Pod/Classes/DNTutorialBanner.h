//
//  DNTutorialBanner.h
//  DNTutorial
//
//  Created by Daniel Niemeyer on 7/24/14.
//  Copyright (c) 2014 Daniel Niemeyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "DNTutorialElement.h"

@interface DNTutorialBanner : DNTutorialElement

// Public method for instantiating a new DNTutorialBanner with an appropriate message
+ (id)bannerWithMessage:(NSString *)message
      completionMessage:(NSString *)completionMessage
                    key:(NSString *)key;


// Style banner
- (void)styleWithColor:(UIColor *)color
        completedColor:(UIColor *)completedColor
               opacity:(CGFloat)opacity
                  font:(UIFont *)font;

// Banner background color, defaults to light gray
- (void)setBannerColor:(UIColor *)bannerColor;

// Banner completed color
- (void)setCompletedColor:(UIColor *)completedColor;

// Banner alpha, defaults to 0.8
- (void)setBannerOpacity:(CGFloat)opacity;

// Banner font, defaults to system font of size 17
- (void)setBannerFont:(UIFont *)font;

// Banner completion delay in seconds, defaults to 2 seconds.
- (void)setCompletedDelay:(NSUInteger)completedDelay;

@end
