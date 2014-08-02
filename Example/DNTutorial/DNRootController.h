//
//  DNRootController.h
//  DNTutorial
//
//  Created by Daniel Niemeyer on 7/29/14.
//  Copyright (c) 2014 Daniel Niemeyer. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DNTutorial.h"

@interface DNRootController : UIViewController <UIScrollViewDelegate, DNTutorialDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

@end
