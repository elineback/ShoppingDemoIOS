#import <Foundation/Foundation.h>

#import <Tradedoubler-SDK/MobileSDK.h>

#import "TMSdk.h"

#import "SDDatabaseUtils.h"

#define TAGMAN_SITEID_DEFAULT    1
#define TAGMAN_SITEID_CART       2
#define TAGMAN_SITEID_CONVERSION 3
#define TAGMAN_SITEID_PRODUCT    4
#define TAGMAN_SITEID_CATEGORY   5
#define TAGMAN_SITEID_CHECKOUT   6
#define TAGMAN_SITEID_CONFIRM    7
#define TAGMAN_SITEID_SEARCH     8

#define TAGMAN_CLIENT_ID         @"clothing"

@interface SDTagManSDKAPI : NSObject

+(void)tagManSignIn:(Account *)account;
+(void)tagManPostCart:(Cart *)cart;
+(void)tagManPostOrder:(Cart *)order;
+(void)tagManViewCategory:(ProductCategory *)productCategory;
+(void)tagManViewProduct:(Product *)product;

+(void)tradeDoublerPostOrder:(Cart *)order;

@end
