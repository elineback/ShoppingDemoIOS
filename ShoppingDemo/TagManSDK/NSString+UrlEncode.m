//
//  NSString_UrlEncode.m
//  Framework
//
//  Created by William Shakour on 23/12/2010.
//  Copyright © 2010 WillShex Ltd. All rights reserved.
//

#import "NSString+UrlEncode.h"


@implementation NSString (UrlEncode)

+ (NSString *)stringByUrlEncodingString:(NSString *)string
{
  NSString *escapeChars[] = {
		@";" , @"/" , @"?" , @":" ,
		@"@" , @"&" , @"=" , @"+" ,
		@"$" , @"," , @"[" , @"]",
		@"#", @"!", @"'", @"(", 
		@")", @"*", nil};
	
  NSString *replaceChars[] = {
		@"%3B" , @"%2F" , @"%3F" ,
		@"%3A" , @"%40" , @"%26" ,
		@"%3D" , @"%2B" , @"%24" ,
		@"%2C" , @"%5B" , @"%5D", 
		@"%23", @"%21", @"%27",
		@"%28", @"%29", @"%2A", nil};
	
	
  NSMutableString *replaced = [[string mutableCopy] autorelease];
	
  int i;
  for (i = 0; escapeChars[i]; i++) {
    [replaced replaceOccurrencesOfString:escapeChars[i] 
                              withString:replaceChars[i]
                                 options:NSLiteralSearch
                                   range:NSMakeRange(0, replaced.length)];
  }
	
  return replaced;
}

@end
