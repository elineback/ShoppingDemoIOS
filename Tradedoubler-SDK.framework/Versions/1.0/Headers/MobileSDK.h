#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 Delegate methods called upon attempts to reach the host running the trackback page.
 */
@protocol MobileTrackingDelegate <NSObject>
@optional
- (void) onTrackbackHostReachable;
- (void) onTrackbackHostNotReachable;
- (void) onTrackbackPerformed;
- (void) onPostDownloadTrackbackSucceeded;
- (void) onPostDownloadTrackbackFailed;
- (void) onRegisteredTrackbackResponse;
- (void) onPostDownloadTrackbackInfo: (NSString*)url: (int)timeout;
- (void) onInAppTrackbackSucceeded;
- (void) onInAppTrackbackFailed;
@end

@interface MobileSDK : NSObject <NSURLConnectionDelegate>

+ (void) trackSale:organization withEvent:(NSString *)event withOrderNumber:(NSString *)orderNumber withSecretCode:(NSString *)secretCode
       withTimeout:(int)timeout withCurrency:(NSString *)currency withOrderValue:(NSString*)orderValue;

+ (void) trackDownloadAsLead:(NSString*)organization withEvent:(NSString*)event withSecretCode:(NSString*)secretCode
            withTimeout:(int)timeout withLifeTimeValueDays:(int)ltvDays;

+ (void) trackDownloadAsSale:(NSString*)organization withEvent:(NSString*)event withSecretCode:(NSString*)secretCode
            withTimeout:(int)timeout withLifeTimeValueDays:(int)ltvDays withCurrency:(NSString*)currency withOrderValue:(NSString*)orderValue;

+ (void) postDownloadTrackback:(NSString *)organization withEvent:(NSString *)event withOrderNumber:(NSString *)orderNumber withSecretCode:(NSString *)secretCode
                  withTimeout:(int)timeout withCurrency:(NSString *)currency withOrderValue:(NSString*)orderValue;

+ (void) registerInAppTracking: (NSURL*)url;

+ (void) performInAppTracking:organization withEvent:(NSString *)event withOrderNumber:(NSString *)orderNumber withSecretCode:(NSString *)secretCode
                  withTimeout:(int)timeout withCurrency:(NSString *)currency withOrderValue:(NSString*)orderValue;

+ (NSString*) getProgram;
+ (NSString*) getAffiliate;
+ (NSString*) getLtvExpiry;

+ (void) registerTrackbackResponse:(NSURL*)url;

+ (void) setDelegate: (id)delegate;
+ (void) clearUniqueIdentifier;     // NOTE! Use this _only_ for testing, before calling trackDownload - Which simulates a new unique installation.

@end
