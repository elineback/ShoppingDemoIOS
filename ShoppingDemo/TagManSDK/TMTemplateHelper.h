////////////////////////////////////////////////////////////////////////////////
//
//  Created by William Shakour on 12/07/2012.
//  Modified by Andy Brick on 22/11/2012.
//  Copyright (c) 2012 Mobile Impossible - http://mobileimpossible.com/.
//  All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>

#define TM_TEMPLATE_TAG_START @"[\%"
#define TM_TEMPLATE_TAG_END @"\%]"
#define TM_TEMPLATE_TAG_PAGE_ID @"[\% pageid \%]"
#define TM_TEMPLATE_TAG_PARAMETERS @"[\% parameters \%]"

#define TM_TEMPLATE_TAG_IF @"[%% IF %@ %%]"

#define TM_TEMPLATE_TAG_IF_ELSE @"[\% ELSE \%]"
#define TM_TEMPLATE_TAG_IF_END @"[\% END \%]"
#define TM_TEMPLATE_TAG_CLIENT_ID @"[\% clientidentifier \%]"

#define TM_TEMPLATE_TAG_STAGING_URL @"[\% urlstage \%]"
#define TM_TEMPLATE_TAG_LIVE_URL @"[\% urllive \%]"

@interface TMTemplateHelper : NSObject

+ (void)replaceTag:(NSString *)tag
                  withObject:(id)object
                  inTemplate:(NSMutableString *)templateMarkup;

+ (void)setCondition:(NSString *)name 
               value:(BOOL)enabled
          inTemplate:(NSMutableString *)templateMarkup;

@end
