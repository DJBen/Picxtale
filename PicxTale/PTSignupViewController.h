//
//  PTSignupViewController.h
//  PicxTale
//
//  Created by Sihao Lu on 1/25/14.
//  Copyright (c) 2014 Hack Rice. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTSignupViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *venmoAccountTextField;

- (IBAction)signUpTapped:(id)sender;

@end
