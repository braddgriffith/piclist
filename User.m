//
//  User.m
//  Powerball Results
//
//  Created by Brad Grifffith on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import <Parse/Parse.h>

@interface User ()

@property (nonatomic, strong) PFUser *parseUser;

@end

@implementation User

@synthesize first_name;
@synthesize id;
@synthesize last_name;
@synthesize credit_card_last_4;
@synthesize credit_card_type;
@synthesize default_cause;
@synthesize location;
@synthesize current_cause;
@synthesize username;
@synthesize parseUser;

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeObject:current_cause forKey:@"current_cause"];
    [coder encodeObject:first_name forKey:@"first_name"];
    [coder encodeObject:id forKey:@"id"];
    [coder encodeObject:last_name forKey:@"last_name"];
    [coder encodeObject:credit_card_last_4 forKey:@"credit_card_last_4"];
    [coder encodeObject:credit_card_type forKey:@"credit_card_type"];
    [coder encodeObject:default_cause forKey:@"default_cause"];
    [coder encodeObject:location forKey:@"location"];
    [coder encodeObject:username forKey:@"username"];
    [parseUser saveInBackground];
}

- (id)initWithCoder:(NSCoder *)coder;
{
    self = [[User alloc] init];
    if (self != nil)
    {
        self.current_cause = [coder decodeObjectForKey:@"current_cause"];
        self.first_name = [coder decodeObjectForKey:@"first_name"];
        self.id = [coder decodeObjectForKey:@"id"];
        self.last_name = [coder decodeObjectForKey:@"last_name"];
        self.credit_card_last_4 = [coder decodeObjectForKey:@"credit_card_last_4"];
        self.credit_card_type = [coder decodeObjectForKey:@"credit_card_type"];
        self.default_cause = [coder decodeObjectForKey:@"default_cause"];
        self.location = [coder decodeObjectForKey:@"location"];
        self.username = [coder decodeObjectForKey:@"username"];
        [PFUser enableAutomaticUser];
        self.parseUser = [PFUser currentUser];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.current_cause = @"";
        self.first_name = @"";
        self.id = @"";
        self.last_name = @"";
        self.credit_card_last_4 = @"";
        self.credit_card_type = @"";
        self.default_cause = @"";
        self.current_cause = @"";
        self.location = @"";
        self.username = @"";
        
        [PFUser enableAutomaticUser];
        self.parseUser = [PFUser currentUser];
        [[PFUser currentUser] saveInBackground];
        
    }
    return self;
}

- (void)setEmail:(NSString *)email
{
    self.parseUser.email = email;
    [[PFUser currentUser] saveInBackground];
}

- (NSString *)email
{
    return self.parseUser.email;
}

- (void)setPaypalEmail:(NSString *)paypalEmail
{
    [self.parseUser setObject:paypalEmail forKey:@"paypalEmail"];
    [[PFUser currentUser] saveInBackground];
}

- (NSString *)paypalEmail
{
    return [self.parseUser objectForKey:@"paypalEmail"];
}

@end