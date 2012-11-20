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

@interface WelceomeViewController : UIViewController
{
    IBOutlet UIImageView* photo;
    MBProgressHUD *HUD;
    MBProgressHUD *refreshHUD;
}

@property (nonatomic, strong) PFObject *userPhoto;
@property (nonatomic, strong) IBOutlet UIButton *sellButton;
@property (strong, nonatomic) IBOutlet UIImageView *exampleImages;

@end
