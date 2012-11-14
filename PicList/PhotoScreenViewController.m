//
//  PhotoScreenViewController.m
//  PicList
//
//  Created by Brad Grifffith on 11/7/12.
//  Copyright (c) 2012 Brad Grifffith. All rights reserved.
//

#import "PhotoScreenViewController.h"
#import "SoldViewController.h"
#import <Parse/Parse.h>

@interface PhotoScreenViewController ()

@end

@implementation PhotoScreenViewController

@synthesize userPhoto;

int i = 0;
NSData *imageData;
int queryNumber;
PFFile *imageFile;

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    NSLog(@"Userphoto = %@", self.userPhoto);
    if (photo.image == nil) {
        [self takePhoto];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)takePhoto
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
#if TARGET_IPHONE_SIMULATOR
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#else
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
#endif
    imagePickerController.editing = YES; //SEE IF THIS IS NECESSARY
    imagePickerController.delegate = (id)self;
    
    [self presentModalViewController:imagePickerController animated:YES];
    //[imagePickerController setShowsCameraControls:NO];
}

#pragma mark - Image picker delegate methdos
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    photo.image = image;
    [picker dismissModalViewControllerAnimated:NO];
    
    imageData = UIImageJPEGRepresentation(image, 0.05f);
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Sell Tickets"
                          message: @"Submit photo or retake?"
                          delegate: self
                          cancelButtonTitle:@"Submit"
                          otherButtonTitles:@"Retake",nil];
    [alert setTag:10];
    [alert show];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (buttonIndex == 0) {
        if (alertView.tag == 10) {
            [self uploadNotification];
            [self uploadImage:imageData];
        } else if (alertView.tag == 20) {
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
        }
    }
    if (buttonIndex == 1) {
        if (alertView.tag == 10) {
            [self takePhoto];
        } else if (alertView.tag == 20) {
            [self takePhoto];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SoldSegue"]){
        SoldViewController *controller = segue.destinationViewController;
        PFObject *passedPhoto = self.userPhoto;
        controller.userPhoto = passedPhoto;
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:NO];
}

#pragma mark - Upload image to Parse
- (void)uploadImage:(NSData *)imageData
{
    imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    
    //HUD creation here (see example for code)
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hide old HUD, show completed HUD (see example for code)
            
            // Create a PFObject around a PFFile and associate it with the current user
            self.userPhoto = [PFObject objectWithClassName:@"UserPhoto"];
            [self.userPhoto setObject:imageFile forKey:@"imageFile"];
            
            // Set the access control list to current user for security purposes
            self.userPhoto.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            
            PFUser *user = [PFUser currentUser];
            [self.userPhoto setObject:user forKey:@"user"];
            
            [self.userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"Success, photo uploaded!");
                    //[self refresh:nil]; //OLD
                    //START PROCESS OF VERIFYING/PRICING/RESPONDING
                    NSLog(@"ObjectID: %@", userPhoto.objectId);
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
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        // Update your progress spinner here. percentDone will be between 0 and 100.
        HUD.progress = (float)percentDone/100; //BRING THIS BACK LATER
    }];
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
            //this is from the .h ... @property (nonatomic, strong)PFObject *userPhoto;
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
    if (queryNumber>16) {
        [t invalidate];
        NSLog(@"Reached %d queries, timer stopped!", queryNumber);
    }
}


// OFFER PRICE

-(void) offerPriceToUser:(NSString *)price
{
    NSString *offer = @"The price was: $";
    offer = [offer stringByAppendingString:price];
    
    UIAlertView *alert = [[UIAlertView alloc]
                      initWithTitle: @"Sell Tickets"
                      message: offer
                      delegate: self
                      cancelButtonTitle:@"Sell!"
                      otherButtonTitles:@"Cancel",nil];
    [alert setTag:20];
    [alert show];
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

+ (PhotoScreenViewController *)photoVC
{
    return (PhotoScreenViewController*)[[UIApplication sharedApplication] delegate];
}

@end
