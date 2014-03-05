//
//  PTAppDelegate.h
//  PicxTale
//
//  Created by Sihao Lu on 1/25/14.
//  Copyright (c) 2014 Hack Rice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VenmoAppSwitch/Venmo.h>

@interface PTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) VenmoClient *venmoClient;

@end
