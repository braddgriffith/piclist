//
//  InfoViewController.h
//  PicList
//
//  Created by Brad Grifffith on 11/25/12.
//  Copyright (c) 2012 Brad Grifffith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UILabel *instructions;
@property (nonatomic, strong) IBOutlet UIImageView *exampleImageView;

- (IBAction)donePressed;

@end
