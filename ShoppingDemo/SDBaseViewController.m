#import "SDBaseViewController.h"

#import "Debug.h"
#import "SDAppDelegate.h"

@implementation SDBaseViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark UIAlertView convenience method

-(void)msg:(NSString *)message
{
    _NSLog(@" UIAlertView : '%@'",message);
    
    [[[UIAlertView alloc] initWithTitle:@"Demo"
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    
}

#pragma mark -
#pragma mark Dismiss Keyboard if view touched outside of field

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark -
#pragma mark UITextFieldDelegate - hides keyboard on "return" key

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark IBActions

-(IBAction)buttonBackPressed:(id)sender
{
    SDAppDelegate *app = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
    [app popViewController];
}

-(IBAction)buttonBrowsePressed:(id)sender
{
    SDAppDelegate *app = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
    [app switchToBrowseViewController];
}

-(IBAction)buttonCartPressed:(id)sender
{
    SDAppDelegate *app = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
    [app switchToCartViewController];
}

-(IBAction)buttonCheckoutPressed:(id)sender
{
    SDAppDelegate *app = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
    [app switchToCheckoutViewController];
}

-(IBAction)buttonWishListPressed:(id)sender
{
    SDAppDelegate *app = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
    [app switchToWishListViewController];
}

-(IBAction)buttonMorePressed:(id)sender
{
    SDAppDelegate *app = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
    [app switchToMoreViewController];
}

-(IBAction)buttonMenuPressed:(id)sender
{
    SDAppDelegate *app = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
    [app switchToMenuViewController];
}

#pragma mark -
#pragma mark IBAction catch-all for actions which are not yet available

-(IBAction)notImplemented:(id)sender
{
    [self msg:@"Not implemented"];
}

#pragma mark -
#pragma mark SDOpenCartAPIDelegate

-(void)refreshProducts
{
}

@end
