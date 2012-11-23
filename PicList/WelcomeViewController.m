//
//  WelcomeViewController.m
//  PicList
//
//  Created by Brad Grifffith on 11/7/12.
//  Copyright (c) 2012 Brad Grifffith. All rights reserved.
//

#import "WelcomeViewController.h"
#import "SoldViewController.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface WelcomeViewController ()
-(IBAction)takePhoto;
@end

@implementation WelcomeViewController

@synthesize sellButton;
@synthesize exampleImages;
@synthesize userPhoto;

int i = 0;
NSData *imageData;
int queryNumber;
PFFile *imageFile;
float uploadProgress = 0.0;
float researchProgress = 0.0;
MBProgressHUD *uploadingHUD;
MBProgressHUD *researchingHUD;
int originalImageX;
int originalImageY;
int originalImageWidth;
int originalImageHeight;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    originalImageX = self.exampleImages.frame.origin.x;
    originalImageY = self.exampleImages.frame.origin.y;
    originalImageWidth = self.exampleImages.frame.size.width;
    originalImageHeight = self.exampleImages.frame.size.height;
    
    float cornerRadius = 10.0;
    
    [self.sellButton.layer setBorderWidth:2.0];
    [self.sellButton.layer setCornerRadius:cornerRadius];
    [self.sellButton.layer setBorderColor:[[UIColor colorWithWhite:0.3 alpha:0.7] CGColor]];
    
    //http://undefinedvalue.com/2010/02/27/shiny-iphone-buttons-without-photoshop
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.frame = self.sellButton.bounds;
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
    [self.sellButton.layer addSublayer:shineLayer];

    CGImageRef imageRef = [[UIImage imageNamed:@"GiantsExample.JPG"] CGImage];
    UIImage *rotatedImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationRight];
    
    self.exampleImages.image = rotatedImage;
}

- (void)viewWillAppear:(BOOL)animated
{    
    [uploadingHUD removeFromSuperview];
    [researchingHUD removeFromSuperview];
    uploadProgress = 0.0;
    researchProgress = 0.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)takePhoto
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
#if TARGET_IPHONE_SIMULATOR
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#else
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
#endif
    imagePickerController.editing = YES; //SEE IF THIS IS NECESSARY
    imagePickerController.delegate = (id)self;
    
    uploadProgress = 0.0;
    researchProgress = 0.0;
    
    [self presentModalViewController:imagePickerController animated:YES];
}

#pragma mark - Image picker delegate methdos
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    photo.image = image;
    [picker dismissModalViewControllerAnimated:NO];
    
    imageData = UIImageJPEGRepresentation(image, 0.05f);
    
    [self uploadNotification];
    [self uploadImage:imageData];
    uploadingHUD = [[MBProgressHUD alloc] initWithView:self.view];
    uploadingHUD.labelText = @"Uploading";
    uploadingHUD.mode = MBProgressHUDModeDeterminate;
    [self.view addSubview:uploadingHUD];
    [uploadingHUD showWhileExecuting:@selector(uploading) onTarget:self withObject:nil animated:YES];
}

#pragma mark - Upload image to Parse
- (void)uploadImage:(NSData *)imageData
{
    int newWidth = self.view.frame.size.width - 40;
    int newHeight = self.view.frame.size.height - 40;
    
    self.exampleImages.frame = CGRectMake(
                                 20,
                                 20, newWidth, newHeight);
    
    self.exampleImages.image = [UIImage imageWithData:imageData];
    
    imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            // Create a PFObject around a PFFile and associate it with the current user
            self.userPhoto = [PFObject objectWithClassName:@"UserPhoto"];
            [self.userPhoto setObject:imageFile forKey:@"imageFile"];
            
            // Set the access control list to current user for security purposes
            self.userPhoto.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            
            PFUser *user = [PFUser currentUser];
            [self.userPhoto setObject:user forKey:@"user"];
            
            [self.userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    uploadingHUD.labelText = @"Success!";
                    [uploadingHUD removeFromSuperview];
                    researchingHUD = [[MBProgressHUD alloc] initWithView:self.view];
                    researchProgress = 0.0;
                    researchingHUD.labelText = @"Evaluating";
                    researchingHUD.mode = MBProgressHUDModeDeterminate;
                    [self.view addSubview:researchingHUD];
                    [researchingHUD showWhileExecuting:@selector(researching) onTarget:self withObject:nil animated:YES];
                    [self priceThis];
                }
                else{
                    // Log details of the failure
                    NSLog(@"Error saving photo: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else{
            [HUD hide:YES]; //BRING THIS BACK LATER
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        // Update your progress spinner here. percentDone will be between 0 and 100.
        HUD.progress = (float)percentDone/100; //BRING THIS BACK LATER
    }];
}

- (void)uploading
{
    while (uploadProgress < 1.0) {
        uploadProgress += 0.007;
        uploadingHUD.progress = uploadProgress;
        usleep(50000);
    }
}

- (void)researching
{
    while (researchProgress < 1.0) {
        researchProgress += 0.0015;
        researchingHUD.progress = researchProgress;
        if (researchProgress < 0.10) {
            [researchingHUD setLabelText:@"Evaluating"];
        } else if (researchProgress < 0.35) {
            [researchingHUD setLabelText:@"Authenticating"];
        } else if (researchProgress < 0.75) {
            [researchingHUD setLabelText:@"Researching"];
        } else if (researchProgress > 0.75) {
            [researchingHUD setLabelText:@"Pricing"];
        }
        usleep(50000);
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (alertView.tag == 10) {
            
        } else if (alertView.tag == 20) {
            [HUD removeFromSuperview];
            PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
            NSLog(@"Looking for ... %@", self.userPhoto.objectId);
            [query getObjectInBackgroundWithId:self.userPhoto.objectId block:^(PFObject *retrievedPhoto, NSError *error) {
                if (!error) {
                    [retrievedPhoto setObject:@"Sold" forKey:@"Result"];
                    [retrievedPhoto saveInBackground];
                    NSLog(@"Sold set");
                } else {
                    // Log details of our failure
                    NSLog(@"Error setting Sold tag: %@ %@", error, [error userInfo]);
                }
            }];
            [self performSegueWithIdentifier: @"SoldSegue" sender: self];
        } else if (alertView.tag == 30) {
            [self takePhoto];
        } else if (alertView.tag == 40) {
            [HUD removeFromSuperview];
            [self takePhoto];
        }
    }
    if (buttonIndex == 1) {
        if (alertView.tag == 10) {
            //            [self takePhoto];
        } else if (alertView.tag == 20) {
            [HUD removeFromSuperview];
            [self takePhoto];
        } else if (alertView.tag == 40) {
            [HUD removeFromSuperview];
            [self takePhoto];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.exampleImages.frame = CGRectMake(
                                          originalImageX,
                                          originalImageY,
                                          originalImageWidth,
                                          originalImageHeight);
    
    CGImageRef imageRef = [[UIImage imageNamed:@"GiantsExample.JPG"] CGImage];
    UIImage *rotatedImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationRight];
    
    self.exampleImages.image = rotatedImage;
    
    if ([segue.identifier isEqualToString:@"SoldSegue"]){
        SoldViewController *controller = segue.destinationViewController;
        PFObject *passedPhoto = self.userPhoto;
        controller.userPhoto = passedPhoto;
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

// PRICE RETRIEVAL LOGIC

- (void)priceThis
{
    // Assume the fastest one could ever price a photo would be 1minute 30 seconds
    // Then assume check every X seconds until Y seconds total
    queryNumber = 0;
    
    [NSTimer scheduledTimerWithTimeInterval:3.0
                                     target:self
                                   selector:@selector(retrievePrice:)
                                   userInfo:nil
                                    repeats:YES];
}


// RETRIEVE PRICE

- (void)retrievePrice:(NSTimer*) t
{
    queryNumber++;
    NSLog(@"The query # is: %d", queryNumber);
    if (queryNumber>3) {
        PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
        NSLog(@"Looking for ... %@", self.userPhoto.objectId);
        [query getObjectInBackgroundWithId:self.userPhoto.objectId block:^(PFObject *retrievedPhoto, NSError *error) {
            if (!error) {
                // The get request succeeded.
                NSLog(@"The price was: $%@", [self.userPhoto objectForKey:@"PriceEach"]);
                if ([retrievedPhoto objectForKey:@"PriceEach"]) {
                    [t invalidate];
                    NSLog(@"Price retrieved, timer stopped at %d queries!", queryNumber);
                    [self offerPriceToUser:[retrievedPhoto objectForKey:@"PriceEach"]];
                }
            } else {
                // Log details of our failure
                NSLog(@"Error getting price: %@ %@", error, [error userInfo]);
            }
        }];
    }
    if (queryNumber>13) {
        [t invalidate];
        NSLog(@"Reached %d queries, timer stopped!", queryNumber);
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Couldn't Price Tickets"
                              message: @""
                              delegate: self
                              cancelButtonTitle:@"Retake"
                              otherButtonTitles:nil];
        [alert setTag:30];
        [alert show];
    }
}


// OFFER PRICE

-(void) offerPriceToUser:(NSString *)price
{
    [HUD removeFromSuperview];
    
    if ([price isEqualToString:@"?"]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Couldn't Authenticate Tickets"
                              message: @"Please ensure the section, row and seat numbers as well as the barcode are in focus."
                              delegate: self
                              cancelButtonTitle:@"Retake"
                              otherButtonTitles:nil];
        [alert setTag:40];
        [alert show];
    } else {
        NSString *offer = @"The price was: $";
        offer = [offer stringByAppendingString:price];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Sell Tickets?"
                              message: offer
                              delegate: self
                              cancelButtonTitle:@"Yes, Sell!"
                              otherButtonTitles:@"Cancel",nil];
        [alert setTag:20];
        [alert show];
    }
}

// TWILIO STARTS

- (void)uploadNotification
{/*
  NSLog(@"Sending request.");
  
  // Common constants
  NSString *kTwilioSID = @"AC252b94aee1e94cc7bc1fec605b194d6c";
  NSString *kTwilioSecret = @"51b92a4a1ecc1f2ce5bfff2f878e27bd";
  NSString *kFromNumber = @"+18583543381";
  NSString *kToNumber = @"+16198221406";
  NSString *kMessage = @"Hi%20there.";
  
  // Build request
  NSString *urlString = [NSString stringWithFormat:@"https://%@:%@@api.twilio.com/2010-04-01/Accounts/%@/SMS/Messages", kTwilioSID, kTwilioSecret, kTwilioSID];
  NSURL *url = [NSURL URLWithString:urlString];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
  [request setURL:url];
  [request setHTTPMethod:@"POST"];
  
  // Set up the body
  NSString *bodyString = [NSString stringWithFormat:@"From=%@&To=%@&Body=%@", kFromNumber, kToNumber, kMessage];
  NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
  [request setHTTPBody:data];
  NSError *error;
  NSURLResponse *response;
  NSData *receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
  
  // Handle the received data
  if (error) {
  NSLog(@"Error: %@", error);
  } else {
  NSString *receivedString = [[NSString alloc]initWithData:receivedData encoding:NSUTF8StringEncoding];
  NSLog(@"Request sent. %@", receivedString);
  }
  */
}   

- (void)viewDidUnload
{
    [self setExampleImages:nil];
    [super viewDidUnload];
}
@end
