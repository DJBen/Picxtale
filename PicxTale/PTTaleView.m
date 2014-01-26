//
//  PTTaleView.m
//  PicxTale
//
//  Created by Sihao Lu on 1/26/14.
//  Copyright (c) 2014 Hack Rice. All rights reserved.
//

#import "PTTaleView.h"

@implementation PTTaleViewOwner
@end

@interface PTTaleView ()
@property (nonatomic, weak) UIViewController <PTTaleViewDelegate> *delegateViewController;
@end

@implementation PTTaleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (void)presentInViewController:(UIViewController <PTTaleViewDelegate> *) viewController
{
    // Instantiating encapsulated here.
    PTTaleViewOwner *owner = [PTTaleViewOwner new];
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:owner options:nil];
    
    // Pass in a reference of the viewController.
    owner.view.delegateViewController = viewController;
    
    [owner.view setDynamic:NO];
    
    // Add (thus retain).
    [viewController.view addSubview:owner.view];
    
    owner.view.alpha = 0.0f;
    [UIView animateWithDuration:1.0 delay:1.0 options:0 animations:^{
        owner.view.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];

}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    NSArray *elements = @[self.title, self.description, self.engraveButton, self.venmoAccountTextField, self.amountTextField];
    
    for (UIView *view in elements) {
        if (CGRectContainsPoint(CGRectMake(view.frame.origin.x, view.frame.origin.y + self.holderView.frame.origin.y, view.frame.size.width, view.frame.size.height), point)) {
            return YES;
        }
    }
    
    for (UIView *view in elements) {
        [view resignFirstResponder];
    }
    
    return NO;
}

- (IBAction)engraveTapped:(id)sender {
    if (self.title.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Title" message:@"Please enter a title!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    [self.delegateViewController taleViewWillDismissWithTitle:self.title.text description:self.description.text venmoAccount:self.venmoAccountTextField.text amount:[self.amountTextField.text floatValue]];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationBeginsFromCurrentState:YES];
	self.holderView.frame = CGRectMake(self.holderView.frame.origin.x, (self.holderView.frame.origin.y - 110), self.holderView.frame.size.width, self.holderView.frame.size.height);
	[UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationBeginsFromCurrentState:YES];
	self.holderView.frame = CGRectMake(self.holderView.frame.origin.x, (self.holderView.frame.origin.y + 110), self.holderView.frame.size.width, self.holderView.frame.size.height);
	[UIView commitAnimations];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
