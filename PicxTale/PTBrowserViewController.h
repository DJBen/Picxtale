//
//  PTBrowserViewController.h
//  PicxTale
//
//  Created by Sihao Lu on 1/25/14.
//  Copyright (c) 2014 Hack Rice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MWPhotoBrowser.h>

@interface PTBrowserViewController : MWPhotoBrowser <MWPhotoBrowserDelegate>

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;

- (IBAction)unwindToBrowser:(UIStoryboardSegue *)segue;

@end
