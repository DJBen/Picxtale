//
//  PTPhotoManager.m
//  PicxTale
//
//  Created by Sihao Lu on 1/25/14.
//  Copyright (c) 2014 Hack Rice. All rights reserved.
//

#import "PTPhotoManager.h"

@implementation PTPhotoManager

+ (PTPhotoManager *)sharedManager {
    static dispatch_once_t pred;
    static PTPhotoManager *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[PTPhotoManager alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _photos = [NSMutableArray array];
        _thumbs = [NSMutableArray array];
        [self loadTestImages];
        [self loadRealImages];
    }
    return self;
}

- (void)loadTestImages {
    MWPhoto *photo;
    photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo5" ofType:@"jpg"]]];
    photo.caption = @"White Tower";
    [_photos addObject:photo];
    photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo2" ofType:@"jpg"]]];
    photo.caption = @"The London Eye is a giant Ferris wheel situated on the banks of the River Thames, in London, England.";
    [_photos addObject:photo];
    photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo3" ofType:@"jpg"]]];
    photo.caption = @"York Floods";
    [_photos addObject:photo];
    photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo4" ofType:@"jpg"]]];
    photo.caption = @"Campervan";
    [_photos addObject:photo];
    // Thumbs
    photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo5t" ofType:@"jpg"]]];
    [_thumbs addObject:photo];
    photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo2t" ofType:@"jpg"]]];
    [_thumbs addObject:photo];
    photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo3t" ofType:@"jpg"]]];
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
        MWPhoto *photo = [[MWPhoto alloc] initWithImage:[UIImage imageWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:imageName]]];
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

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
    NSLog(@"ACTION!");
}

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

@end
