//
//  NSString+Random.m
//  PicxTale
//
//  Created by Sihao Lu on 1/26/14.
//  Copyright (c) 2014 Hack Rice. All rights reserved.
//

#import "NSString+Random.h"

@implementation NSString (Random)

+ (NSString *)randomString:(int)length {
    NSMutableString* string = [NSMutableString stringWithCapacity:length];
    for (int i = 0; i < length; i++) {
        [string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
    }
    return string;
}

@end
