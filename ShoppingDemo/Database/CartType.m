#import "CartType.h"

@implementation CartType

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
	return @"CartType";
}

@end
