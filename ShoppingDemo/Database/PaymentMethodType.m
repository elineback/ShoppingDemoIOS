#import "PaymentMethodType.h"

@implementation PaymentMethodType

@synthesize uid = _uid;
@synthesize constantName = _constantName;
@synthesize details = _details;

- (id) init
{
	if ((self = [super init]))
	{
	}
	return self;
}

- (NSString *) tableName
{
	return @"PaymentMethodType";
}

@end
