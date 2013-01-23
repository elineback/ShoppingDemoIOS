#import "DatabaseObject.h"

@interface Product : DatabaseObject
{

	@private
		NSNumber *_uid;
		NSString *_title;
		NSDecimalNumber *_price;
		NSString *_details;
		NSNumber *_category;
		NSNumber *_manufacturer;
		NSNumber *_featured;
		NSNumber *_promoted;
		NSString *_currency;
		NSDecimalNumber *_vat;
		NSNumber *_serverUID;
		NSString *_mpn;
		NSString *_sku;
		NSString *_url;
		NSString *_upc;
		NSString *_availability;
		NSDecimalNumber *_priceSpecial;
		NSDecimalNumber *_weight;

}

@property (strong, nonatomic, getter=uid) NSNumber *uid;
@property (strong, nonatomic, getter=title) NSString *title;
@property (strong, nonatomic, getter=price) NSDecimalNumber *price;
@property (strong, nonatomic, getter=details) NSString *details;
@property (strong, nonatomic, getter=category) NSNumber *category;
@property (strong, nonatomic, getter=manufacturer) NSNumber *manufacturer;
@property (strong, nonatomic, getter=featured) NSNumber *featured;
@property (strong, nonatomic, getter=promoted) NSNumber *promoted;
@property (strong, nonatomic, getter=currency) NSString *currency;
@property (strong, nonatomic, getter=vat) NSDecimalNumber *vat;
@property (strong, nonatomic, getter=serverUID) NSNumber *serverUID;
@property (strong, nonatomic, getter=mpn) NSString *mpn;
@property (strong, nonatomic, getter=sku) NSString *sku;
@property (strong, nonatomic, getter=url) NSString *url;
@property (strong, nonatomic, getter=upc) NSString *upc;
@property (strong, nonatomic, getter=availability) NSString *availability;
@property (strong, nonatomic, getter=priceSpecial) NSDecimalNumber *priceSpecial;
@property (strong, nonatomic, getter=weight) NSDecimalNumber *weight;

@end
