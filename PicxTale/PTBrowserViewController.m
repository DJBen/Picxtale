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
#import "PTAddTaleViewController.h"
#import <UINavigationController+M13ProgressViewBar.h>
#import "PTImageEncrypter.h"
#import "PTTaleDisplayView.h"
#import "NSString+Random.h"
#import <VenmoAppSwitch/Venmo.h>
#import "PTAppDelegate.h"

@interface PTBrowserViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PTTaleDisplayViewDelegate> {
    MWPhoto *photoToUse;
    NSUInteger currentPhotoIndex;
    BOOL photoShouldContainTale;
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
        // Init
        self.displayActionButton = YES;
        self.displayNavArrows = YES;
        self.zoomPhotosToFill = YES;
        self.enableGrid = YES;
        self.alwaysShowControls = YES;
        self.delegate = self;
        
        _photos = [NSMutableArray array];
        _thumbs = [NSMutableArray array];
        
        [self loadTestImages];
        [self loadRealImages];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reveal:(UIImage *)image {
    if (!image) {
        NSLog(@"Image is nil! Cannot reveal!");
        return;
    }
    [self.navigationController setIndeterminate:YES];
    [self.view setUserInteractionEnabled:NO];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t main_queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        NSString *secretMessage = [PTImageEncrypter secretInImage:image];
        dispatch_async(main_queue, ^{
            [self.navigationController finishProgress];
            [self.view setUserInteractionEnabled:YES];
            if (!secretMessage) {
                UIAlertView *imageHasNoSecretAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tale not found", @"Image Has No Tale Alert") message:NSLocalizedString(@"This image does not contain a tale or it is broken.", @"Image Has No Tale Alert") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [imageHasNoSecretAlert show];
            } else {
                NSLog(@"%@", secretMessage);
                PTTaleDisplayView *view = [PTTaleDisplayView presentInViewController:self];
                NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:[secretMessage dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                view.title.text = jsonData[@"title"];
                view.description.text = jsonData[@"description"];
                if (jsonData[@"venmoAccount"] && [jsonData[@"venmoAccount"] length] > 0) {
                    view.venmoAccount = jsonData[@"venmoAccount"];
                    view.amount = [jsonData[@"amount"] floatValue];
                    view.payButton.hidden = NO;
                } else {
                    view.payButton.hidden = YES;
                }
            }
        });
    });
}

- (void)action {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add from Camera", @"Add from Gallery", @"Add Photo with Tale", @"Refresh", nil];
    actionSheet.tag = 1123;
    actionSheet.delegate = self;
    [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

- (void)photoOption {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Images" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Reveal Tale", @"Refresh", nil];
    actionSheet.tag = 319;
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

- (IBAction)unwindToBrowser:(UIStoryboardSegue *)segue {
    [_photos removeAllObjects];
    [_thumbs removeAllObjects];
    [self loadTestImages];
    [self loadRealImages];
    double delayInSeconds = 2.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self reloadData];
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(action)];
        self.navigationItem.rightBarButtonItem = anotherButton;
    });
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1023) {

    } else if (actionSheet.tag == 1123) {
        switch (buttonIndex) {
            case 1:
                NSLog(@"Gallery");
                photoShouldContainTale = NO;
                [self startMediaBrowserFromViewController:self sourceType:UIImagePickerControllerSourceTypePhotoLibrary usingDelegate:self];
                break;
            case 0:
                NSLog(@"Camera");
                photoShouldContainTale = NO;
                [self startMediaBrowserFromViewController:self sourceType:UIImagePickerControllerSourceTypeCamera usingDelegate:self];
                break;
            case 2:
                photoShouldContainTale = YES;
                [self startMediaBrowserFromViewController:self sourceType:UIImagePickerControllerSourceTypePhotoLibrary usingDelegate:self];
                break;
            case 3:
                [self unwindToBrowser:nil];
                break;
            default:
                break;
        }
    } else if (actionSheet.tag == 319) {
        switch (buttonIndex) {
            case 0: {
                // Delete
                NSLog(@"Delete %@", [_photos[currentPhotoIndex] filePath]);
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSError *error;
                BOOL success = [fileManager removeItemAtPath:[_photos[currentPhotoIndex] filePath] error:&error];
                if (success) {
                    UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"Congratulation:" message:@"Successfully removed" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
                    [removeSuccessFulAlert show];
                } else {
                    NSLog(@"%@", error);
                }
                [self unwindToBrowser:nil];
                break;
            }
            case 1:
                [self reveal:[_photos[currentPhotoIndex] image]];
                break;
            default:
                break;
        }
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
        if (!photoShouldContainTale) {
            [self performSegueWithIdentifier:@"addTaleSegue" sender:self];
        } else {
            if (![PTImageEncrypter secretInImage:photoToUse.image]) {
                [self.navigationController setIndeterminate:YES];
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_queue_t main_queue = dispatch_get_main_queue();
                dispatch_async(queue, ^{
                    NSData *encodedImageData = UIImagePNGRepresentation(photoToUse.image);
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsPath = [paths objectAtIndex  :0]; //Get the docs directory
                    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"image_%@.png", [NSString randomString:8]]]; //Add the file name
                    [encodedImageData writeToFile:filePath atomically:YES]; //Write the file
                    
                    dispatch_async(main_queue, ^{
                        [self.navigationController finishProgress];
                        [self.view setUserInteractionEnabled:YES];
                        [self unwindToBrowser:nil];
                    });
                });
            }
        }
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

- (void)loadTestImages {
    MWPhoto *photo;
    photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo5" ofType:@"jpg"]]];
    photo.caption = @"White Tower";
    [_photos addObject:photo];
    photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo4" ofType:@"jpg"]]];
    photo.caption = @"Campervan";
    [_photos addObject:photo];
    // Thumbs
    photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo5t" ofType:@"jpg"]]];
    [_thumbs addObject:photo];
    photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo4t" ofType:@"jpg"]]];
    [_thumbs addObject:photo];
}

- (void)loadRealImages {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSError *error;
    NSArray *directoryContents =  [[NSFileManager defaultManager]
                                   contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    NSLog(@"%@", directoryContents);
    for (NSString *imageName in directoryContents) {
        NSString *thePath = [documentsDirectory stringByAppendingPathComponent:imageName];
        MWPhoto *photo = [[MWPhoto alloc] initWithImage:[UIImage imageWithContentsOfFile:thePath]];
        [_photos addObject:photo];
        [_thumbs addObject:photo];
    }
    
}

#pragma mark - MWPhotoBrowser Delegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
    // Change button to image-specific
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Photo" style:UIBarButtonItemStylePlain target:self action:@selector(photoOption)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    currentPhotoIndex = index;
    
}

- (void)photoBrowserDidShowGrid:(MWPhotoBrowser *)photoBrowser {
    NSLog(@"Changing button to add");
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(action)];
    self.navigationItem.rightBarButtonItem = anotherButton;
}

#pragma mark - Tale Display View Delegate
- (void)taleDisplayViewRequestPaymentWithVenmo:(NSString *)venmo amount:(NSString *)amount note:(NSString *)note {
    PTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    VenmoClient *venmoClient = appDelegate.venmoClient;
    VenmoTransaction *venmoTransaction = [[VenmoTransaction alloc] init];
    venmoTransaction.type = VenmoTransactionTypePay;
    venmoTransaction.amount = [NSDecimalNumber decimalNumberWithString:amount];
    venmoTransaction.note = note;
    venmoTransaction.toUserHandle = venmo;
    VenmoViewController *venmoViewController = [venmoClient viewControllerWithTransaction:
                                                venmoTransaction];
    if (venmoViewController) {
        [self presentViewController:venmoViewController animated:YES completion:nil];
    }
}

@end
