#import <Foundation/Foundation.h>
#import "sqlite3.h"

#import "Debug.h"

#ifndef __DATABASE_H__
#define __DATABASE_H__

#define __DATABASE_TRUE__  ([[NSNumber alloc] initWithInt:1])
#define __DATABASE_FALSE__ ([[NSNumber alloc] initWithInt:0])

// Convenience macros

#define DBBOOLEAN(x) ( (x) ? __DATABASE_TRUE__ : __DATABASE_FALSE__ )
#define DBDATE(x)    ([Database iso8601DateAsString:(x)])
#define DBFALSE()    (__DATABASE_FALSE__)
#define DBGUID()     ([[Database sharedDatabaseInstance] makeGUID])
#define DBINTEGER(x) ([[NSNumber alloc] initWithInt:(x)])
#define DBREAL(x)    ([[NSDecimalNumber alloc] initWithFloat:(x)])
#define DBSTRING(x)  (x)
#define DBTRUE()     (__DATABASE_TRUE__)

#endif // __DATABASE_H__

@interface Database : NSObject 
{
}

+ (id)sharedDatabaseInstance;

-(BOOL)create:(NSString *)databaseName;
-(BOOL)install:(NSString *)databaseName; 
-(BOOL)install:(NSString *)databaseName shallOverwrite:(BOOL)overwrite;
-(BOOL)upgrade:(NSString *)databaseName;
-(BOOL)open:(NSString *)databaseName;
-(BOOL)close;
-(NSString *)makeGUID;
-(BOOL)executeStatement:(NSString *)statement;
-(BOOL)executeStatements:(NSArray *)arrayOfStatements;
-(BOOL)executeScript:(NSString *)scriptFilePath;
-(NSArray *)executeQuery:(NSString *)query;

-(NSInteger) executeIntegerQuery:(NSString *)query column:(NSString *)columnName;
-(CGFloat)   executeFloatQuery:(NSString *)query   column:(NSString *)columnName;
-(NSString *)executeStringQuery:(NSString *)query  column:(NSString *)columnName;
-(NSDate *)  executeDateQuery:(NSString *)query    column:(NSString *)columnName;

-(NSArray *)load:(NSArray *)resultSet into:(NSString *)tableName;
-(NSArray *)selectWithCriteria:(NSString *)criteria orderBy:(NSString *)orderByClause forClass:(NSString *)className;
-(NSInteger)lastSequence:(NSString *)sequenceName;
-(id)lookUpRow:(NSString *)tableName withPrimaryKey:(NSInteger)primaryKey;
-(id)lookUpRow:(NSString *)tableName thatMatches:(NSString *)criteria;
-(NSString *)lookUpField:(NSString *)fieldName inTable:(NSString *)tableName forKey:(NSNumber *)uid;
+(NSString *)iso8601DateAsString:(NSDate *)date;
+(NSDate *)iso8601StringAsDate:(NSString *)string;

@end