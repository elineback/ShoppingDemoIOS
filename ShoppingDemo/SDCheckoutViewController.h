#import <UIKit/UIKit.h>

#import "SDBaseViewController.h"

@interface SDCheckoutViewController : SDBaseViewController
{
    UIButton *_buttonPlaceOrder;
    UIButton *_buttonPaymentMethodCreditCard;
    UIButton *_buttonPaymentMethodPaypal;
    UIButton *_buttonSignIn;
    UIButton *_buttonTermsAndConditions;
}

@property (strong,nonatomic) IBOutlet UIButton *buttonPlaceOrder;
@property (strong,nonatomic) IBOutlet UIButton *buttonPaymentMethodCreditCard;
@property (strong,nonatomic) IBOutlet UIButton *buttonPaymentMethodPaypal;
@property (strong,nonatomic) IBOutlet UIButton *buttonSignIn;
@property (strong,nonatomic) IBOutlet UIButton *buttonTermsAndConditions;

-(IBAction)buttonPlaceOrderPressed:(id)sender;
-(IBAction)buttonPaymentMethodCreditCardPressed:(id)sender;
-(IBAction)buttonPaymentMethodPaypalPressed:(id)sender;
-(IBAction)buttonSignInPressed:(id)sender;
-(IBAction)buttonTermsAndConditionsPressed:(id)sender;

@end
