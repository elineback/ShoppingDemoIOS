#import "Account.h"

@implementation Account

@synthesize uid = _uid;
@synthesize emailAddress = _emailAddress;
@synthesize password = _password;
@synthesize forename = _forename;
@synthesize surname = _surname;
@synthesize serverUID = _serverUID;
@synthesize approved = _approved;
@synthesize dateAdded = _dateAdded;

- (id) init
{
	if ((self = [super init]))
	{
	}
	return self;
}

- (NSString *) tableName
{
	return @"Account";
}

@end
