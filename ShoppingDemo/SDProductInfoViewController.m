#import "SDProductInfoViewController.h"

#import "Debug.h"

#import "SDAppDelegate.h"
#import "SDCartViewController.h"

#import "SDTagManSDKAPI.h"

@implementation SDProductInfoViewController

@synthesize uid                  = _uid;

@synthesize imageViewProduct     = _imageViewProduct;
@synthesize labelName            = _labelName;
@synthesize labelPrice           = _labelPrice;

@synthesize buttonAddToCart      = _buttonAddToCart;
@synthesize buttonPhotoGallery   = _buttonPhotoGallery;
@synthesize buttonAddToWishList  = _buttonAddToWishList;

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

-(void)viewDidAppear:(BOOL)animated
{
    Product *product = (Product *)[Product selectRow:[_uid integerValue]];
    [SDTagManSDKAPI tagManViewProduct:product];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark IBActions

-(IBAction)buttonAddToCartPressed:(id)sender
{
    _NSLog(@"Adding to cart");

    SDAppDelegate *app = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];

    if (app.account)
    {
        Cart *cart = [[SDDatabaseUtils defaultInstance] createOrFindShoppingCartForAccount:[app.account.uid integerValue]];
        NSString *criteriaProductInCart = [NSString stringWithFormat:@" product = %d AND cart = %d ",[_uid integerValue], [cart.uid integerValue]];
        NSString *queryProductInCart = [ProductInCart selectStatementWithCriteria:criteriaProductInCart orderBy:nil];
        NSArray  *productsInCart     = [[Database sharedDatabaseInstance] load:[[Database sharedDatabaseInstance] executeQuery:queryProductInCart] into:@"ProductInCart"];
        ProductInCart *productInCart = (ProductInCart *)[productsInCart objectAtIndex:0];
        
        if (productInCart)
        {
            _NSLog(@"Product already in cart :\n%@",[productInCart xml]);
            
            int quantity  = [productInCart.quantity intValue] + 1;
            [productInCart setQuantity:[NSNumber numberWithInt:quantity]];
            [productInCart updateRow];
            
            _NSLog(@"Product entry updated to :\n%@",[productInCart xml]);
        }
        else
        {
            _NSLog(@"Product new to cart");
            
            productInCart = [[ProductInCart alloc] init];
            [productInCart setQuantity:[NSNumber numberWithInt:1]];
            [productInCart setProduct:_uid];
            [productInCart setCart:cart.uid];
            
            _NSLog(@"Product entry created as :\n%@",[productInCart xml]);
            
            [productInCart insertRow];
        }

        SDCartViewController *cartViewController = [[SDCartViewController alloc] initWithNibName:@"SDCartViewController" bundle:nil];
        [app pushViewController:cartViewController];
    }
    else
    {
        [self msg:@"You must be signed in to add a product to your shopping cart."];
    }

    _NSLog(@"Done");
}

-(IBAction)buttonAddToWishlistPressed:(id)sender
{
    _NSLog(@"Wishlist not implemented");
    [self notImplemented:sender];
}

@end
