#import <UIKit/UIKit.h>

#import "SDDatabaseUtils.h"
#import "SDOpenCartAPI.h"

#import "SDPushPopDelegate.h"

@interface SDBaseViewController : UIViewController <SDPushPopDelegate,UITextFieldDelegate,SDOpenCartAPIDelegate>

-(void)msg:(NSString *)message;

-(IBAction)buttonBackPressed:(id)sender;
-(IBAction)buttonBrowsePressed:(id)sender;
-(IBAction)buttonCartPressed:(id)sender;
-(IBAction)buttonCheckoutPressed:(id)sender;
-(IBAction)buttonWishListPressed:(id)sender;
-(IBAction)buttonMorePressed:(id)sender;
-(IBAction)buttonMenuPressed:(id)sender;

-(IBAction)notImplemented:(id)sender;

@end
