//
//  PTPhotoManager.h
//  PicxTale
//
//  Created by Sihao Lu on 1/25/14.
//  Copyright (c) 2014 Hack Rice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MWPhotoBrowser.h>

@interface PTPhotoManager : NSObject <MWPhotoBrowserDelegate>

+ (PTPhotoManager *)sharedManager;

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;

@end
