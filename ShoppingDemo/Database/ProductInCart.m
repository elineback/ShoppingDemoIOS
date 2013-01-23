#import "ProductInCart.h"

@implementation ProductInCart

@synthesize cart = _cart;
@synthesize product = _product;
@synthesize quantity = _quantity;

- (id) init
{
	if ((self = [super init]))
	{
	}
	return self;
}

- (NSString *) tableName
{
	return @"ProductInCart";
}

@end
