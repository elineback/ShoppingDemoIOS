#import "SDCheckoutViewController.h"

#import "SDAppDelegate.h"
#import "SDSignInViewController.h"

#import "SDTagManSDKAPI.h"

@implementation SDCheckoutViewController

@synthesize buttonPlaceOrder                = _buttonPlaceOrder;
@synthesize buttonPaymentMethodCreditCard   = _buttonPaymentMethodCreditCard;
@synthesize buttonPaymentMethodPaypal       = _buttonPaymentMethodPaypal;
@synthesize buttonSignIn                    = _buttonSignIn;
@synthesize buttonTermsAndConditions        = _buttonTermsAndConditions;

#pragma mark -
#pragma mark View Life Cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewDidAppear:(BOOL)animated
{
    SDAppDelegate *app = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (app.account)
    {
        [_buttonPlaceOrder setEnabled:YES];
        [_buttonSignIn setTitle:@"   Sign Out" forState:UIControlStateNormal];
    }
    else
    {
        [_buttonPlaceOrder setEnabled:NO];
        [_buttonSignIn setTitle:@"   Sign In" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark IBActions

-(IBAction)buttonPlaceOrderPressed:(id)sender
{
    // Convert the shopping cart to an order
    SDAppDelegate *app = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (app.account)
    {
        Cart *order = [[SDDatabaseUtils defaultInstance] convertShoppingCartToOrderForAccount:[app.account.uid intValue] withPaymentMethod:0];
        
        [SDTagManSDKAPI tagManPostOrder:order];
        [SDTagManSDKAPI tradeDoublerPostOrder:order];

        [self msg:@"Your order has been placed."];
    }
    else
    {
        [self msg:@"You must be signed in to place and order."];
    }
}

-(IBAction)buttonPaymentMethodCreditCardPressed:(id)sender
{
    [super notImplemented:sender];
}

-(IBAction)buttonPaymentMethodPaypalPressed:(id)sender
{
    [super notImplemented:sender];
}

-(IBAction)buttonSignInPressed:(id)sender
{
    SDAppDelegate *app = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (app.account)
    {
        [app setAccount:nil];
        [_buttonPlaceOrder setEnabled:NO];
        [_buttonSignIn setTitle:@"   Sign In" forState:UIControlStateNormal];
    }
    else
    {
        SDSignInViewController *signInViewController = [[SDSignInViewController alloc] initWithNibName:@"SDSignInViewController" bundle:nil];
        [app pushViewController:signInViewController];
    }
}

-(IBAction)buttonTermsAndConditionsPressed:(id)sender
{
    [super notImplemented:sender];
}

@end
