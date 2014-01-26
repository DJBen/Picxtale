//
//  PTBrowserViewController.m
//  PicxTale
//
//  Created by Sihao Lu on 1/25/14.
//  Copyright (c) 2014 Hack Rice. All rights reserved.
//

#import "PTBrowserViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ImageHelper.h"
#import "UIImage+Resize.h"
#import "PTPhotoManager.h"
#import "PTAddTaleViewController.h"
#import <UINavigationController+M13ProgressViewBar.h>
#import "PTImageEncrypter.h"

@interface PTBrowserViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    MWPhoto *photoToUse;
}

@end

@implementation PTBrowserViewController

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
        //        self.displaySelectionButtons = displaySelectionButtons;
        self.alwaysShowControls = YES;
        self.zoomPhotosToFill = YES;
        self.enableGrid = YES;
        self.startOnGrid = YES;
        self.delegate = [PTPhotoManager sharedManager];
        
        UILongPressGestureRecognizer *gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(reveal)];
        gr.minimumPressDuration = 2.0;
        [self.view addGestureRecognizer:gr];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPhoto)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    
//    NSLog(@"Current index: %d", self.currentIndex);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reveal {
    [self.navigationController setIndeterminate:YES];
    [self.view setUserInteractionEnabled:NO];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t main_queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        NSString *secretMessage = [PTImageEncrypter secretInImage:nil];
        dispatch_async(main_queue, ^{
            [self.navigationController finishProgress];
            [self.view setUserInteractionEnabled:YES];
            if (!secretMessage) {
                UIAlertView *imageHasNoSecretAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Secret not found", @"Image Has No Secret Alert") message:NSLocalizedString(@"This image does not contain a secret or it is broken.", @"Image Has No Secret Alert") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", Nil) otherButtonTitles:nil];
                [imageHasNoSecretAlert show];
            } else {
                NSLog(@"%@", secretMessage);
            }
        });
    });
}

- (void)addPhoto {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"From Camera", @"From Gallery", nil];
    actionSheet.delegate = self;
    [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addTaleSegue"]) {
        UINavigationController *nav = segue.destinationViewController;
        PTAddTaleViewController *vc = nav.viewControllers[0];
        [vc setPhoto:photoToUse];
    }
}

- (IBAction)refresh:(id)sender {
    [self reloadData];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1:
            NSLog(@"Gallery");
            [self startMediaBrowserFromViewController:self sourceType:UIImagePickerControllerSourceTypePhotoLibrary usingDelegate:self];
            break;
        case 0:
            NSLog(@"Camera");
            [self startMediaBrowserFromViewController:self sourceType:UIImagePickerControllerSourceTypeCamera usingDelegate:self];
            break;
        default:
            break;
    }
}

#pragma mark - Image Picker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    // Handle a still image picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) info[UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) info[UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        // Do something with imageToUse
        photoToUse = [[MWPhoto alloc] initWithImage:imageToUse];
    }
    
    // Handle a movied picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        
        // NSString *moviePath = [info[UIImagePickerControllerMediaURL] path];
        
        // Do something with the picked movie available at moviePath
        NSString *cannotUseMovieComment;
        cannotUseMovieComment = @"Cannot Use Movie Alert";
        UIAlertView *cannotUseMovieAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot Use Movie", cannotUseMovieComment) message:NSLocalizedString(@"Please choose a still image.", cannotUseMovieComment) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [picker dismissViewControllerAnimated:YES completion:^{
            [cannotUseMovieAlert show];
        }];
        return;
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        // Proceed to add tale
        [self performSegueWithIdentifier:@"addTaleSegue" sender:self];
    }];
    
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                                  sourceType:(UIImagePickerControllerSourceType)sourceType
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = sourceType;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    [controller presentViewController:mediaUI animated:YES completion:nil];
    return YES;
}



@end
