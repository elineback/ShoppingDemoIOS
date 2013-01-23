#import <UIKit/UIKit.h>

#import "Database.h"
#import "DatabaseConstants.h"

#import "Account.h"
#import "ProductCategory.h"

@class SDBaseViewController;

@interface SDAppDelegate : UIResponder <UIApplicationDelegate>
{
    NSMutableArray  *_arrayOfViewControllers;
    Account         *_account;
    ProductCategory *_productCategory;
}

@property (strong, nonatomic) UIWindow             *window;
@property (strong, nonatomic) SDBaseViewController *viewController;

@property (strong, nonatomic) Account              *account;
@property (strong, nonatomic) ProductCategory      *productCategory;

-(void) switchToBrowseViewController;
-(void) switchToCartViewController;
-(void) switchToCheckoutViewController;
-(void) switchToWishListViewController;
-(void) switchToMoreViewController;
-(void) switchToMenuViewController;

-(BOOL) logToFile;

-(void) pushViewController:(UIViewController *)vc;
-(void) popViewController;

@end
