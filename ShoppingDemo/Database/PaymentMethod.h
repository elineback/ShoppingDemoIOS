#import "DatabaseObject.h"

@interface PaymentMethod : DatabaseObject
{

	@private
		NSNumber *_uid;
		NSNumber *_typeOfPayment;
		NSString *_identity;
		NSString *_expiry;
		NSNumber *_account;

}

@property (strong, nonatomic, getter=uid) NSNumber *uid;
@property (strong, nonatomic, getter=typeOfPayment) NSNumber *typeOfPayment;
@property (strong, nonatomic, getter=identity) NSString *identity;
@property (strong, nonatomic, getter=expiry) NSString *expiry;
@property (strong, nonatomic, getter=account) NSNumber *account;

@end
