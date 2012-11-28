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
@synthesize infoButton;

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
double uploadStep = 0.007;
double researchStep = 0.0015;
int prepQueries = 3;
int serverQueries = 13;
float queryTime = 3.0f;
float imageQuality = 0.05f;
NSString *kToNumber = @"+16198221406";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get defaults from Parse
    PFQuery *query = [PFQuery queryWithClassName:@"Defaults"];
    [query whereKey:@"objectId" equalTo:@"2v45cWF0do"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *defaults, NSError *error) {
        if (!error) {
            uploadStep = [[defaults objectForKey:@"UploadStep"] doubleValue];
            researchStep = [[defaults objectForKey:@"ResearchStep"] doubleValue];
            prepQueries = [[defaults objectForKey:@"PrepQueries"] intValue];
            serverQueries = [[defaults objectForKey:@"ServerQueries"] intValue];
            queryTime = [[defaults objectForKey:@"QueryTime"] floatValue];
            imageQuality = [[defaults objectForKey:@"ImageQuality"] floatValue];
            NSLog(@"uploadStep: %f", uploadStep);
            NSLog(@"researchStep: %f", researchStep);
            NSLog(@"researchStep: %d", prepQueries);
            NSLog(@"serverQueries: %d", serverQueries);
            NSLog(@"queryTime: %f", queryTime);
            NSLog(@"imageQuality: %f", imageQuality);
        } else {
            // Log details of our failure
            NSLog(@"Error setting Sold tag: %@ %@", error, [error userInfo]);
        }
    }];
    
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
    
    imageData = UIImageJPEGRepresentation(image, imageQuality);
    
    //[self uploadNotification];
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
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle: @"Couldn't Upload Photo"
                                          message: @"Upload timed out. Please try again in one minute."
                                          delegate: self
                                          cancelButtonTitle:@"Retake"
                                          otherButtonTitles:nil];
                    [alert setTag:50];
                    [alert show];
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
        uploadProgress += uploadStep;
        uploadingHUD.progress = uploadProgress;
        usleep(50000);
    }
}

- (void)researching
{
    while (researchProgress < 1.0) {
        researchProgress += researchStep;
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
    [self reloadOriginalImageSize];
    
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
    [self reloadOriginalImageSize];
    
    [picker dismissModalViewControllerAnimated:YES];
}

// PRICE RETRIEVAL LOGIC

- (void)priceThis
{
    // Assume the fastest one could ever price a photo would be 1minute 30 seconds
    // Then assume check every X seconds until Y seconds total
    queryNumber = 0;
    
    [NSTimer scheduledTimerWithTimeInterval:queryTime
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
    
    if (queryNumber>prepQueries) {
        PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
        NSLog(@"Looking for ... %@", self.userPhoto.objectId);
        [query getObjectInBackgroundWithId:self.userPhoto.objectId block:^(PFObject *retrievedPhoto, NSError *error) {
            if (!error) {
                // The get request succeeded.
                NSString *totalPrice = [retrievedPhoto objectForKey:@"PriceTotal"];
                NSString *numTickets = [retrievedPhoto objectForKey:@"NumTickets"];
                NSLog(@"The price was: $%@", totalPrice);
                if ([numTickets isEqualToString:@"0"] ) {
                    [t invalidate];
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle: @"Couldn't Read Tickets"
                                          message: @"Please ensure that the barcode is in focus and the event, date, section, row and seat numbers are visible."
                                          delegate: self
                                          cancelButtonTitle:@"Retake"
                                          otherButtonTitles:nil];
                    [alert setTag:30];
                    [alert show];
                } else if ([totalPrice isEqualToString:@"?"]) {
                    [t invalidate];
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle: @"Couldn't Authenticate Tickets"
                                          message: @"According to our sources, one or more of those tickets may be invalid."
                                          delegate: self
                                          cancelButtonTitle:@"Retake"
                                          otherButtonTitles:nil];
                    [alert setTag:40];
                    [alert show];
                } else if (totalPrice && numTickets) {
                    [t invalidate];
                    NSLog(@"Price retrieved, timer stopped at %d queries!", queryNumber);
                    [self offerPriceToUser:totalPrice:numTickets];
                }
            } else {
                // Log details of our failure
                NSLog(@"Error getting price: %@ %@", error, [error userInfo]);
            }
        }];
    }
    if (queryNumber>serverQueries) {
        [t invalidate];
        NSLog(@"Reached %d queries, timer stopped!", queryNumber);
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Couldn't Price Tickets"
                              message: @"Request timed out. It looks like we couldn't find a market price for those tickets."
                              delegate: self
                              cancelButtonTitle:@"Retake"
                              otherButtonTitles:nil];
        [alert setTag:30];
        [alert show];
//        [self offerPriceToUser:@"15":@"1"];
    }
}


// OFFER PRICE

-(void) offerPriceToUser:(NSString *)price :(NSString *)numTickets
{
    [HUD removeFromSuperview];

    NSString *offer = @"After reviewing the data, your Flash offer is $";
    offer = [offer stringByAppendingString:price];
    NSString *forThese;
    NSString *conclusion;
    if([numTickets isEqualToString:@"1"]) {
        forThese = @" for this ";
        conclusion = @" ticket.";
    } else {
        forThese = @" for these ";
        conclusion = @" tickets.";
    }
    offer = [offer stringByAppendingString:forThese];
    offer = [offer stringByAppendingString:numTickets];
    offer = [offer stringByAppendingString:conclusion];

    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Get Paid?"
                          message: offer
                          delegate: self
                          cancelButtonTitle:@"Get Paid"
                          otherButtonTitles:@"Cancel",nil];
    [alert setTag:20];
    [alert show];
}

// TWILIO STARTS

- (void)uploadNotification
{
  NSLog(@"Sending request.");
  
  // Common constants
  NSString *kTwilioSID = @"AC252b94aee1e94cc7bc1fec605b194d6c";
  NSString *kTwilioSecret = @"51b92a4a1ecc1f2ce5bfff2f878e27bd";
  NSString *kFromNumber = @"+18583543381";
  NSString *kMessage = @"A user just uploaded a photo%20check it out.";
  
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
}

- (void)reloadOriginalImageSize
{
    self.exampleImages.frame = CGRectMake(
                                          originalImageX,
                                          originalImageY,
                                          originalImageWidth,
                                          originalImageHeight);
}

- (void)viewDidUnload
{
    [self setExampleImages:nil];
    [super viewDidUnload];
}
@end
