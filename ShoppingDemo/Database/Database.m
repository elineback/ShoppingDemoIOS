#import "Database.h"
#import "DatabaseObject.h"
#import "Debug.h"
 
static Database   *sharedDatabase = nil;
static char       *databasePath;
 
@implementation Database
 
#pragma mark -
#pragma mark Singleton Methods
 
////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
+ (id)sharedDatabaseInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedDatabase == nil) {
            sharedDatabase = [[self alloc] init];
        }
    });
    return sharedDatabase;
}
 
////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
- (id)init
{
    if (self = [super init]) 
	{
		// No custom set up needed.
    }
    return self;
}

#pragma mark -
#pragma mark Utility Methods

////////////////////////////////////////////////////////////////////////////////
// Returns the documents directory for the App
////////////////////////////////////////////////////////////////////////////////
-(NSString *)documents
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

#pragma mark -
#pragma mark Database Management Methods

////////////////////////////////////////////////////////////////////////////////
// Create an empty database in the Documents directory
////////////////////////////////////////////////////////////////////////////////
-(BOOL)create:(NSString *)databaseName
{
    int ret = SQLITE_OK;
    sqlite3 *db;
	NSString      *dbPath      = [[NSString alloc] initWithString: [[self documents] stringByAppendingPathComponent:databaseName]];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath: dbPath] == NO)
	{
		databasePath = strdup([dbPath UTF8String]);
        ret = sqlite3_open(databasePath, &db);
	    if (ret == SQLITE_OK)
		{
			sqlite3_close(db);
			return YES;
		}
        else
            _NSLog(@"ERROR - Database could not be created, status %d.",ret);
	}
    else
        _NSLog(@"ERROR - Database already exists.");
	return NO;
}

////////////////////////////////////////////////////////////////////////////////
// Copy a database from the App bundle to the Documents directory
// Sets the databasePath to the copy of the database in the Documents directory
// Optionally overwrites an existing file
////////////////////////////////////////////////////////////////////////////////
-(BOOL)install:(NSString *)databaseName
{
    return [self install:databaseName shallOverwrite:NO];
}

-(BOOL)install:(NSString *)databaseName shallOverwrite:(BOOL)overwrite
{
    BOOL          result                      = YES;
	NSString      *applicationBundleDatabase  = [[NSBundle mainBundle] pathForResource:databaseName ofType:nil];
	NSString      *documentsDirectoryDatabase = [[NSString alloc] initWithString: [[self documents] stringByAppendingPathComponent:databaseName]];

    databasePath = strdup( [documentsDirectoryDatabase UTF8String] );
	NSError       *error;
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:documentsDirectoryDatabase];

    // -----------------------------------------------------------------------------------------------
    // If the database does not already exist, just copy it from the bundle
    // -----------------------------------------------------------------------------------------------
    if ( !fileExists )
    {
        result = [[NSFileManager defaultManager] copyItemAtPath:applicationBundleDatabase 
                                                         toPath:documentsDirectoryDatabase 
                                                          error:&error];
        if (!result)
            _NSLog(@"ERROR - Failed to copy file, Code %d Description '%@' Reason '%@'",
                  [error code],
                  [error localizedDescription],
                  [error localizedFailureReason] );
    
    }
    // -----------------------------------------------------------------------------------------------
    // If the database does exist and we're not overwriting, then that's an unresolvable error
    // -----------------------------------------------------------------------------------------------
    else if ( fileExists && !overwrite )
    {
        _NSLog(@"ERROR - File exists at destination, and not in overwrite mode.");
    }
    // -----------------------------------------------------------------------------------------------
    // If the database does exist and we're overwriting, then overwrite it
    // -----------------------------------------------------------------------------------------------
    else if ( fileExists && overwrite )
    {
        result = [[NSFileManager defaultManager] removeItemAtPath:documentsDirectoryDatabase error:&error];
        
        if ( result )
            result = [[NSFileManager defaultManager] copyItemAtPath:applicationBundleDatabase 
                                                             toPath:documentsDirectoryDatabase 
                                                              error:&error];

        if (!result)
            _NSLog(@"ERROR - Failed to overwrite file, Code %d Description '%@' Reason '%@'",
                  [error code],
                  [error localizedDescription],
                  [error localizedFailureReason] );
    }
    return result;
}

////////////////////////////////////////////////////////////////////////////////
// Upgrade an existing database based on database versions
////////////////////////////////////////////////////////////////////////////////
-(BOOL)upgrade:(NSString *)databaseName
{
    BOOL          result                      = YES;
	NSString      *applicationBundleDatabase  = [[NSBundle mainBundle] pathForResource:databaseName ofType:nil];
	NSString      *documentsDirectoryDatabase = [[NSString alloc] initWithString: [[self documents] stringByAppendingPathComponent:databaseName]];
    
    databasePath = strdup( [documentsDirectoryDatabase UTF8String] );
	NSError       *error;
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:documentsDirectoryDatabase];
    
    // -----------------------------------------------------------------------------------------------
    // If the database does not exist then just copy it from the bundle
    // -----------------------------------------------------------------------------------------------
    if ( !fileExists )
    {
        _NSLog(@"Database not installed so performing a copy from application bundle to documents directory");
        result = [[NSFileManager defaultManager] copyItemAtPath:applicationBundleDatabase 
                                                         toPath:documentsDirectoryDatabase 
                                                          error:&error];
        
        if (!result)
            _NSLog(@"ERROR - Failed to copy database, Code %d Description '%@' Reason '%@'",
                  [error code],
                  [error localizedDescription],
                  [error localizedFailureReason] );
        
    }
    // -----------------------------------------------------------------------------------------------
    // The database does exist, so compare db versions
    // -----------------------------------------------------------------------------------------------
    else if ( fileExists )
    {
        _NSLog(@"Database exists so comparing database User Version values");
              
        // SQLite3 file format includes a user version at position 60 in the database file.
        // This value is stored in "big-endian" format and is four bytes long.
        // It can be read/set in SQLite3 using the following statements.
        //
        // PRAGMA user_version; 
        // PRAGMA user_version = integer ;
        // 
        // We use it to set the database version to the build number of the application.
        
        unsigned long long SQLITE3_USER_VERSION_OFFSET = 60;
        
        NSFileHandle *applicationBundleDatabaseHandle = [NSFileHandle fileHandleForReadingAtPath:applicationBundleDatabase];
        [applicationBundleDatabaseHandle seekToFileOffset:SQLITE3_USER_VERSION_OFFSET];
        NSData *applicationBundleDatabaseVersionData = [applicationBundleDatabaseHandle readDataOfLength:4];
        [applicationBundleDatabaseHandle closeFile];
        UInt32 *pApplicationBundleVersion = (UInt32 *)applicationBundleDatabaseVersionData.bytes;
        // Use ntohl (Network byte order to Host Byte Order) to convert big-endian to little-endian
        UInt32 applicationBundleVersion = ntohl(*pApplicationBundleVersion);
        
        NSFileHandle *documentsDirectoryDatabaseHandle = [NSFileHandle fileHandleForReadingAtPath:documentsDirectoryDatabase];
        [documentsDirectoryDatabaseHandle seekToFileOffset:SQLITE3_USER_VERSION_OFFSET];
        NSData *documentsDirectoryDatabaseVersionData = [documentsDirectoryDatabaseHandle readDataOfLength:4];
        [documentsDirectoryDatabaseHandle closeFile];
        UInt32 *pDocumentDirectoryVersion = (UInt32 *)documentsDirectoryDatabaseVersionData.bytes;
        // Use ntohl (Network byte order to Host Byte Order) to convert big-endian to little-endian
        UInt32 documentDirectoryVersion = ntohl(*pDocumentDirectoryVersion);

        _NSLog(@"Application Bundle Database Version %lu",applicationBundleVersion);
        _NSLog(@"Document Directory Database Version %lu",documentDirectoryVersion);

        if (applicationBundleVersion > documentDirectoryVersion)
        {
            _NSLog(@"Existing database version is less than bundle database - existing database will be replaced.");

            result = [[NSFileManager defaultManager] removeItemAtPath:documentsDirectoryDatabase 
                                                                error:&error];
            if (result)
                result = [[NSFileManager defaultManager] copyItemAtPath:applicationBundleDatabase 
                                                                 toPath:documentsDirectoryDatabase 
                                                                  error:&error];
            if (!result)
                _NSLog(@"ERROR - Failed to overwrite database with new version, Code %d Description '%@' Reason '%@'",
                      [error code],
                      [error localizedDescription],
                      [error localizedFailureReason] );
        }
        else 
        {
            _NSLog(@"Existing database version is equal to or greater than bundle database - no action taken.");
        }
    }
    return result;
}

////////////////////////////////////////////////////////////////////////////////
// Open a database of a given name assumed to be located in the Documents directory.
////////////////////////////////////////////////////////////////////////////////
-(BOOL)open:(NSString *)databaseName
{
	NSString      *dbPath      = [[NSString alloc] initWithString: [[self documents] stringByAppendingPathComponent:databaseName]];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL result = [fileManager fileExistsAtPath: dbPath];
    if ( result )
		databasePath = strdup( [dbPath UTF8String] );
    else
        _NSLog(@"ERROR - File does not exist");
	return result;
}

////////////////////////////////////////////////////////////////////////////////
// Close the currently open database
////////////////////////////////////////////////////////////////////////////////
-(BOOL)close
{
    databasePath = NULL;
	return YES;
}

#pragma mark GUID Methods

////////////////////////////////////////////////////////////////////////////////
// Create a GUID.
////////////////////////////////////////////////////////////////////////////////
-(NSString *)makeGUID
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return uuidString;
}

#pragma mark SQL Execution Methods

////////////////////////////////////////////////////////////////////////////////
// Execute an SQL statement that does not return any data, i.e. DELETE, INSERT, UPDATE, etc.
// This can also be used for DDL statements.
////////////////////////////////////////////////////////////////////////////////
-(BOOL)executeStatement:(NSString *)statement
{
    int ret = SQLITE_OK;
    sqlite3 *db;
    if (!databasePath)
        _NSLog(@"ERROR - Database Path is NULL");
    ret = sqlite3_open(databasePath,&db);
    if (ret == SQLITE_OK)
	{
		char *errorMessage_;
		const char *sqlStatement = [statement UTF8String];
		ret = sqlite3_exec(db, sqlStatement, NULL, NULL, &errorMessage_);
        if ( ret != SQLITE_OK)
        {
            NSMutableString *errorMessage = [[NSMutableString alloc] init];
            if (errorMessage_)
            {
                NSString *temp = [[NSString alloc] initWithUTF8String:errorMessage_];
                [errorMessage appendString:temp];
            }
            _NSLog(@"ERROR - Statement %@ failed, status %d, message '%@'",statement, ret, errorMessage);
			return NO;
        }
        sqlite3_close(db);
        return YES;
	}
    else
        _NSLog(@"ERROR - Database could not be opened, status %d",ret);
	return NO;
}

////////////////////////////////////////////////////////////////////////////////
// Execute a batch of SQL statements
// This can also be used for DDL statements.
////////////////////////////////////////////////////////////////////////////////
-(BOOL)executeStatements:(NSArray *)arrayOfStatements
{
    BOOL result = YES;
    for( NSString *statement in arrayOfStatements )
    {
        result = [self executeStatement:statement];
        if (!result)
            break;
    }
    return result;
}

////////////////////////////////////////////////////////////////////////////////
// Execute a batch of SQL statements in a text file. The file name must be provided with the full path.
////////////////////////////////////////////////////////////////////////////////
-(BOOL)executeScript:(NSString *)scriptFilePath
{
    NSError  *error;
    NSString *content    = [NSString stringWithContentsOfFile:scriptFilePath encoding:NSUTF8StringEncoding error:&error];
    NSArray  *statements = [content componentsSeparatedByString: @"\n"];
    return [self executeStatements:statements];
}

////////////////////////////////////////////////////////////////////////////////
// Execute a query that returns a result set. The result set is returned as an NSArray of NSDictionary objects.
// Each NSDictionary object is set of column names as keys, and column values as values. The full SQL statement
// is executed, and data types are NOT coerced - they remain as NSStrings.
////////////////////////////////////////////////////////////////////////////////
-(NSArray *)executeQuery:(NSString *)query
{
    _NSLog(@"executeQuery : %@",query);
    
    int ret = SQLITE_OK;
    sqlite3      *db;
	NSMutableArray *results = [[NSMutableArray alloc] init];
    
    if ( ![[NSFileManager defaultManager] 
           fileExistsAtPath:[NSString 
                             stringWithCString:databasePath 
                             encoding:NSUTF8StringEncoding]] )
        _NSLog(@"ERROR - Can't find database file.");

    ret = sqlite3_open(databasePath,&db);
    if ( ret == SQLITE_OK )
    {
        sqlite3_stmt *statement;
    	const char *sql = [query UTF8String];

        ret = sqlite3_prepare_v2(db, sql, -1, &statement, NULL);
        if (ret == SQLITE_OK)
        {
        	while (sqlite3_step( statement ) == SQLITE_ROW)
            {
				NSMutableDictionary *columns = [[NSMutableDictionary alloc] init];
				for(int i = 0 ; i < sqlite3_column_count(statement) ; i++)
				{
                    const char *cName  = (const char *)sqlite3_column_name(statement, i);
                    const char *cValue = (const char *)sqlite3_column_text(statement, i);
					NSString *columnName  = [[NSString alloc] initWithUTF8String:cName];
                    NSString *columnValue = (cValue ? [[NSString alloc] initWithUTF8String:cValue] : nil);
                    if (columnValue)
                    {
                        [columns setObject:columnValue forKey:columnName];
                    }
                    else
                    {
                    }
				}
				[results addObject:columns];
			}
            // Delete statement
			sqlite3_finalize(statement);
		}
		sqlite3_close(db);
	}
    else 
        _NSLog(@"ERROR - Database could not be opened, status %d",ret);
	return results;
}

////////////////////////////////////////////////////////////////////////////////
// Perform a query that returns ONE column from ONE row as an INTEGER
////////////////////////////////////////////////////////////////////////////////
-(NSInteger) executeIntegerQuery:(NSString *)query column:(NSString *)columnName
{
    NSInteger result = 0;
    NSArray *results = [self executeQuery:query];
    if (results)
    {
        if ([results count] > 0)
        {
            NSDictionary *row = [results objectAtIndex:0];
            NSString     *column = [row objectForKey:columnName];
            result = [column intValue];
        }
    }
    return result;
}

////////////////////////////////////////////////////////////////////////////////
// Perform a query that returns ONE column from ONE row as a FLOAT
////////////////////////////////////////////////////////////////////////////////
-(CGFloat) executeFloatQuery:(NSString *)query column:(NSString *)columnName
{
    CGFloat result = 0;
    NSArray *results = [self executeQuery:query];
    if (results)
    {
        if ([results count] > 0)
        {
            NSDictionary *row = [results objectAtIndex:0];
            NSString     *column = [row objectForKey:columnName];
            result = [column floatValue];
        }
    }
    return result;
}

////////////////////////////////////////////////////////////////////////////////
// Perform a query that returns ONE column from ONE row as a STRING
////////////////////////////////////////////////////////////////////////////////
-(NSString *)executeStringQuery:(NSString *)query  column:(NSString *)columnName
{
    NSString *result = @"";
    NSArray *results = [self executeQuery:query];
    if (results)
    {
        if ([results count] > 0)
        {
            NSDictionary *row = [results objectAtIndex:0];
            result = [row objectForKey:columnName];
        }
    }
    return result;
}

////////////////////////////////////////////////////////////////////////////////
// Perform a query that returns ONE column from ONE row as a DATE
////////////////////////////////////////////////////////////////////////////////
-(NSDate *)executeDateQuery:(NSString *)query  column:(NSString *)columnName
{
    NSString *result = @"";
    NSDate   *date   = nil;
    NSArray *results = [self executeQuery:query];
    if (results)
    {
        if ([results count] > 0)
        {
            NSDictionary *row = [results objectAtIndex:0];
            if (row)
            {
                result = [row objectForKey:columnName];
                if (result)
                    date = [Database iso8601StringAsDate:result];
            }
        }
    }
    return date;
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
-(NSArray *)load:(NSArray *)resultSet into:(NSString *)tableName
{
    if (!resultSet || !tableName)
    {
        _NSLog(@"ERROR - resultSet or tableName is nil");
        return nil;
    }
    if ([resultSet count] == 0 || [tableName length] == 0)
        return nil;
    
    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:[resultSet count]];
    int rowIndex = 0;
    for(NSDictionary *row in resultSet)
    {
        _NSLog(@"Row %d",rowIndex);
        id rowObject = [[NSClassFromString(tableName) alloc] init];
        for(id column in row)
        {
            DatabaseObject *obj = (DatabaseObject *)rowObject;
            NSString *value = [row objectForKey:column];
            [obj setPropertyNamed:column toValue:value];

            // [rowObject setValue:[row objectForKey:column] forKey:column];
            
            _NSLog(@"... Table : '%@', Column : '%@', Value : '%@'",
                   tableName,
                   column,
                   [rowObject valueForKey:column]);
        }
        [objects setObject:rowObject atIndexedSubscript:rowIndex];
        rowIndex++;
    }
    _NSLog(@"Number of objects loaded %d",[objects count]);
    return objects;
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
-(NSArray *)selectWithCriteria:(NSString *)criteria orderBy:(NSString *)orderByClause forClass:(NSString *)className
{
    Class clazz = NSClassFromString(className);
    if (clazz)
    {
        id obj = [[clazz alloc] init];
        if (obj)
        {
            if ([obj respondsToSelector:@selector(selectStatementWithCriteria:orderBy:)])
            {
                NSString *sql = [obj performSelector:@selector(selectStatementWithCriteria:orderBy:) 
                                          withObject:criteria 
                                          withObject:orderByClause]; 
                NSArray *resultSet = [self executeQuery:sql];
                if ( resultSet )
                {
                    if ( [resultSet count] )
                    {
                        return [self load:resultSet into:className];
                    }
                }
            }
        }
    }
    return [[NSArray alloc] init];
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
-(NSInteger)lastSequence:(NSString *)sequenceName
{
    NSInteger result = -1;
	NSArray *results = [self executeQuery:[NSString 
                                           stringWithFormat:@"SELECT seq from SQLITE_SEQUENCE WHERE name='%@';",
                                           sequenceName]];
    if ( results )
    {
        if ( [results count] > 0 )
        {
            NSDictionary *row = (NSDictionary *)[results objectAtIndex:0];
            NSString *column  = (NSString *)[row objectForKey:@"seq"];
            if (column)
                result = [column integerValue];
        }
    }
    return result;
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
-(id)lookUpRow:(NSString *)tableName withPrimaryKey:(NSInteger)primaryKey
{
    return [self lookUpRow:tableName thatMatches:[NSString stringWithFormat:@" uid = %d ",primaryKey]];
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
-(id)lookUpRow:(NSString *)tableName thatMatches:(NSString *)criteria
{
    id row = [[NSClassFromString(tableName) alloc] init];
    if (row)
    {
        SEL sel = @selector(selectStatementWithCriteria:orderBy:);
        if ( [row respondsToSelector:sel] )
        {
            NSString *sql  = [row performSelector:sel withObject:criteria withObject:nil];
            NSArray  *rows = [self executeQuery:sql];
            if (rows)
            {
                if ([rows count])
                {
                    NSDictionary *columns = (NSDictionary *)[rows objectAtIndex:0];
                    for(id column in columns)
                    {
                        NSString *value = (NSString *)[columns objectForKey:column];
                        [row performSelector:@selector(setPropertyNamed:toValue:) withObject:column withObject:value];
                    }
                }
                else 
                {
                    return nil;
                }
            }
            else 
            {
                return nil;
            }
        }
        else 
        {
            _NSLog(@"ERROR - '%@' does not respond to selectStatement",tableName);
            return nil;
        }
    }
    else 
    {
        _NSLog(@"ERROR - Could not instance '%@'",tableName);
        return nil;
    }
    return row;
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
-(NSString *)lookUpField:(NSString *)fieldName inTable:(NSString *)tableName forKey:(NSNumber *)uid
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE uid = %d;",
                     fieldName,
                     tableName,
                     [uid intValue]];
    NSArray *results = [self executeQuery:sql];
    if ( results )
    {
        if ( [results count] > 0 )
        {
            NSDictionary *row = (NSDictionary *)[results objectAtIndex:0];
            if (row)
            {
                NSString *column  = (NSString *)[row objectForKey:fieldName];
                if (column)
                    [result appendString:column];
            }
        }
    }
    return result;
}

////////////////////////////////////////////////////////////////////////////////
// YYYY-MM-DD HH:MM:SS
////////////////////////////////////////////////////////////////////////////////
+(NSString *)iso8601DateAsString:(NSDate *)date
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormat stringFromDate:date];
}

////////////////////////////////////////////////////////////////////////////////
// YYYY-MM-DD HH:MM:SS
////////////////////////////////////////////////////////////////////////////////
+(NSDate *)iso8601StringAsDate:(NSString *)string
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormat dateFromString:string];  
}

@end
