#import "ProductCategory.h"

@implementation ProductCategory

@synthesize uid = _uid;
@synthesize name = _name;
@synthesize parent = _parent;

- (id) init
{
	if ((self = [super init]))
	{
	}
	return self;
}

- (NSString *) tableName
{
	return @"ProductCategory";
}

@end
