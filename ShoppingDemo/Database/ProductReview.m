#import "ProductReview.h"

@implementation ProductReview

@synthesize uid = _uid;
@synthesize reviewedAt = _reviewedAt;
@synthesize details = _details;
@synthesize product = _product;
@synthesize rating = _rating;
@synthesize author = _author;

- (id) init
{
	if ((self = [super init]))
	{
	}
	return self;
}

- (NSString *) tableName
{
	return @"ProductReview";
}

@end
