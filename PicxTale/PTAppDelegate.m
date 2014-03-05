//
//  PTAppDelegate.m
//  PicxTale
//
//  Created by Sihao Lu on 1/25/14.
//  Copyright (c) 2014 Hack Rice. All rights reserved.
//

#import "PTAppDelegate.h"
#import "PTMainViewController.h"
#import <Parse/Parse.h>

static NSString *const kVenmoAppId      = @"1564";
static NSString *const kVenmoAppSecret  = @"eg8bFxbAFg7R7H7Mhn3UNcmAYCrHVwfY";

@implementation PTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _venmoClient = [VenmoClient clientWithAppId:kVenmoAppId secret:kVenmoAppSecret];

    [Parse setApplicationId:@"9osGpkWKYYtZxgN7z7lVa2846JglPgyjMXRfBqan"
                  clientKey:@"5WzxuJTc9tgTT6VPP1RGcHPqSaovsY8RjPNUYZtx"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFFacebookUtils initializeFacebook];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    NSLog(@"openURL: %@", url);
    BOOL success = [_venmoClient openURL:url completionHandler:^(VenmoTransaction *transaction, NSError *error) {
        if (transaction) {
            NSString *success = (transaction.success ? @"Success" : @"Failure");
            NSString *title = [@"Transaction " stringByAppendingString:success];
            NSString *message = [@"payment_id: " stringByAppendingFormat:@"%@. %@ %@ %@ (%@) $%@ %@",
                                 transaction.transactionID,
                                 transaction.fromUserID,
                                 transaction.typeStringPast,
                                 transaction.toUserHandle,
                                 transaction.toUserID,
                                 transaction.amountString,
                                 transaction.note];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message
                                                               delegate:nil cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else { // error
            NSLog(@"transaction error code: %i", error.code);
        }
    }];
    if (success) return success;
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
