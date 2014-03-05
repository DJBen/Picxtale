//
//  PTImageEncrypter.m
//  PicxTale
//
//  Created by Sihao Lu on 1/26/14.
//  Copyright (c) 2014 Hack Rice. All rights reserved.
//

#import "PTImageEncrypter.h"
#import "ImageHelper.h"
#import "NSString+Brainfuck.h"

@implementation PTImageEncrypter

+ (UIImage *)encodedImage:(UIImage *)sourceImage message:(NSString *)message {
    if (!message) return nil;
    NSLog(@"Encoded begins");
    NSString *secretInBrainfuckCode = [message brainfuckCode];
    NSUInteger interval = sourceImage.size.width * sourceImage.size.height / secretInBrainfuckCode.length;
    if (interval < 1) {
        NSLog(@"Picture too small to hold all the info");
        return nil;
    }
    NSLog(@"Interval = %d", interval);
    NSUInteger brainfuckCodeIndex = 0;
    unsigned char *bitmap = [ImageHelper convertUIImageToBitmapRGBA8:sourceImage];
    BOOL terminated = NO;
    for (int i = 0; i < sourceImage.size.height; i++) {
        for (int j = 0; j < 4 * sourceImage.size.width; j+=4) {
            int index = i * 4 * sourceImage.size.width + j;
            if (index == 0) {
                bitmap[index] = interval / 255 / 255;
                bitmap[index + 1] = (interval - interval / 255 / 255 * 255 * 255) / 255;
                bitmap[index + 2] = interval % 255;
                NSLog(@"Encoded interval = %d %d %d", bitmap[index], bitmap[index + 1], bitmap[index + 2]);
                continue;
            }
            if (index == 4) {
                bitmap[index] = 255.0 - bitmap[index - 4];
                bitmap[index + 1] = 255.0 - bitmap[index + 1 - 4];
                bitmap[index + 2] = 255.0 - bitmap[index + 2 - 4];
                continue;
            }
            if (index / 4 % interval != 0) {
                continue;
            }
            unsigned char red = bitmap[index];
            unsigned char green = bitmap[index + 1];
            unsigned char blue = bitmap[index + 2];
            if (brainfuckCodeIndex >= secretInBrainfuckCode.length) {
                if (!terminated) {
                    red = roundToFit(red, 1, 2);
                    green = roundToFit(green, 1, 2);
                    blue = roundToFit(blue, 1, 2);
                    bitmap[index] = red;
                    bitmap[index + 1] = green;
                    bitmap[index + 2] = blue;
                    terminated = YES;
                }
                break;
            }
            switch ([secretInBrainfuckCode characterAtIndex:brainfuckCodeIndex]) {
                case '<':
                    red = roundToFit(red, 0, 2);
                    green = roundToFit(green, 0, 2);
                    blue = roundToFit(blue, 0, 2);
                    break;
                case '>':
                    red = roundToFit(red, 0, 2);
                    green = roundToFit(green, 0, 2);
                    blue = roundToFit(blue, 1, 2);
                    break;
                case '+':
                    red = roundToFit(red, 0, 2);
                    green = roundToFit(green, 1, 2);
                    blue = roundToFit(blue, 0, 2);
                    break;
                case '-':
                    red = roundToFit(red, 0, 2);
                    green = roundToFit(green, 1, 2);
                    blue = roundToFit(blue, 1, 2);
                    break;
                case '[':
                    red = roundToFit(red, 1, 2);
                    green = roundToFit(green, 0, 2);
                    blue = roundToFit(blue, 0, 2);
                    break;
                case ']':
                    red = roundToFit(red, 1, 2);
                    green = roundToFit(green, 0, 2);
                    blue = roundToFit(blue, 1, 2);
                    break;
                case '.':
                    red = roundToFit(red, 1, 2);
                    green = roundToFit(green, 1, 2);
                    blue = roundToFit(blue, 0, 2);
                    break;
                default:
                    break;
            }
            bitmap[index] = red;
            bitmap[index + 1] = green;
            bitmap[index + 2] = blue;
            brainfuckCodeIndex++;
        }
    }
    
    return [ImageHelper convertBitmapRGBA8ToUIImage:bitmap withWidth:sourceImage.size.width withHeight:sourceImage.size.height];
}

unsigned char roundToFit(unsigned char value, int mod, int base) {
    value += (base - value % base) + mod;
    if (value > 255) {
        value -= base;
    }
    return value;
}

//// Display HUD
//[MMProgressHUD showProgressWithStyle:MMProgressHUDProgressStyleIndeterminate title:NSLocalizedString(@"Revealing Secret", @"Progress HUD") status:NSLocalizedString(@"Please wait...", @"Progress HUD")];
//dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//dispatch_queue_t main_queue = dispatch_get_main_queue();
//dispatch_async(queue, ^{
//    self.secretMessage = [self secretInImage:self.imageToUse];
//    dispatch_async(main_queue, ^{
//        [MMProgressHUD dismiss];
//        if (!self.secretMessage) {
//            UIAlertView *imageHasNoSecretAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Secret not found", @"Image Has No Secret Alert") message:NSLocalizedString(@"This image does not contain a secret or it is broken.", @"Image Has No Secret Alert") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", Nil) otherButtonTitles:nil];
//            [imageHasNoSecretAlert show];
//        } else {
//            [self performSegueWithIdentifier:@"decryptMessageSegue" sender:self];
//        }
//    });
//});

+ (NSString *)secretInImage:(UIImage *)sourceImage {
    NSMutableString *message = [[NSMutableString alloc] init];
    unsigned char *bitmap = [ImageHelper convertUIImageToBitmapRGBA8:sourceImage];
    NSUInteger interval = bitmap[0] * 255 * 255 + bitmap[1] * 255 + bitmap[2];
    //    NSLog(@"calculated interval = %d", interval);
    BOOL valid = YES;
    for (int i = 0; i < 2; i++) {
        if (bitmap[i] != 255 - bitmap[i + 4]) valid = NO;
    }
    if (!valid || interval == 0) {
        NSLog(@"This image does not contain a secret or it is broken.");
        return nil;
    }
    for (int i = 0; i < sourceImage.size.height; i++) {
        for (int j = 0; j < 4 * sourceImage.size.width; j+=4) {
            int index = i * 4 * sourceImage.size.width + j;
            if (index / 4 % interval != 0 || index <= 1) {
                continue;
            }
            unsigned char red = bitmap[index];
            unsigned char green = bitmap[index + 1];
            unsigned char blue = bitmap[index + 2];
            NSString *currentBrainfuckCodeBit = brainfuckCodeString(red, green, blue);
            if ([currentBrainfuckCodeBit isEqualToString:@"terminator"]) {
                return [[message copy] parseBrainfuckCode];
            }
            [message appendString:currentBrainfuckCodeBit];
        }
    }
    free(bitmap);
    return [[message copy] parseBrainfuckCode];
}

NSString* brainfuckCodeString(unsigned char red, unsigned char green, unsigned char blue) {
    int value = red % 2 * 4 + green % 2 * 2 + blue % 2;
    switch (value) {
        case 0:
            return @"<";
        case 1:
            return @">";
        case 2:
            return @"+";
        case 3:
            return @"-";
        case 4:
            return @"[";
        case 5:
            return @"]";
        case 6:
            return @".";
        case 7:
            return @"terminator";
        default:
            break;
    }
    return nil;
}

@end
