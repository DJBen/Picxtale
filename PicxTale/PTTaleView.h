//
//  PTTaleView.h
//  PicxTale
//
//  Created by Sihao Lu on 1/26/14.
//  Copyright (c) 2014 Hack Rice. All rights reserved.
//

#import "FXBlurView.h"

@interface PTTaleView : FXBlurView

+ (void)presentInViewController:(UIViewController*) viewController;

@property (weak, nonatomic) IBOutlet UIView *holderView;

@property (weak, nonatomic) IBOutlet UITextField *title;
@property (weak, nonatomic) IBOutlet UITextField *description;
@property (weak, nonatomic) IBOutlet UIButton *engraveButton;
- (IBAction)engraveTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *venmoAccountTextField;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;

@end

@interface PTTaleViewOwner : NSObject

@property (nonatomic, weak) IBOutlet PTTaleView *view;

@end

@protocol PTTaleViewDelegate <NSObject>

- (void)taleViewWillDismissWithTitle:(NSString *)title description:(NSString *)description venmoAccount:(NSString *)venmoAccount amount:(CGFloat)amount;

@end