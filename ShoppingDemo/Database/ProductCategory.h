#import "DatabaseObject.h"

@interface ProductCategory : DatabaseObject
{

	@private
		NSNumber *_uid;
		NSString *_name;
		NSNumber *_parent;

}

@property (strong, nonatomic, getter=uid) NSNumber *uid;
@property (strong, nonatomic, getter=name) NSString *name;
@property (strong, nonatomic, getter=parent) NSNumber *parent;

@end
