#import <Foundation/Foundation.h>

#import <Tradedoubler-SDK/MobileSDK.h>

#import "TMSdk.h"

#import "SDDatabaseUtils.h"

#define TAGMAN_SITEID_DEFAULT    9
#define TAGMAN_SITEID_CART       9
#define TAGMAN_SITEID_CONVERSION 9
#define TAGMAN_SITEID_PRODUCT    9
#define TAGMAN_SITEID_CATEGORY   9
#define TAGMAN_SITEID_CHECKOUT   9
#define TAGMAN_SITEID_CONFIRM    9
#define TAGMAN_SITEID_SEARCH     9

#define TAGMAN_CLIENT_ID         @"aveschema"

@interface SDTagManSDKAPI : NSObject

+(void)tagManSignIn:(Account *)account;
+(void)tagManPostCart:(Cart *)cart;
+(void)tagManPostOrder:(Cart *)order;
+(void)tagManViewCategory:(ProductCategory *)productCategory;
+(void)tagManViewProduct:(Product *)product;

+(void)tradeDoublerPostOrder:(Cart *)order;

@end
