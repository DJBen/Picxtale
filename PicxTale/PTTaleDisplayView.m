//
//  PTTaleDisplayView.m
//  PicxTale
//
//  Created by Sihao Lu on 1/26/14.
//  Copyright (c) 2014 Hack Rice. All rights reserved.
//

#import "PTTaleDisplayView.h"

@implementation PTTaleDisplayViewOwner
@end

@interface PTTaleDisplayView ()
@property (nonatomic, weak) UIViewController <PTTaleDisplayViewDelegate> *delegateViewController;
@end


@implementation PTTaleDisplayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (PTTaleDisplayView *)presentInViewController:(UIViewController <PTTaleDisplayViewDelegate> *)viewController
{
    // Instantiating encapsulated here.
    PTTaleDisplayViewOwner *owner = [PTTaleDisplayViewOwner new];
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:owner options:nil];
    
    // Pass in a reference of the viewController.
    owner.view.delegateViewController = viewController;
    
    // Add (thus retain).
    [viewController.view addSubview:owner.view];
    
    owner.view.alpha = 0.0f;
    [UIView animateWithDuration:1.0 delay:1.0 options:0 animations:^{
        owner.view.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [owner.view setDynamic:NO];
    }];
    
    return owner.view;
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    NSArray *elements = @[self.payButton];
    
    for (UIView *view in elements) {
        if (CGRectContainsPoint(view.frame, point)) {
            return YES;
        }
    }
    
    for (UIView *view in elements) {
        [view resignFirstResponder];
    }
    
    [UIView animateWithDuration:1.0 delay:0.0 options:0 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)pay:(id)sender {
    [self.delegateViewController taleDisplayViewRequestPaymentWithVenmo:self.venmoAccount amount:[NSString stringWithFormat:@"%.2f", self.amount] note:[NSString stringWithFormat:@"%@: %@ -  Payment from PicxTale", self.title.text, self.description.text]];
}
@end
