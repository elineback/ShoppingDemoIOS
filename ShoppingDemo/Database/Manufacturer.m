#import "Manufacturer.h"

@implementation Manufacturer

@synthesize uid = _uid;
@synthesize title = _title;

- (id) init
{
	if ((self = [super init]))
	{
	}
	return self;
}

- (NSString *) tableName
{
	return @"Manufacturer";
}

@end
