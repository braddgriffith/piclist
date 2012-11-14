//
//  AppDelegate.h
//  PicList
//
//  Created by Brad Grifffith on 11/7/12.
//  Copyright (c) 2012 Brad Grifffith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WelceomeViewController.h"
#import "User.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) WelceomeViewController *viewController;

@property (strong, nonatomic) User *user;

+(UIApplication *)appDelegate;
//Call this to get the appDelegate
+ (User *)user;

@end
