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

@end

@implementation DNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    // [DNTutorial advanceTutorialSequenceWithName:@"example"];
}

- (IBAction)investButtonAction:(id)sender
{
    [DNTutorial completedStepForKey:@"secondStep"];
}

- (IBAction)resetAction:(id)sender
{
    [DNTutorial resetProgress];
}

@end
