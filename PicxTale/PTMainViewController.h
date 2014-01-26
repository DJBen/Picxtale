//
//  PTMainViewController.h
//  PicxTale
//
//  Created by Sihao Lu on 1/25/14.
//  Copyright (c) 2014 Hack Rice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@interface PTMainViewController : MWPhotoBrowser <MWPhotoBrowserDelegate> {
    NSMutableArray *_selections;
}

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;

@end

