#import <UIKit/UIKit.h>

@protocol SDPushPopDelegate <NSObject>
@optional

-(void)willPushViewController;
-(void)didPushViewController;

-(void)willPopViewController;
-(void)didPopViewController;

-(void)didBecomeCurrentViewController;

@end
