#import "DatabaseObject.h"

@interface Cart : DatabaseObject
{

	@private
		NSNumber *_uid;
		NSNumber *_account;
		NSNumber *_cartType;
		NSString *_orderPlaced;
		NSDecimalNumber *_orderTotal;
		NSNumber *_paymentMethod;

}

@property (strong, nonatomic, getter=uid) NSNumber *uid;
@property (strong, nonatomic, getter=account) NSNumber *account;
@property (strong, nonatomic, getter=cartType) NSNumber *cartType;
@property (strong, nonatomic, getter=orderPlaced) NSString *orderPlaced;
@property (strong, nonatomic, getter=orderTotal) NSDecimalNumber *orderTotal;
@property (strong, nonatomic, getter=paymentMethod) NSNumber *paymentMethod;

@end
