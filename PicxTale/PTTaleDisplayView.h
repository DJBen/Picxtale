//
//  PTTaleDisplayView.h
//  PicxTale
//
//  Created by Sihao Lu on 1/26/14.
//  Copyright (c) 2014 Hack Rice. All rights reserved.
//

#import "FXBlurView.h"

@interface PTTaleDisplayView : FXBlurView

+ (PTTaleDisplayView *)presentInViewController:(UIViewController*) viewController;

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UITextView *description;

@property (strong, nonatomic) NSString *venmoAccount;
@property (nonatomic) CGFloat amount;
- (IBAction)pay:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *payButton;

@end

@interface PTTaleDisplayViewOwner : NSObject

@property (nonatomic, weak) IBOutlet PTTaleDisplayView *view;

@end

@protocol PTTaleDisplayViewDelegate <NSObject>

- (void)taleDisplayViewRequestPaymentWithVenmo:(NSString *)venmo amount:(NSString *)amount note:(NSString *)note;

@end