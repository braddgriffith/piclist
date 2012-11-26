//
//  InfoViewController.m
//  PicList
//
//  Created by Brad Grifffith on 11/25/12.
//  Copyright (c) 2012 Brad Grifffith. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

@synthesize doneButton;
@synthesize scrollView;
@synthesize instructions;

int scrollviewHeight = 600;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.alpha = 0.9f;
    self.navigationController.navigationBar.translucent = NO;
    
    [self.scrollView setScrollEnabled:YES];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, scrollviewHeight); //Should be algorithmic based on size of content
    
    [self.scrollView addSubview:instructions];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)donePressed
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
