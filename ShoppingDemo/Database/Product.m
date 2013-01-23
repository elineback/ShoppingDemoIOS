#import "Product.h"

@implementation Product

@synthesize uid = _uid;
@synthesize title = _title;
@synthesize price = _price;
@synthesize details = _details;
@synthesize category = _category;
@synthesize manufacturer = _manufacturer;
@synthesize featured = _featured;
@synthesize promoted = _promoted;
@synthesize currency = _currency;
@synthesize vat = _vat;
@synthesize serverUID = _serverUID;
@synthesize mpn = _mpn;
@synthesize sku = _sku;
@synthesize url = _url;
@synthesize upc = _upc;
@synthesize availability = _availability;
@synthesize priceSpecial = _priceSpecial;
@synthesize weight = _weight;

- (id) init
{
	if ((self = [super init]))
	{
	}
	return self;
}

- (NSString *) tableName
{
	return @"Product";
}

@end
