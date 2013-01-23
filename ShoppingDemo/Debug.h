#ifndef DEBUG_H
#define DEBUG_H

#include "time.h"

#define _NSLog(__FORMAT__,...)   {                                                                                   \
                                     NSDate          *__debugLogDateTime      = [NSDate date];                       \
                                     NSDateFormatter *__debugLogDateFormatter = [[NSDateFormatter alloc] init];      \
                                     [__debugLogDateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];                 \
                                     fprintf( stderr                                                               , \
                                         "%s [ %s : %d : %s ] %s\n"                                                , \
                                         [[__debugLogDateFormatter stringFromDate:__debugLogDateTime] UTF8String]  , \
                                         [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String] , \
                                         __LINE__                                                                  , \
                                         __PRETTY_FUNCTION__                                                       , \
                                         [[NSString stringWithFormat:__FORMAT__ , ##__VA_ARGS__] UTF8String]);       \
                                 }

#define _ERROR_TEMPLATE         @"\nError\n... Description         \"%@\"\n... Failure Reason      \"%@\"\n... Recovery Options    \"%@\"\n... Recovery Suggestion \"%@\"\n"
#define _ERROR(e)               _NSLog(_ERROR_TEMPLATE,[e localizedDescription],[error localizedFailureReason],[error localizedRecoveryOptions],[error localizedRecoverySuggestion])

#define _ENTER                  // _NSLog( @"*** Enter ***" );
#define _LEAVE                  // _NSLog( @"*** Leave ***" );

#define _ISNIL(var)             _NSLog( @"%s is %@" , #var , ( var ? @ "not NIL" : @"NIL"   ) );
#define _ISTRUE(var)            _NSLog( @"%s is %@" , #var , ( var ? @ "TRUE"    : @"FALSE" ) );

#endif // DEBUG_H
