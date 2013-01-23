#import "Cart.h"

@implementation Cart

@synthesize uid = _uid;
@synthesize account = _account;
@synthesize cartType = _cartType;
@synthesize orderPlaced = _orderPlaced;
@synthesize orderTotal = _orderTotal;
@synthesize paymentMethod = _paymentMethod;

- (id) init
{
	if ((self = [super init]))
	{
	}
	return self;
}

- (NSString *) tableName
{
	return @"Cart";
}

@end
