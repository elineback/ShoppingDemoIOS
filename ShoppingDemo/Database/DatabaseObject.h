#import <Foundation/Foundation.h>

@interface DatabaseObject : NSObject

-(id) init;

-(BOOL)isNSDecimalNumber:(NSString *)propertyName;
-(BOOL)isNSNumber:(NSString *)propertyName;
-(BOOL)isNSString:(NSString *)propertyName;
-(void)setPropertyNamed:(NSString *)propertyName toValue:(NSString *)propertyValue;

-(void)insertRow;
-(NSString *)insertStatement;

-(void)updateRow;
-(NSString *)updateStatement:(NSString *)whereClause;

-(void)deleteRow;
-(NSString *)deleteStatement:(NSString *)whereClause;

//-(void)replaceRow;
-(NSString *)replaceStatement;

+(DatabaseObject *)selectRow:(NSInteger)uid;
+(DatabaseObject *)selectRowWithGUID:(NSString *)guid;

+(NSString *)selectStatementWithCriteria:(NSString *)whereClause orderBy:(NSString *)orderByClause;
-(NSString *)selectStatementWithCriteria:(NSString *)whereClause orderBy:(NSString *)orderByClause;

-(NSString *)tableName;

-(NSString *)xml;

@end
