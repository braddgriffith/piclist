//
//  ViewController.h
//  PicList
//
//  Created by Brad Grifffith on 11/7/12.
//  Copyright (c) 2012 Brad Grifffith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#include <stdlib.h> // For math functions including arc4random (a number randomizer)

@interface WelcomeViewController : UIViewController
{
    IBOutlet UIImageView* photo;
    MBProgressHUD *HUD;
    MBProgressHUD *refreshHUD;
}

@property (nonatomic, strong) PFObject *userPhoto;
@property (nonatomic, strong) IBOutlet UIButton *sellButton;
@property (strong, nonatomic) IBOutlet UIImageView *exampleImages;
@property (nonatomic, strong) IBOutlet UIButton *infoButton;
@property (nonatomic, strong) IBOutlet UILabel *titleLine;
@property (nonatomic, strong) IBOutlet UILabel *lineOne;
@property (nonatomic, strong) IBOutlet UILabel *lineTwo;

- (IBAction)takePhoto;

@end
