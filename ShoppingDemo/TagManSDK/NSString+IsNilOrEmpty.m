//
//  NSString+IsNilOrEmpty.m
//  Waitrose
//
//  Created by William Shakour on 26/01/2012.
//  Copyright (c) 2012 YOC Ltd. All rights reserved.
//

#import "NSString+IsNilOrEmpty.h"

@implementation NSString (IsNilOrEmpty)

+ (BOOL)isNilOrEmpty:(NSString *)string {
    return string == nil || [string isEqualToString:@""];
}

@end
