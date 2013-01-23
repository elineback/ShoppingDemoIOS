#import "SDLaunchViewController.h"

@implementation SDLaunchViewController

@synthesize buttonDownloadProducts   = _buttonDownloadProducts;
@synthesize buttonStartDemonstration = _buttonStartDemonstration;

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
#pragma mark IBActions

-(IBAction)buttonDownloadProductsPressed:(id)sender
{
    [_buttonDownloadProducts setEnabled:NO];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    dispatch_async(dispatch_get_global_queue(0, 0),
                   ^ {
                       [SDOpenCartAPI getProducts:self];
                   });
}

-(IBAction)buttonStartDemonstrationPressed:(id)sender
{
    SDAppDelegate *appDelegate = (SDAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate switchToBrowseViewController];
}

#pragma mark -
#pragma mark SDOpenCartAPIDelegate

-(void)refreshProducts
{
    [_hud hide:YES];
    [_buttonStartDemonstration setEnabled:YES];
}

@end
