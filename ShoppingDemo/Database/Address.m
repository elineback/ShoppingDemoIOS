#import "Address.h"

@implementation Address

@synthesize uid = _uid;
@synthesize addressLine1 = _addressLine1;
@synthesize addressLine2 = _addressLine2;
@synthesize addressLine3 = _addressLine3;
@synthesize addressLine4 = _addressLine4;
@synthesize town = _town;
@synthesize county = _county;
@synthesize postcode = _postcode;
@synthesize country = _country;
@synthesize telephone = _telephone;
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
	return @"Address";
}

@end
