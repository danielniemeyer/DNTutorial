//
//  DNRootController.m
//  DNTutorial
//
//  Created by Daniel Niemeyer on 7/29/14.
//  Copyright (c) 2014 Daniel Niemeyer. All rights reserved.
//

#import "DNRootController.h"
#import "DNViewController.h"

NSInteger const sScrollViewPageCount = 2;

#define kPageControlHeight 45

@interface DNRootController ()

@property (nonatomic, strong) NSMutableArray *viewControllers;

@end

@implementation DNRootController


#pragma mark --
#pragma mark Initialization
#pragma mark --

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < sScrollViewPageCount; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    // a page is the width of the scroll view
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(screenSize.width * sScrollViewPageCount, screenSize.height - kPageControlHeight);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    self.pageControl.numberOfPages = sScrollViewPageCount;
    self.pageControl.currentPage = 0;
    
    [self gotoPage:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Tutorial
    [self presentTutorial];
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStoryboard *)mainStoryboard;
{
    NSString *storyboardName = @"Storyboard";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        storyboardName = @"Main_iPad";
    
    return [UIStoryboard storyboardWithName:storyboardName bundle:nil];
}

#pragma mark --
#pragma mark DNTutorial Delegate
#pragma mark --

- (void)presentTutorial;
{
    CGPoint center, buttonCenter, objectCenter;
    center = buttonCenter = objectCenter = self.view.center;

    center.x += 50;
    buttonCenter.y = 60;
    
    DNTutorialBanner *banner1 = [DNTutorialBanner bannerWithMessage:@"Tap and swipe left to navigate to the next page. Swipe anywhere left or right to skip pages." completionMessage:@"Congratulations! You now know how to navigate throughout the app." key:@"initialBanner"];
    DNTutorialBanner *banner2 = [DNTutorialBanner bannerWithMessage:@"Tap 'complete action' to continue." completionMessage:@"Congratulations! You now know how to complete actions" key:@"secondBanner"];
    DNTutorialBanner *banner3 = [DNTutorialBanner bannerWithMessage:@"Tap and swipe down to drag objects across the screen." completionMessage:@"Congratulations! You now know how use swipe gestures" key:@"thirdBanner"];
    
    [banner2 styleWithColor:[UIColor blackColor] completedColor:[UIColor blueColor] opacity:0.7 font:[UIFont systemFontOfSize:13]];
    
    DNTutorialGesture *scrollGesture = [DNTutorialGesture gestureWithPosition:center type:DNTutorialGestureTypeScrollLeft key:@"firstGesture"];
    DNTutorialGesture *tapGesture = [DNTutorialGesture gestureWithPosition:buttonCenter type:DNTutorialGestureTypeTap key:@"tapGesture"];
    DNTutorialGesture *swipeGesture = [DNTutorialGesture gestureWithPosition:objectCenter type:DNTutorialGestureTypeSwipeDown key:@"secondGesture"];

    DNTutorialAudio *audio1 = [DNTutorialAudio audioWithPath:@"completionSound" ofType:@"wav" key:@"firstAudio"];
    
// Movement beta
//    DNTutorialMovement *movement1 = [DNTutorialMovement movementWithDirection:DNTutorialMovementDirectionUp key:@"firstMovement"];
    
    DNTutorialStep *step1 = [DNTutorialStep stepWithTutorialElements:@[banner1, scrollGesture, audio1] forKey:@"firtStep"];
    DNTutorialStep *step2 = [DNTutorialStep stepWithTutorialElements:@[banner2, tapGesture] forKey:@"secondStep"];
    DNTutorialStep *step3 = [DNTutorialStep stepWithTutorialElements:@[banner3, swipeGesture] forKey:@"thirdStep"];
    
    [DNTutorial presentTutorialWithSteps:@[step1, step2, step3] inView:self.view delegate:self];
}

- (BOOL)shouldPresentStep:(DNTutorialStep *)step forKey:(NSString *)aKey;
{
    return YES;
}

- (BOOL)shouldAnimateStep:(DNTutorialStep *)step forKey:(NSString *)aKey;
{
    if ([aKey isEqualToString:@"secondStep"] || [aKey isEqualToString:@"thirdStep"])
    {
        return self.pageControl.currentPage == 1;
    }
    
    return YES;
}

#pragma mark --
#pragma mark Screen rotation
#pragma mark --

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;
{
    // Tutorial
    [DNTutorial willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
    
    // View rotations
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    self.scrollView.contentSize = CGSizeMake(screenSize.width * sScrollViewPageCount, screenSize.height - kPageControlHeight);
    
    for (UIViewController *viewController in self.viewControllers)
    {
        [viewController.view removeFromSuperview];
    }
    
    [self gotoPage:NO];
}

- (void)willAnimateElement:(DNTutorialElement *)element toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    if ([element isKindOfClass:[DNTutorialGesture class]])
    {
        // Reposition center
        CGPoint center, buttonCenter, objectCenter;
        center = buttonCenter = objectCenter = self.view.center;
        
        center.x += 50;
        buttonCenter.y = 60;
        
        if ([element.key isEqualToString:@"firstGesture"])
        {
            [(DNTutorialGesture *)element setPosition:center];
        }
        else if ([element.key isEqualToString:@"tapGesture"])
        {
            [(DNTutorialGesture *)element setPosition:buttonCenter];
        }
        else if ([element.key isEqualToString:@"secondGesture"])
        {
            [(DNTutorialGesture *)element setPosition:objectCenter];
        }
    }
}

#pragma mark --
#pragma mark ScrollView
#pragma mark --

- (void)loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= 2)
        return;
    
    DNViewController *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        if (page == 0)
            controller = [[self mainStoryboard] instantiateViewControllerWithIdentifier:@"DNFirstController"];
        else
            controller = [[self mainStoryboard] instantiateViewControllerWithIdentifier:@"DNViewController"];
        
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    if (controller.view.superview == nil)
    {
        CGRect frame = self.scrollView.frame;
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        frame.origin.x = screenSize.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        
        [self addChildViewController:controller];
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [DNTutorial scrollViewWillBeginDragging:scrollView];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [DNTutorial scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    [DNTutorial scrollViewDidEndDecelerating:scrollView];
}

#pragma mark --
#pragma mark Pagination
#pragma mark --

- (void)gotoPage:(BOOL)animated
{
    NSInteger page = self.pageControl.currentPage;
    
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    [self.scrollView scrollRectToVisible:bounds animated:animated];
}

- (IBAction)changePage:(id)sender
{
    [self gotoPage:YES];
}

@end
