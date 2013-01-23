#import "DatabaseObject.h"

@interface Manufacturer : DatabaseObject
{

	@private
		NSNumber *_uid;
		NSString *_title;

}

@property (strong, nonatomic, getter=uid) NSNumber *uid;
@property (strong, nonatomic, getter=title) NSString *title;

@end
