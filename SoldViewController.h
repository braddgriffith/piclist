//
//  SoldViewController.h
//  PicList
//
//  Created by Brad Grifffith on 11/9/12.
//  Copyright (c) 2012 Brad Grifffith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SoldViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) PFObject *userPhoto;

@property (nonatomic, strong) IBOutlet UILabel *orderNumberLabel;
@property (nonatomic, strong) IBOutlet UITextField *paypalEmailField;
@property (nonatomic, strong) UITextField *activeField;

@property (nonatomic, strong) IBOutlet UIButton *submitButton;

- (IBAction)emailConfirmed;

@end
