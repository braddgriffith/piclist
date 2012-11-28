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
@synthesize exampleImageView;

int buffer = 20;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.navigationController.navigationBar.tintColor = [UIColor redColor];
    self.navigationController.navigationBar.alpha = 0.9f;
    self.navigationController.navigationBar.translucent = NO;
    
    [self.scrollView setScrollEnabled:YES];
    
    
    //Calculate the expected size based on the font and linebreak mode of your label
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width - (2*buffer),9999);
    
    CGSize expectedLabelSize = [self.instructions.text sizeWithFont:self.instructions.font constrainedToSize:maximumLabelSize lineBreakMode:self.instructions.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = self.instructions.frame;
    newFrame.size.height = expectedLabelSize.height;
    self.instructions.frame = newFrame;
    
    self.instructions.textColor = [UIColor whiteColor];
    
    [self.scrollView addSubview:instructions];
    
    CGImageRef imageRef = [[UIImage imageNamed:@"GiantsExample.JPG"] CGImage];
    UIImage *rotatedImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationRight];
    
    self.exampleImageView.image = rotatedImage;
    
    int startHeight = self.instructions.frame.size.height + self.navigationController.navigationBar.frame.size.height;
    int newWidth = self.view.frame.size.width - (2*buffer);
    
    float scaleFactor = newWidth / rotatedImage.size.width;
    float newHeight = rotatedImage.size.height * scaleFactor;
    
    self.exampleImageView.frame = CGRectMake(
                                          buffer,
                                          startHeight, newWidth, newHeight);
    
    [self.scrollView addSubview:exampleImageView];
    
    int scrollviewHeight = startHeight + newHeight + buffer;
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, scrollviewHeight); 
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
