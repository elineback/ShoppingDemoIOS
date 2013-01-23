#import "DatabaseObject.h"

@interface PaymentMethodType : DatabaseObject
{

	@private
		NSNumber *_uid;
		NSString *_constantName;
		NSString *_details;

}

@property (strong, nonatomic, getter=uid) NSNumber *uid;
@property (strong, nonatomic, getter=constantName) NSString *constantName;
@property (strong, nonatomic, getter=details) NSString *details;

@end
