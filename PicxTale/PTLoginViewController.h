//
//  PTLoginViewController.h
//  PicxTale
//
//  Created by Sihao Lu on 1/25/14.
//  Copyright (c) 2014 Hack Rice. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTLoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)loginTapped:(id)sender;

- (IBAction)unwindToLogin:(UIStoryboardSegue *)segue;

- (IBAction)loginWithFacebook:(id)sender;
@end
