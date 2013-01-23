#import "DatabaseObject.h"

@interface ProductPhoto : DatabaseObject
{

	@private
		NSNumber *_uid;
		NSString *_image;
		NSString *_details;
		NSNumber *_product;
		NSNumber *_bundle;
		NSNumber *_width;
		NSNumber *_height;
		NSNumber *_useAsThumbnail;
		NSString *_url;

}

@property (strong, nonatomic, getter=uid) NSNumber *uid;
@property (strong, nonatomic, getter=image) NSString *image;
@property (strong, nonatomic, getter=details) NSString *details;
@property (strong, nonatomic, getter=product) NSNumber *product;
@property (strong, nonatomic, getter=bundle) NSNumber *bundle;
@property (strong, nonatomic, getter=width) NSNumber *width;
@property (strong, nonatomic, getter=height) NSNumber *height;
@property (strong, nonatomic, getter=useAsThumbnail) NSNumber *useAsThumbnail;
@property (strong, nonatomic, getter=url) NSString *url;

@end
