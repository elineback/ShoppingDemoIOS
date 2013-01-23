//
//  NSString_Sha1Hash.m
//  Framework
//
//  Created by William Shakour on 23/12/2010.
//  Copyright © 2010 WillShex Ltd. All rights reserved.
//

#import "NSString+Sha1Hash.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Sha1Hash)

+ (NSString *) stringHashUsingSha1:(NSString *)string
{
  NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
  
  uint8_t digest[CC_SHA1_DIGEST_LENGTH];
  CC_SHA1(stringData.bytes, stringData.length, digest);
  NSMutableString *sha1 = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH];
  for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
    [sha1 appendFormat:@"%02x", digest[i]];
  }
  
  return sha1;
}

@end
