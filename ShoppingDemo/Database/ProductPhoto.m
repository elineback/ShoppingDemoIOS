#import "ProductPhoto.h"

@implementation ProductPhoto

@synthesize uid = _uid;
@synthesize image = _image;
@synthesize details = _details;
@synthesize product = _product;
@synthesize bundle = _bundle;
@synthesize width = _width;
@synthesize height = _height;
@synthesize useAsThumbnail = _useAsThumbnail;
@synthesize url = _url;

- (id) init
{
	if ((self = [super init]))
	{
	}
	return self;
}

- (NSString *) tableName
{
	return @"ProductPhoto";
}

@end
