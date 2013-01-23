////////////////////////////////////////////////////////////////////////////////
//
//  Created by William Shakour on 12/07/2012.
//  Modified by Andy Brick on 22/11/2012.
//  Copyright (c) 2012 Mobile Impossible - http://mobileimpossible.com/.
//  All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

@interface NSFileManager (PathHelper)

@property (readonly, nonatomic) NSString *documentsPath;
@property (readonly, nonatomic) NSString *tmpPath;
@property (readonly, nonatomic) NSString *cachesPath;

@end
