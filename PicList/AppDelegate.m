//
//  AppDelegate.m
//  PicList
//
//  Created by Brad Grifffith on 11/7/12.
//  Copyright (c) 2012 Brad Grifffith. All rights reserved.
//

#import "AppDelegate.h"
#import "WelcomeViewController.h"
#import "User.h"
#import <Parse/Parse.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize user = _user;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // ****************************************************************************
    // Fill in with your Parse credentials:
    // ****************************************************************************
    [Parse setApplicationId:@"34jkXHSyb1j5lW4isKEYSl4esKjBfd3doc8jZqbm" clientKey:@"1k8dCabKT2B9pDVqWp5BBpDhvF401573iyL8mk7i"];
    
    // Wipe out old user defaults
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"objectIDArray"]){
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"objectIDArray"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
        
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *userData = [currentDefaults objectForKey:@"user"];
    
    if (userData) {
        self.user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
        NSLog(@"Loaded stored user.");
    }
    if (!self.user) {
        self.user = [[User alloc] init];
        NSLog(@"Created new user.");
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

+ (AppDelegate *)appDelegate
{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

+ (User *)user
{
    return ((AppDelegate*)[[UIApplication sharedApplication] delegate]).user;
}


@end
