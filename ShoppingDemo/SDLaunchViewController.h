#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"

#import "SDDatabaseUtils.h"
#import "SDOpenCartAPI.h"
#import "SDAppDelegate.h"
#import "SDBaseViewController.h"

@interface SDLaunchViewController : SDBaseViewController <SDOpenCartAPIDelegate>
{
    UIButton *_buttonDownloadProducts;
    UIButton *_buttonStartDemonstration;
    
    MBProgressHUD *_hud;
}

@property (strong,nonatomic) IBOutlet UIButton *buttonDownloadProducts;
@property (strong,nonatomic) IBOutlet UIButton *buttonStartDemonstration;

-(IBAction)buttonDownloadProductsPressed:(id)sender;
-(IBAction)buttonStartDemonstrationPressed:(id)sender;

@end
