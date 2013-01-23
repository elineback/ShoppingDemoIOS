#import "SDProductView.h"

@implementation SDProductView

@synthesize productUID          = _productUID;
@synthesize productThumbnail    = _productThumbnail;
@synthesize productManufacturer = _productManufacturer;
@synthesize productName         = _productName;
@synthesize productPrice        = _productPrice;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        CGRect f = CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              SD_PRODUCT_VIEW_WIDTH,
                              SD_PRODUCT_VIEW_HEIGHT);
        [self setFrame:f];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    CGRect f = CGRectMake(self.frame.origin.x,
                          self.frame.origin.y,
                          SD_PRODUCT_VIEW_WIDTH,
                          SD_PRODUCT_VIEW_HEIGHT);
    self = [super initWithFrame:f];
    if (self)
    {
    }
    return self;
}

@end
