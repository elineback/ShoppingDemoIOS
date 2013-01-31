#import <Foundation/Foundation.h>

#import "SDDatabaseUtils.h"

#ifndef SDOPENCARTAPI_H
#define SDOPENCARTAPI_H

#define OPENCART_API_HOST                 @"aveschema.tagmandemo.com"

#define OPENCART_API_KEY                  @"7fe4771c008a22eb763df47d19e2c6aa"

#define OPENCART_API_URL_PRODUCTS         @"http://%@/index.php?route=feed/tagman_feed&api=%@&function=products&imgw=%d&imgh=%d"
#define OPENCART_API_URL_USER             @"http://%@/index.php?route=feed/tagman_feed&api=%@&function=user&email=%@&password=%@"

#define OPENCART_API_PRODUCTS(imageSize)  ([NSString stringWithFormat:OPENCART_API_URL_PRODUCTS,OPENCART_API_HOST,OPENCART_API_KEY,(imageSize),(imageSize)])
#define OPENCART_API_USER(email,password) ([NSString stringWithFormat:OPENCART_API_URL_USER    ,OPENCART_API_HOST,OPENCART_API_KEY,(email)    ,(password) ])

#endif  // SDOPENCARTAPI_H

@protocol SDOpenCartAPIDelegate <NSObject>

-(void)refreshProducts;

@end

@interface SDOpenCartAPI : NSObject

+(BOOL)       getProducts:(id<SDOpenCartAPIDelegate>)delegate;
+(NSString *) signOnWithEmailAddress:(NSString *)emailAddress password:(NSString *)password;
+(void)       getImage:(NSURL *)imageURL toPath:(NSString *)imagePath;
+(id)         invokeJSONWebService:(NSString *)url;

@end
