//
//  SoldViewController.m
//  PicList
//
//  Created by Brad Grifffith on 11/9/12.
//  Copyright (c) 2012 Brad Grifffith. All rights reserved.
//

#import "SoldViewController.h"
#import "PhotoScreenViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "User.h"

@interface SoldViewController ()

@end

@implementation SoldViewController

@synthesize userPhoto;

@synthesize orderNumberLabel;
@synthesize paypalEmailField;
@synthesize activeField;

User *localUser;

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
    
    localUser = [AppDelegate user];
    
    self.paypalEmailField.delegate = self;
    
    //QUESTION #1
    self.orderNumberLabel.text = self.userPhoto.objectId;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidBeginEditing method");
    if (![textField.text isEqualToString:@""]) {
        textField.text = @"";
    }
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidEndEditing method");
    
    NSString *dataElement = self.paypalEmailField.text;
    NSLog(@"dataElement: %@", dataElement);
    NSLog(@"textfield.tag: %i", self.paypalEmailField.tag);
    
    //[localUser setEmail:dataElement];
    localUser.paypalEmail = dataElement;
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Address Accepted"
                          message:@"We're processing your Paypal payment."
                          delegate:self
                          cancelButtonTitle:@"Sell Again"
                          otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    alert.tag = 10;
    [alert show];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn method");
    [textField resignFirstResponder];
    
    return YES;
}


-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (alertView.tag == 10) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

@end
