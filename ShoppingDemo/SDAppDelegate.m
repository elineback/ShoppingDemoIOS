#import "SDAppDelegate.h"

#import "TestFlight.h"
#import "TestFlightToken.h"

#import "MMAdvertiser.h"
#import <Tradedoubler-SDK/MobileSDK.h>

#import "Debug.h"

#import "SDDatabaseUtils.h"
#import "SDOpenCartAPI.h"

#import "SDBaseViewController.h"
#import "SDBrowseViewController.h"
#import "SDCartViewController.h"
#import "SDCheckoutViewController.h"
#import "SDLaunchViewController.h"
#import "SDMenuViewController.h"
#import "SDMoreViewController.h"
#import "SDSignInViewController.h"
#import "SDThankYouViewController.h"
#import "SDWishListViewController.h"

@implementation SDAppDelegate

@synthesize account         = _account;
@synthesize productCategory = _productCategory;

#pragma mark -
#pragma mark Application Life Cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ////////////////////////////////////////////////////////////////////////////
    // TESTFLIGHT
    ////////////////////////////////////////////////////////////////////////////
    
    // If we are in a DEBUG build then we do NOT enable TestFlight as it blocks exceptions
    // and prevents debug traces from being written to the console.
#ifndef DEBUG
    // Note that the UDID is deprecated but for now we'll use it.
    // We use a pragma here to turn off the stupid warning about deprecations.
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#pragma GCC diagnostic warning "-Wdeprecated-declarations"
    // Start TestFlight
    [TestFlight takeOff:@"939ae8ce33a60662f9e1b494381c1108_MTE2MTgzMjAxMi0wNy0zMSAwOToxMjoxNC4zMDk0NjA"];
    
    NSMutableDictionary *testFlightOptions = [[NSMutableDictionary alloc] init];
    [testFlightOptions setObject:[NSNumber numberWithBool:YES] forKey:@"disableInAppUpdates"];
    [TestFlight setOptions:testFlightOptions];
#endif

    ////////////////////////////////////////////////////////////////////////////
    // Redirect STDERR to debug.txt
    ////////////////////////////////////////////////////////////////////////////
    [self logToFile];
    
    ////////////////////////////////////////////////////////////////////////////
    // Track conversion
    ////////////////////////////////////////////////////////////////////////////

    // Start of App Download Tracking
    NSString *organization = @"1710346";
    NSString *event        = @"260143";
    NSString *secretCode   = @"23123";
    NSString *currency     = @"EUR";
    NSString *orderValue   = @"1.49";
    int timeout            = 5; // in seconds
    int lifeTimeValue      = 10; // In days
    
    [MobileSDK trackDownloadAsSale:organization
                         withEvent:event
                    withSecretCode:secretCode
                       withTimeout:timeout
             withLifeTimeValueDays:lifeTimeValue
                      withCurrency: currency
                    withOrderValue:orderValue];

    ////////////////////////////////////////////////////////////////////////////
    // Start UI
    ////////////////////////////////////////////////////////////////////////////
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    SDLaunchViewController *sdlvc  = [[SDLaunchViewController alloc] initWithNibName:@"SDLaunchViewController" bundle:nil];
    self.viewController            = sdlvc;
    self.window.rootViewController = sdlvc;
    [self.window makeKeyAndVisible];

    ////////////////////////////////////////////////////////////////////////////
    // Set up database
    ////////////////////////////////////////////////////////////////////////////
    [[Database sharedDatabaseInstance] install:@"demo.db" shallOverwrite:YES];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (BOOL)application:(UIApplication *)application:(NSURL *)url
{
    [MobileSDK registerTrackbackResponse:url];
    return YES;
}

#pragma mark -
#pragma mark View Navigation

////////////////////////////////////////////////////////////////////////////////
// Tab Bar View Controllers - these clear down the "history of view controllers".
////////////////////////////////////////////////////////////////////////////////

-(void) switchToBrowseViewController
{
    _ENTER
    if (_arrayOfViewControllers)
        [_arrayOfViewControllers removeAllObjects];
    SDBrowseViewController *browseViewController = [[SDBrowseViewController alloc] initWithNibName:@"SDBrowseViewController" bundle:nil];
    if (!browseViewController)
        _NSLog(@"browseViewController is nil");
    [self pushViewController:browseViewController];
    _LEAVE
}

-(void) switchToCartViewController
{
    _ENTER
    if (_arrayOfViewControllers)
        [_arrayOfViewControllers removeAllObjects];
    SDCartViewController *cartViewController = [[SDCartViewController alloc] initWithNibName:@"SDCartViewController" bundle:nil];
    if (!cartViewController)
        _NSLog(@"cartViewController is nil");
    [self pushViewController:cartViewController];
    _LEAVE
}

-(void) switchToCheckoutViewController
{
    _ENTER
    if (_arrayOfViewControllers)
        [_arrayOfViewControllers removeAllObjects];
    SDCheckoutViewController *checkoutViewController = [[SDCheckoutViewController alloc] initWithNibName:@"SDCheckoutViewController" bundle:nil];
    if (!checkoutViewController)
        _NSLog(@"checkoutViewController is nil");
    [self pushViewController:checkoutViewController];
    _LEAVE
}

-(void) switchToWishListViewController
{
    _ENTER
    if (_arrayOfViewControllers)
        [_arrayOfViewControllers removeAllObjects];
    SDWishListViewController *wishlistViewController = [[SDWishListViewController alloc] initWithNibName:@"SDWishListViewController" bundle:nil];
    if (!wishlistViewController)
        _NSLog(@"wishlistViewController is nil");
    [self pushViewController:wishlistViewController];
    _LEAVE
}

-(void) switchToMoreViewController
{
    _ENTER
    if (_arrayOfViewControllers)
        [_arrayOfViewControllers removeAllObjects];
    SDMoreViewController *moreViewController = [[SDMoreViewController alloc] initWithNibName:@"SDMoreViewController" bundle:nil];
    if (!moreViewController)
        _NSLog(@"moreViewController is nil");
    [self pushViewController:moreViewController];
    _LEAVE
}

////////////////////////////////////////////////////////////////////////////////
// Menu
////////////////////////////////////////////////////////////////////////////////

-(void) switchToMenuViewController
{
    SDMenuViewController *menuViewController = [[SDMenuViewController alloc] initWithNibName:@"SDMenuViewController" bundle:nil];
    [self pushViewController:menuViewController];
}

////////////////////////////////////////////////////////////////////////////////
// General view controller history management
////////////////////////////////////////////////////////////////////////////////

-(void) pushViewController:(UIViewController *)vc
{
    _ENTER
    if (!_arrayOfViewControllers)
        _arrayOfViewControllers = [[NSMutableArray alloc] init];
    
    if ([vc respondsToSelector:@selector(willPushViewController)])
        [vc performSelector:@selector(willPushViewController)];
    
    [_arrayOfViewControllers addObject:vc];
    
    if ([vc respondsToSelector:@selector(didPushViewController)])
        [vc performSelector:@selector(didPushViewController)];
    
    if ([vc respondsToSelector:@selector(didBecomeCurrentViewController)])
        [vc performSelector:@selector(didBecomeCurrentViewController)];
    
    self.viewController            = (SDBaseViewController *)vc;
    self.window.rootViewController = vc;

    _LEAVE
}

-(void) popViewController
{
    _ENTER
    if ([_arrayOfViewControllers count] > 0)
    {
        id tmp = [_arrayOfViewControllers lastObject];
        
        if ([tmp respondsToSelector:@selector(willPopViewController)])
            [tmp performSelector:@selector(willPopViewController)];
        
        [_arrayOfViewControllers removeLastObject];
        
        if ([tmp respondsToSelector:@selector(didPopViewController)])
            [tmp performSelector:@selector(didPopViewController)];
    }
    
    if ([_arrayOfViewControllers count] > 0)
    {
        UIViewController *vc = [_arrayOfViewControllers lastObject];
        
        self.viewController = (SDBaseViewController *)vc;
        self.window.rootViewController = vc;
        
        if ([vc respondsToSelector:@selector(didBecomeCurrentViewController)])
            [vc performSelector:@selector(didBecomeCurrentViewController)];
    }
    _LEAVE
}

#pragma mark -
#pragma mark Redirect STDERR console output to a file for attachment to an email

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////

-(BOOL) logToFile
{
    // Only redirect STDERR if the console is not connected i.e. we have no attached debugger
    if (!isatty(STDERR_FILENO))
    {
        NSArray       *paths              = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString      *documentsDirectory = [paths objectAtIndex:0];
        NSString      *nsLogPath          = [[NSString alloc] initWithString: [documentsDirectory stringByAppendingPathComponent:@"debug.txt"]];
        
        [@"" writeToFile:nsLogPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        id fileHandle = [NSFileHandle fileHandleForWritingAtPath:nsLogPath];
        
        if (!fileHandle)
        {
            _NSLog(@"logToFile - Could not open %@",nsLogPath);
            return NO;
        }
        
        int err = dup2([fileHandle fileDescriptor], STDERR_FILENO);
        if (!err)
        {
            _NSLog(@"logToFile - Could not redirect stderr");
            return NO;
        }
    }
    else
        _NSLog(@"logToFile - Debugger attached");
    return YES;
}

#pragma mark -

@end
