#import <UIKit/UIKit.h>

#import "SDBaseViewController.h"

@interface SDSignInViewController : SDBaseViewController
{
    UITextField *_textUsername;
    UITextField *_textPassword;

    UIButton    *_buttonSignOn;
    UIButton    *_buttonPlaceOrder;
    UIButton    *_buttonTermsAndConditions;
}

@property (strong,nonatomic) IBOutlet UITextField *textUsername;
@property (strong,nonatomic) IBOutlet UITextField *textPassword;

@property (strong,nonatomic) IBOutlet UIButton    *buttonSignOn;

-(IBAction)buttonSignInPressed:(id)sender;

@end
