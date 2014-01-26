//
//  PTImageEncrypter.h
//  PicxTale
//
//  Created by Sihao Lu on 1/26/14.
//  Copyright (c) 2014 Hack Rice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTImageEncrypter : NSObject

+ (UIImage *)encodedImage:(UIImage *)sourceImage message:(NSString *)message;

+ (NSString *)secretInImage:(UIImage *)sourceImage;

@end
