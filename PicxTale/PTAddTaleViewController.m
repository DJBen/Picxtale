//
//  PTEditPhotoViewController.m
//  PicxTale
//
//  Created by Sihao Lu on 1/26/14.
//  Copyright (c) 2014 Hack Rice. All rights reserved.
//

#import "PTAddTaleViewController.h"
#import "PTTaleView.h"
#import <UINavigationController+M13ProgressViewBar.h>
#import "PTImageEncrypter.h"
#import "UIImage+Resize.h"
#import "NSString+Random.h"
#import "PTChooseFriendsViewController.h"

@interface PTAddTaleViewController () <MWPhotoBrowserDelegate, PTTaleViewDelegate, UIAlertViewDelegate>

@end

@implementation PTAddTaleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.displayActionButton = YES;
        self.displayNavArrows = YES;
        //        self.displaySelectionButtons = displaySelectionButtons;
        //        self.alwaysShowControls = displaySelectionButtons;
        self.zoomPhotosToFill = YES;
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [PTTaleView presentInViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"friendListSegue"]) {
        PTChooseFriendsViewController *vc = [segue destinationViewController];
        vc.photo = self.photo;
    }
}

#pragma mark - PTTaleView Delegate
- (void)taleViewWillDismissWithTitle:(NSString *)title description:(NSString *)description venmoAccount:(NSString *)venmoAccount amount:(CGFloat)amount {
    //// Display HUD
    //[MMProgressHUD showProgressWithStyle:MMProgressHUDProgressStyleIndeterminate title:NSLocalizedString(@"Hiding Secret", @"Progress HUD") status:NSLocalizedString(@"Please wait...", @"Progress HUD")];
    //dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //dispatch_queue_t main_queue = dispatch_get_main_queue();
    //dispatch_async(queue, ^{
    //    self.encodedImage = [self encodedImage:[self resizedImage]];
    //    NSData *encodedImageData = UIImagePNGRepresentation(self.encodedImage);
    //    UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:encodedImageData], self, nil, nil);
    //    dispatch_async(main_queue, ^{
    //        [MMProgressHUD dismiss];
    //    });
    //});
    
    NSDictionary *messageDict = @{@"title":title, @"description":description, @"venmoAccount":venmoAccount, @"amount":@(amount)};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:messageDict options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    NSLog(@"%@", jsonString);
    
    [self.navigationController setIndeterminate:YES];
    [self.view setUserInteractionEnabled:NO];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t main_queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        UIImage *newImage = [PTImageEncrypter encodedImage:[self.photo.image resizedImageWithQuality:PTImageHighQuality] message:jsonString];
        NSData *encodedImageData = UIImagePNGRepresentation(newImage);
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex  :0]; //Get the docs directory
        NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"image_%@.png", [NSString randomString:8]]]; //Add the file name
        [encodedImageData writeToFile:filePath atomically:YES]; //Write the file
        
        dispatch_async(main_queue, ^{
            [self.navigationController finishProgress];
            [self.view setUserInteractionEnabled:YES];
            if (venmoAccount && venmoAccount.length > 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ask for Payment" message:@"Do you wish to push this photo immediately to your friend to let him pay you?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes!", nil];
                alert.delegate = self;
                alert.tag = 1023;
                [alert show];
            }
        });
    });
}

#pragma mark - MWPhotoBrowser Delegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    return self.photo;
}

//- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
//    if (index < _thumbs.count)
//        return [_thumbs objectAtIndex:index];
//    return nil;
//}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

//- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
//    return [[_selections objectAtIndex:index] boolValue];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
//    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
//    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
//}

#pragma mark - Alert View Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            // NO
            [self performSegueWithIdentifier:@"unwindAddTaleSegue" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"friendListSegue" sender:self];
            // YES
            break;
        default:
            break;
    }
}

@end
