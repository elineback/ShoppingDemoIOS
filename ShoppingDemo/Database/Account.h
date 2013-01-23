#import "DatabaseObject.h"

@interface Account : DatabaseObject
{

	@private
		NSNumber *_uid;
		NSString *_emailAddress;
		NSString *_password;
		NSString *_forename;
		NSString *_surname;
		NSNumber *_serverUID;
		NSNumber *_approved;
		NSString *_dateAdded;

}

@property (strong, nonatomic, getter=uid)          NSNumber *uid;
@property (strong, nonatomic, getter=emailAddress) NSString *emailAddress;
@property (strong, nonatomic, getter=password)     NSString *password;
@property (strong, nonatomic, getter=forename)     NSString *forename;
@property (strong, nonatomic, getter=surname)      NSString *surname;
@property (strong, nonatomic, getter=serverUID)    NSNumber *serverUID;
@property (strong, nonatomic, getter=approved)     NSNumber *approved;
@property (strong, nonatomic, getter=dateAdded)    NSString *dateAdded;

@end
