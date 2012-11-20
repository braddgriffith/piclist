//
//  PhotoScreenViewController.h
//  PicList
//
//  Created by Brad Grifffith on 11/7/12.
//  Copyright (c) 2012 Brad Grifffith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "SoldViewController.h"

@interface PhotoScreenViewController : UIViewController //<UIImagePickerControllerDelegate, PF_MBProgressHUDDelegate>
{
    IBOutlet UIImageView* photo;
    MBProgressHUD *HUD;
    MBProgressHUD *refreshHUD;
}

@property (nonatomic, strong)PFObject *userPhoto;

+ (PhotoScreenViewController *)photoVC;

@end
