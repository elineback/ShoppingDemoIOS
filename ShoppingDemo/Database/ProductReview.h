#import "DatabaseObject.h"

@interface ProductReview : DatabaseObject
{

	@private
		NSNumber *_uid;
		NSString *_reviewedAt;
		NSString *_details;
		NSNumber *_product;
		NSNumber *_rating;
		NSString *_author;

}

@property (strong, nonatomic, getter=uid) NSNumber *uid;
@property (strong, nonatomic, getter=reviewedAt) NSString *reviewedAt;
@property (strong, nonatomic, getter=details) NSString *details;
@property (strong, nonatomic, getter=product) NSNumber *product;
@property (strong, nonatomic, getter=rating) NSNumber *rating;
@property (strong, nonatomic, getter=author) NSString *author;

@end
