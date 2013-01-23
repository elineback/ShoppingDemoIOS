#import <objc/runtime.h>
#import "Debug.h"
#import "Database.h"
#import "DatabaseObject.h"

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
const char *property_getTypeString( objc_property_t property )
{
	const char * attrs = property_getAttributes( property );
	if ( attrs == NULL )
		return ( NULL );
	static char buffer[256];
	const char * e = strchr( attrs, ',' );
	if ( e == NULL )
		return ( NULL );
	int len = (int)(e - attrs);
	memcpy( buffer, attrs, len );
	buffer[len] = '\0';
	return ( buffer );
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
SEL property_getGetter( objc_property_t property )
{
	const char * attrs = property_getAttributes( property );
	if ( attrs == NULL )
		return ( NULL );
    //_NSLog(@"Property Attributes : %s",attrs);
	const char * p = strstr( attrs, ",G" );
    if ( p == NULL )
		return ( NULL );
	p += 2;
    //_NSLog(@"p : %s",p);
	const char * e = strchr( p, ',' );
	if ( e == NULL )
		return ( sel_getUid(p) );
	if ( e == p )
		return ( NULL );
	int len = (int)(e - p);
	char * selPtr = malloc( len + 1 );
	memcpy( selPtr, p, len );
	selPtr[len] = '\0';
    //_NSLog(@"selPtr : %s",selPtr);
	SEL result = sel_getUid( selPtr );
	free( selPtr );
	return ( result );
}

@implementation DatabaseObject

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
- (id) init
{
	if ((self = [super init]))
	{
	}
	return self;
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
-(NSArray *)getArrayOfProperties
{
    Class clazz = [self class];
    u_int count;
    
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];

    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        [propertyArray addObject:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
    }
    free(properties);    

    return propertyArray;
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
-(NSString *)typeOfPropertyNamed:(NSString *) name
{
    Class clazz = [self class];
	objc_property_t property = class_getProperty( clazz, [name UTF8String] );
	if ( property == NULL )
		return ( NULL );
	return [NSString stringWithCString:property_getTypeString(property) encoding:NSUTF8StringEncoding];
}

-(BOOL)isNSDecimalNumber:(NSString *)propertyName
{
    NSString *propertyType = [self typeOfPropertyNamed:propertyName];
    return (BOOL)([propertyType rangeOfString:@"NSDecimalNumber"].location != NSNotFound);
}

-(BOOL)isNSNumber:(NSString *)propertyName
{
    NSString *propertyType = [self typeOfPropertyNamed:propertyName];
    return (BOOL)([propertyType rangeOfString:@"NSNumber"].location != NSNotFound);
}

-(BOOL)isNSString:(NSString *)propertyName
{
    NSString *propertyType = [self typeOfPropertyNamed:propertyName];
    return (BOOL)([propertyType rangeOfString:@"NSString"].location != NSNotFound);
}

-(void)setPropertyNamed:(NSString *)propertyName toValue:(NSString *)propertyValue
{
    NSString *setter = [NSString stringWithFormat:@"set%@%@:",[[propertyName substringToIndex:1] uppercaseString],[propertyName substringFromIndex:1]];

    if ([self isNSDecimalNumber:propertyName])
    {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *value = [formatter numberFromString:propertyValue];
        [self performSelector:NSSelectorFromString(setter) withObject:value];
    }
    else if ([self isNSNumber:propertyName])
    {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *value = [formatter numberFromString:propertyValue];
        [self performSelector:NSSelectorFromString(setter) withObject:value];
    }
    else if ([self isNSString:propertyName])
    {
        [self performSelector:NSSelectorFromString(setter) withObject:propertyValue];
    }
    else 
    {
        _NSLog(@"setPropertyNamed:%@ toValue:%@ - ERROR - Unknown Type",propertyName,propertyValue);
    }
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
-(SEL)getSelectorForPropertyNamed:(NSString *)name
{
    Class clazz = [self class];
	objc_property_t property = class_getProperty( clazz, [name UTF8String] );
    return property_getGetter( property );
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
-(NSString *)valueForProperty:(NSString *)name
{
    return [self valueForProperty:name xmlFormatting:NO];
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
-(NSString *)valueForProperty:(NSString *)name xmlFormatting:(BOOL)xmlFormatting
{
    NSString *propertyType = [self typeOfPropertyNamed:name];
    SEL selector = [self getSelectorForPropertyNamed:name];
    if (!selector)
    {
        return (xmlFormatting ? @"" : @"NULL");
    }
    NSMutableString *field = [[NSMutableString alloc] initWithString:@""];
    if ([propertyType rangeOfString:@"NSDecimalNumber"].location != NSNotFound)
    {
        id uncastPropertyValue = [self performSelector:selector];
        if (uncastPropertyValue)
        {
            if ( [uncastPropertyValue isKindOfClass:[NSDecimalNumber class]] )
            {
                NSDecimalNumber *castPropertyValue = (NSDecimalNumber *)uncastPropertyValue;
                if ( [castPropertyValue respondsToSelector:@selector(stringValue)] )
                {
                    [field appendString:[castPropertyValue stringValue]];
                }
                else 
                {
                    return (xmlFormatting ? @"" : @"NULL");
                }
            }
            else 
            {
                return (xmlFormatting ? @"" : @"NULL");
            }
        }
        else
        {
            [field appendString:(xmlFormatting ? @"" : @"NULL")];
        }
    }
    else if ([propertyType rangeOfString:@"NSNumber"].location != NSNotFound)
    {
        id uncastPropertyValue = [self performSelector:selector];
        if (uncastPropertyValue)
        {
            if ( [uncastPropertyValue isKindOfClass:[NSNumber class]] )
            {
                NSNumber *castPropertyValue = (NSNumber *)uncastPropertyValue;
                if ( [castPropertyValue respondsToSelector:@selector(stringValue)] )
                {
                    [field appendString:[castPropertyValue stringValue]];
                }
                else 
                {
                    return (xmlFormatting ? @"" : @"NULL");
                }
            }
            else 
            {
                return (xmlFormatting ? @"" : @"NULL");
            }
        }
        else
        {
            [field appendString:(xmlFormatting ? @"" : @"NULL")];
        }
    }
    else if ([propertyType rangeOfString:@"NSString"].location != NSNotFound)
    {
        id uncastPropertyValue = [self performSelector:selector];
        if (uncastPropertyValue)
        {
            if ( [uncastPropertyValue isKindOfClass:[NSString class]] )
            {
                NSString *castPropertyValue = (NSString *)uncastPropertyValue;
                if ([castPropertyValue length])
                {
                    NSMutableString *mutableValue = [[NSMutableString alloc] initWithString:castPropertyValue];
                    // Expand ' to ''
                    [mutableValue replaceOccurrencesOfString:@"'" 
                                                  withString:@"''" 
                                                     options:NSCaseInsensitiveSearch 
                                                       range:NSMakeRange(0, [mutableValue length])];
                    [field appendFormat:(xmlFormatting ? @"%@" : @"'%@'"),mutableValue];
                }
                else 
                {
                    [field appendString:(xmlFormatting ? @"" : @"NULL")];
                }
            }
            else 
            {
                return (xmlFormatting ? @"" : @"NULL");
            }
        }
        else
        {
            [field appendString:(xmlFormatting ? @"" : @"NULL")];
        }
    }
    else 
    {
        return (xmlFormatting ? @"" : @"NULL");
    }
    return field;
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
-(void)insertRow
{
    NSString *sql = [self insertStatement];
    if ([[Database sharedDatabaseInstance] executeStatement:sql])
    {
        int sequence = [[Database sharedDatabaseInstance] lastSequence:[[self class] description]];
        if ([self respondsToSelector:@selector(setUid:)])
            [self performSelector:@selector(setUid:) withObject:[[NSNumber alloc] initWithInt:sequence]];
    }
    else 
        _NSLog(@"%@.insertRow FAILED!!!",[[self class] description]);
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
-(NSString *)insertStatement
{
    NSArray  *properties = [self getArrayOfProperties];
    NSString *delimiter  = @"";
    NSMutableString *sql = [[NSMutableString alloc] initWithString:@"INSERT INTO "];
    [sql appendString:[self tableName]];
    [sql appendString:@" ("];
    for( NSString *property in properties )
    {
        if ( ![property isEqualToString:@"uid"] )
        {
            [sql appendFormat:@"%@%@",delimiter,property];
            delimiter = @" , ";
        }
    }
    [sql appendString:@" ) VALUES ( "];
    delimiter = @"";
    for( NSString *property in properties )
    {
        if ( [property isEqualToString:@"uid"] )
        {
            // Do nothing
        }
        else if ( [property isEqualToString:@"guid"] )
        {
            // Create a GUID
            NSString *guid = [[Database sharedDatabaseInstance] makeGUID];
            if ([self respondsToSelector:@selector(setGuid:)])
                [self performSelector:@selector(setGuid:) withObject:guid];
            [sql appendFormat:@" %@ '%@'",delimiter,guid];
            delimiter = @" , ";
        }
        else
        {
            [sql appendFormat:@" %@ %@",delimiter,[self valueForProperty:property]];
            delimiter = @" , ";
        }
    }        
    [sql appendString:@" );"];
    return sql;
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
-(void)updateRow
{
    NSString *criteria = nil;
    NSString *uid_     = nil;
    if ([self respondsToSelector:@selector(uid)])
        uid_ = [self performSelector:@selector(uid)];
    if (uid_)
        criteria = [NSString stringWithFormat:@" uid = %@ ",uid_];
    NSString *sql = [self updateStatement:criteria];
    if (![[Database sharedDatabaseInstance] executeStatement:sql])
        _NSLog(@"%@.updateRow FAILED!!!",[[self class] description]);
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
-(NSString *)updateStatement:(NSString *)whereClause
{
    NSArray  *properties = [self getArrayOfProperties];
    NSString *delimiter  = @"";
    
    NSMutableString *sql = [[NSMutableString alloc] initWithString:@"UPDATE "];
    [sql appendString:[self tableName]];
    [sql appendString:@" SET "];
    
    delimiter = @"";

    for( NSString *property in properties )
    {
        if (![property isEqualToString:@"uid"])
        {
            [sql appendFormat:@"%@%@ = %@",delimiter,property,[self valueForProperty:property]];
            delimiter = @" , ";
        }
    }        
    
    if ( whereClause )
    {
        [sql appendString:@" WHERE "];
        [sql appendString:whereClause];
    }

    [sql appendString:@";"];
    return sql;
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
-(void)deleteRow
{
    NSString *criteria = nil;
    NSString *uid_     = nil;
    if ([self respondsToSelector:@selector(uid)])
        uid_ = [self performSelector:@selector(uid)];
    if (uid_)
        criteria = [NSString stringWithFormat:@" uid = %@ ",uid_];
    NSString *sql = [self deleteStatement:criteria];
    if ([[Database sharedDatabaseInstance] executeStatement:sql])
    {
        // Clear UID in object
        if ([self respondsToSelector:@selector(setUid:)])
            [self performSelector:@selector(setUid:) withObject:nil];
    }
    else
        _NSLog(@"%@.deleteRow FAILED!!!",[[self class] description]);
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
-(NSString *)deleteStatement:(NSString *)whereClause
{
    NSMutableString *sql = [[NSMutableString alloc] initWithString:@"DELETE FROM"];

    [sql appendFormat:@" %@ ",[self tableName]];
    if (whereClause)
    {
        [sql appendString:@"WHERE "];
        [sql appendString:whereClause];
    }
    [sql appendString:@";"];
    return sql;
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
-(NSString *)replaceStatement
{
    NSArray  *properties = [self getArrayOfProperties];
    NSString *delimiter  = @"";
    
    NSMutableString *sql = [[NSMutableString alloc] initWithString:@"INSERT OR REPLACE INTO "];
    [sql appendString:[self tableName]];
    [sql appendString:@" ("];
    
    for( NSString *property in properties )
    {
        [sql appendFormat:@"%@%@",delimiter,property];
        delimiter = @",";
    }
    
    [sql appendString:@" ) VALUES ( "];
    
    delimiter = @"";
    
    for( NSString *property in properties )
    {
        [sql appendFormat:@" %@ %@",delimiter,[self valueForProperty:property]];
        delimiter = @",";
    }        
    [sql appendString:@" );"];
    return sql;
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
+(DatabaseObject *)selectRow:(NSInteger)uid
{
    return [[Database sharedDatabaseInstance] lookUpRow:[[self class] description] withPrimaryKey:uid];
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
+(DatabaseObject *)selectRowWithGUID:(NSString *)guid
{
    return [[Database sharedDatabaseInstance] lookUpRow:[[self class] description] thatMatches:[NSString stringWithFormat:@" guid = '%@' ",guid]];
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
+(NSString *)selectStatementWithCriteria:(NSString *)whereClause orderBy:(NSString *)orderByClause
{
    // Instance this class
    id  databaseObject = [[self alloc] init];
    SEL sel            = @selector(selectStatementWithCriteria:orderBy:);
    return [databaseObject performSelector:sel 
                                withObject:whereClause 
                                withObject:orderByClause];
}    

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
-(NSString *)selectStatementWithCriteria:(NSString *)whereClause orderBy:(NSString *)orderByClause
{
    NSArray         *properties = [self getArrayOfProperties];
    NSMutableString *sql        = [[NSMutableString alloc] initWithString:@"SELECT "];
    NSString        *delimiter  = @"";

    for( NSString *property in properties )
    {
        [sql appendFormat:@"%@%@",delimiter,property];
        delimiter = @",";
    }

    [sql appendString:@" FROM "];
    [sql appendString:[self tableName]];
    
    if ( whereClause )
    {
        [sql appendString:@" WHERE "];
        [sql appendString:whereClause];
    }

    if ( orderByClause )
    {
        [sql appendString:@" ORDER BY "];
        [sql appendString:orderByClause];
    }

    [sql appendString:@";"];
    return sql;
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
-(NSString *)tableName
{
    return @"UNKNOWN";
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
-(NSString *)xml
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSArray *properties = [self getArrayOfProperties];
    [result appendFormat:@"<%@>\n",[self tableName]];
    for(NSString *propertyName in properties)
    {
        NSString *rawValue = [self valueForProperty:propertyName xmlFormatting:YES];
        if (!rawValue)
            rawValue = @"";
        NSMutableString *propertyValue = [[NSMutableString alloc] initWithString:rawValue];
        if ([propertyValue isEqualToString:@"NULL"])
            [propertyValue setString:@""];
        else 
        {
            [propertyValue replaceOccurrencesOfString:@"&"  withString:@"&amp;"  options:NSCaseInsensitiveSearch range:NSMakeRange(0,[propertyValue length])];        
            [propertyValue replaceOccurrencesOfString:@"<"  withString:@"&lt;"   options:NSCaseInsensitiveSearch range:NSMakeRange(0,[propertyValue length])];        
            [propertyValue replaceOccurrencesOfString:@">"  withString:@"&gt;"   options:NSCaseInsensitiveSearch range:NSMakeRange(0,[propertyValue length])];        
            [propertyValue replaceOccurrencesOfString:@"'"  withString:@"&apos;" options:NSCaseInsensitiveSearch range:NSMakeRange(0,[propertyValue length])];        
            [propertyValue replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSCaseInsensitiveSearch range:NSMakeRange(0,[propertyValue length])];        
        }
        
        [result appendFormat:@"    <%@>%@</%@>\n",propertyName,propertyValue,propertyName];
    }

    [result appendFormat:@"</%@>\n",[self tableName]];
    return result;
}

@end
