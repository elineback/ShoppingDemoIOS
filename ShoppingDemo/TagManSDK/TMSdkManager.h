////////////////////////////////////////////////////////////////////////////////
//
//  Created by William Shakour on 12/07/2012.
//  Modified by Andy Brick on 22/11/2012.
//  Copyright (c) 2012 Mobile Impossible - http://mobileimpossible.com/.
//  All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>

#import "NSString+Sha1Hash.h"
#import "NSFileManager+PathHelper.h"

#import "TMParams.h"
#import "TMContainer.h"
#import "TMTemplateHelper.h"

#define TM_DEFAULT_LIVE_URL    @"pfa.levexis.com"
#define TM_DEFAULT_STAGING_URL @"tagstaging.levexis.com"

@interface TMSdkManager : NSObject
{
    NSString       *_stagingUrl;
    NSString       *_liveUrl;
    NSTimeInterval  _timeOut;
}

@property (strong,nonatomic) NSString       *stagingUrl;
@property (strong,nonatomic) NSString       *liveUrl;
@property (assign,nonatomic) NSTimeInterval  timeout;

+ (TMSdkManager *)sharedSdkManager;

- (TMContainer *)setupContainerForPage:(NSInteger)pageId 
                            withParams:(NSDictionary *)params
                             andClient:(NSString *)clientId
                             onStaging:(BOOL)useStagingUrl;

@end
