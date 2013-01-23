#import "SDSignInViewController.h"

#import "SDAppDelegate.h"

@implementation SDSignInViewController

@synthesize textUsername = _textUsername;
@synthesize textPassword = _textPassword;
@synthesize buttonSignOn = _buttonSignOn;

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

- (void)viewDidAppear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(IBAction)buttonSignInPressed:(id)sender
{
    NSString *result = [SDOpenCartAPI signOnWithEmailAddress:_textUsername.text password:_textPassword.text];
    if (result == nil)
    {
        SDAppDelegate *app = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
        [self msg:[NSString stringWithFormat:@"Welcome, %@ %@!",app.account.forename,app.account.surname]];
        [app popViewController];
    }
    else
    {
        [self msg:[NSString stringWithFormat:@"%@",result]];
    }
}

@end
