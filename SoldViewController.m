//
//  SoldViewController.m
//  PicList
//
//  Created by Brad Grifffith on 11/9/12.
//  Copyright (c) 2012 Brad Grifffith. All rights reserved.
//

#import "SoldViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "User.h"
#import <Quartzcore/Quartzcore.h>

@interface SoldViewController ()
- (IBAction)emailConfirmed;
@end

@implementation SoldViewController

@synthesize userPhoto;

@synthesize orderNumberLabel;
@synthesize paypalEmailField;
@synthesize activeField;

@synthesize submitButton;

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
    
    localUser = [AppDelegate user];
    
    self.paypalEmailField.delegate = self;
    
    NSString *email = localUser.paypalEmail;
    self.paypalEmailField.text = email;
    
    self.orderNumberLabel.text = self.userPhoto.objectId;
    
    float cornerRadius = 8.0;
    
    [self.submitButton.layer setBorderWidth:2.0];
    [self.submitButton.layer setCornerRadius:cornerRadius];
    [self.submitButton.layer setBorderColor:[[UIColor colorWithWhite:0.3 alpha:0.7] CGColor]];
    
    //http://undefinedvalue.com/2010/02/27/shiny-iphone-buttons-without-photoshop
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.frame = self.submitButton.bounds;
    shineLayer.cornerRadius = cornerRadius;
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         nil];
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    [self.submitButton.layer addSublayer:shineLayer];
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
    
    localUser.paypalEmail = dataElement;
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Address Accepted"
                          //message:@"We're processing your Paypal payment."
                          message:@"We've stored your email address and will reach out to you with your tax deduction."
                          delegate:self
                          //cancelButtonTitle:@"Sell Again"
                          cancelButtonTitle:@"Donate Again"
                          otherButtonTitles:@"Done", nil];
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
            [self dismissModalViewControllerAnimated:YES];
        }
    } else if (buttonIndex == 1) {
        if (alertView.tag == 10) {
            [self dismissModalViewControllerAnimated:YES];
        }
    }
}

- (IBAction)emailConfirmed
{
    //NSDictionary *new = [[NSDictionary alloc] init];
//    [PFCloud callFunctionInBackground:@"sendReceipt" withParameters:(NSDictionary *new) block:^(id object, NSError *error) {
//        if(!error) {
//            NSLog(@"Receipt Sent");
//        }
//    }];
    [self dismissModalViewControllerAnimated:YES];
}

@end
