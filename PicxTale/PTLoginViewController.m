//
//  PTLoginViewController.m
//  PicxTale
//
//  Created by Sihao Lu on 1/25/14.
//  Copyright (c) 2014 Hack Rice. All rights reserved.
//

#import "PTLoginViewController.h"
#import <Parse/Parse.h>
#import "PTBrowserViewController.h"

@interface PTLoginViewController ()

@property (nonatomic, strong) PFUser *user;

@end

@implementation PTLoginViewController

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
    if ([PFUser currentUser]) [self proceed];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)loginTapped:(id)sender {
}

- (IBAction)unwindToLogin:(UIStoryboardSegue *)segue {
    
}

- (IBAction)loginWithFacebook:(id)sender {
    NSArray *permissions = @[];
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Please check your connection and login again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            if (user.isNew) {
                NSLog(@"User signed up and logged in through Facebook!");
            } else {
                NSLog(@"User logged in through Facebook!");
            }
            self.user = user;
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    // Store the current user's Facebook ID on the user
                    [[PFUser currentUser] setObject:[result objectForKey:@"id"]
                                             forKey:@"fbId"];
                    [[PFUser currentUser] saveInBackground];
                }
            }];
            [self proceed];
        }
        NSLog(@"%@", [PFUser currentUser]);
    }];
}

- (void)proceed {
    [self performSegueWithIdentifier:@"browserSegue" sender:self];
}

@end
