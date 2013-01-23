//
//  NSFileManager+PathHelper.m
//  VWDealer
//
//  Created by William Shakour on 03/04/2011.
//  Copyright 2011 WillShex Ltd. All rights reserved.
//

#import "NSFileManager+PathHelper.h"

@implementation NSFileManager (PathHelper)

@dynamic documentsPath;
@dynamic tmpPath;
@dynamic cachesPath;

- (NSString *)documentsPath
{ 
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                       NSUserDomainMask,
                                                       YES);
	return [paths objectAtIndex:0];
}

- (NSString *)tmpPath
{
    return NSTemporaryDirectory();
}

- (NSString *)cachesPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    
    return [paths objectAtIndex:0];
}

@end
