#import "DatabaseObject.h"

@interface Address : DatabaseObject
{

	@private
		NSNumber *_uid;
		NSString *_addressLine1;
		NSString *_addressLine2;
		NSString *_addressLine3;
		NSString *_addressLine4;
		NSString *_town;
		NSString *_county;
		NSString *_postcode;
		NSString *_country;
		NSString *_telephone;
		NSNumber *_account;

}

@property (strong, nonatomic, getter=uid) NSNumber *uid;
@property (strong, nonatomic, getter=addressLine1) NSString *addressLine1;
@property (strong, nonatomic, getter=addressLine2) NSString *addressLine2;
@property (strong, nonatomic, getter=addressLine3) NSString *addressLine3;
@property (strong, nonatomic, getter=addressLine4) NSString *addressLine4;
@property (strong, nonatomic, getter=town) NSString *town;
@property (strong, nonatomic, getter=county) NSString *county;
@property (strong, nonatomic, getter=postcode) NSString *postcode;
@property (strong, nonatomic, getter=country) NSString *country;
@property (strong, nonatomic, getter=telephone) NSString *telephone;
@property (strong, nonatomic, getter=account) NSNumber *account;

@end
