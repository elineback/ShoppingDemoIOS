#import "PaymentMethod.h"

@implementation PaymentMethod

@synthesize uid = _uid;
@synthesize typeOfPayment = _typeOfPayment;
@synthesize identity = _identity;
@synthesize expiry = _expiry;
@synthesize account = _account;

- (id) init
{
	if ((self = [super init]))
	{
	}
	return self;
}

- (NSString *) tableName
{
	return @"PaymentMethod";
}

@end
