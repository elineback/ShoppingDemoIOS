#import "SDDatabaseUtils.h"

static SDDatabaseUtils *sdDatabaseUtils = nil;

@implementation SDDatabaseUtils

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
+ (id)defaultInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sdDatabaseUtils == nil) {
            sdDatabaseUtils = [[self alloc] init];
        }
    });
    return sdDatabaseUtils;
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
- (id)init
{
    if (self = [super init])
	{
    }
    return self;
}

#pragma mark -
#pragma mark Utility Methods

////////////////////////////////////////////////////////////////////////////////
// PREPARE DATABASE
////////////////////////////////////////////////////////////////////////////////
-(BOOL)prepareDatabase
{
    return NO;
}

////////////////////////////////////////////////////////////////////////////////
// CLEAN DATABASE
// Used prior to a *complete* product import from the server
////////////////////////////////////////////////////////////////////////////////
-(BOOL)cleanDatabase
{
    BOOL result = YES;
    
    // Depends on Product
    _NSLog(@"Deleting ProductPhoto");
    if (result)
        result = result & [[Database sharedDatabaseInstance] executeStatement:@"DELETE FROM ProductPhoto"];

    // Depends on Product
    _NSLog(@"Deleting ProductReview");
    if (result)
        result = result & [[Database sharedDatabaseInstance] executeStatement:@"DELETE FROM ProductReview"];

    // Depends on Product, Cart
    _NSLog(@"Deleting ProductInCart");
    if (result)
        result = result & [[Database sharedDatabaseInstance] executeStatement:@"DELETE FROM ProductInCart"];

    // Depends on nothing
    _NSLog(@"Deleting Cart");
    if (result)
        result = result & [[Database sharedDatabaseInstance] executeStatement:@"DELETE FROM Cart"];

    // Depends on ProductCategory
    _NSLog(@"Deleting Product");
    if (result)
        result = result & [[Database sharedDatabaseInstance] executeStatement:@"DELETE FROM Product"];

    // Depends on nothing
    _NSLog(@"Deleting ProductCategory");
    if (result)
        result = result & [[Database sharedDatabaseInstance] executeStatement:@"DELETE FROM ProductCategory"];

    return result;
}

////////////////////////////////////////////////////////////////////////////////
// CREATE/FIND EMPTY SHOPPING CART FOR ACCOUNT
////////////////////////////////////////////////////////////////////////////////
-(Cart *)createOrFindShoppingCartForAccount:(NSInteger)accountUid
{
    _NSLog(@"Looking for shopping cart for account #%d", accountUid);
    
    NSString *queryCart = [Cart selectStatementWithCriteria:[NSString stringWithFormat:@" account = %d AND cartType = %d ",accountUid,CART_TYPE_BASKET] orderBy:nil];
    NSArray  *arrayCart = [[Database sharedDatabaseInstance] load:[[Database sharedDatabaseInstance] executeQuery:queryCart] into:@"Cart"];
    Cart     *cart      = nil;

    if (arrayCart && [arrayCart count] > 0)
    {
        _NSLog(@"Found existing shopping cart so using that");
        cart = (Cart *)[arrayCart objectAtIndex:0];
    }
    else
    {
        _NSLog(@"Creating new shopping cart");
        cart = [[Cart alloc] init];
        [cart setAccount:[[NSNumber alloc] initWithInteger:accountUid]];
        [cart setCartType:DBINTEGER(CART_TYPE_BASKET)];
        [cart insertRow];
    }

    _NSLog(@"Shopping Cart :\n%@",[cart xml]);
    
    return cart;
}

////////////////////////////////////////////////////////////////////////////////
// CREATE/FIND EMPTY WISHLIST FOR ACCOUNT
////////////////////////////////////////////////////////////////////////////////
-(Cart *)createOrFindWishlistForAccount:(NSInteger)accountUid
{
    NSString *queryCart = [Cart selectStatementWithCriteria:[NSString stringWithFormat:@" account = %d AND cartType = %d ",accountUid,CART_TYPE_WISHLIST] orderBy:nil];
    NSArray  *arrayCart = [[Database sharedDatabaseInstance] load:[[Database sharedDatabaseInstance] executeQuery:queryCart] into:@"Cart"];
    if (!arrayCart && [arrayCart count] > 0)
        return (Cart *)[arrayCart objectAtIndex:0];
    
    Cart *cart = [[Cart alloc] init];
    [cart setAccount:[[NSNumber alloc] initWithInteger:accountUid]];
    [cart setCartType:DBINTEGER(CART_TYPE_WISHLIST)];
    [cart insertRow];

    _NSLog(@"Wishlist :\n%@",[cart xml]);
    
    return cart;
}

////////////////////////////////////////////////////////////////////////////////
// GET SHOPPING CART TOTAL
////////////////////////////////////////////////////////////////////////////////
-(CGFloat)getTotalForShoppingCartForAccount:(NSInteger)accountUid
{
    Cart *cart = [self createOrFindShoppingCartForAccount:accountUid];
    
    NSString *queryProductInCart = [ProductInCart selectStatementWithCriteria:[NSString stringWithFormat:@" cart = %d ",[cart.uid intValue]] orderBy:nil];
    NSArray  *arrayProductInCart = [[Database sharedDatabaseInstance] load:[[Database sharedDatabaseInstance] executeQuery:queryProductInCart] into:@"ProductInCart"];
    
    CGFloat total = 0.0f;
    
    for(ProductInCart *productInCart in arrayProductInCart)
    {
        NSString *queryProduct = [Product selectStatementWithCriteria:[NSString stringWithFormat:@" uid = %d ",[productInCart.product intValue]] orderBy:@"title"];
        NSArray  *arrayProduct = [[Database sharedDatabaseInstance] load:[[Database sharedDatabaseInstance] executeQuery:queryProduct] into:@"Product"];
        
        if (arrayProduct && [arrayProduct count])
        {
            Product *product = (Product *)[arrayProduct objectAtIndex:0];
            total += ( [productInCart.quantity floatValue] * [product.price floatValue] );
        }
    }

    _NSLog(@"Shopping Cart Total : %f", total);
    
    return total;
}

////////////////////////////////////////////////////////////////////////////////
// CREATE NEW ORDER FROM SHOPPING CART
////////////////////////////////////////////////////////////////////////////////
-(Cart *)convertShoppingCartToOrderForAccount:(NSInteger)accountUid withPaymentMethod:(NSInteger)paymentMethod
{
    Cart *cart = [self createOrFindShoppingCartForAccount:accountUid];
    
    if (cart)
    {
        _NSLog(@"Converting cart to order : \n%@", [cart xml]);
        [cart setOrderPlaced:[Database iso8601DateAsString:[NSDate date]]];
        [cart setOrderTotal:[[NSDecimalNumber alloc] initWithFloat:[self getTotalForShoppingCartForAccount:accountUid]]];
        [cart setPaymentMethod:[[NSNumber alloc] initWithInteger:paymentMethod]];
        [cart setCartType:DBINTEGER(CART_TYPE_ORDER)];
        [cart updateRow];
        _NSLog(@"Order : \n%@", [cart xml]);
    }

    return cart;
}

////////////////////////////////////////////////////////////////////////////////
// ADD PRODUCT TO SHOPPING CART
////////////////////////////////////////////////////////////////////////////////
-(BOOL)addProduct:(NSInteger)productUid toShoppingCartWithQuantity:(NSInteger)quantity forAccount:(NSInteger)accountUid
{
    Cart *cart = [self createOrFindShoppingCartForAccount:accountUid];
    
    NSString *queryProductInCart = [ProductInCart selectStatementWithCriteria:[NSString stringWithFormat:@" cart = %d ",[cart.uid intValue]] orderBy:nil];
    NSArray  *arrayProductInCart = [[Database sharedDatabaseInstance] load:[[Database sharedDatabaseInstance] executeQuery:queryProductInCart] into:@"ProductInCart"];
    
    if (arrayProductInCart && [arrayProductInCart count])
    {
        ProductInCart *productInCart = (ProductInCart *)[arrayProductInCart objectAtIndex:0];
        _NSLog(@"Found the product already in the cart :\n %@", [productInCart xml]);
        
        if (quantity == 0)
        {
            [productInCart deleteRow];
        }
        else
        {
            [productInCart setQuantity:[[NSNumber alloc] initWithInteger:quantity]];
            [productInCart updateRow];
        }
    }
    else
    {
        if (quantity > 0)
        {
            _NSLog(@"Adding %d OF product %d to the cart", quantity, productUid);
            ProductInCart *productInCart = [[ProductInCart alloc] init];
            [productInCart setCart:cart.uid];
            [productInCart setProduct:[[NSNumber alloc] initWithInteger:productUid]];
            [productInCart setQuantity:[[NSNumber alloc] initWithInteger:quantity]];
            [productInCart insertRow];
        }
    }

    return YES;
}

////////////////////////////////////////////////////////////////////////////////
// ADD PRODUCT TO WISHLIST
////////////////////////////////////////////////////////////////////////////////
-(BOOL)addProduct:(NSInteger)productUid toWishlistWithQuantity:(NSInteger)quantity forAccount:(NSInteger)accountUid
{
    Cart *cart = [self createOrFindWishlistForAccount:accountUid];
    
    NSString *queryProductInCart = [ProductInCart selectStatementWithCriteria:[NSString stringWithFormat:@" cart = %d ",[cart.uid intValue]] orderBy:nil];
    NSArray  *arrayProductInCart = [[Database sharedDatabaseInstance] load:[[Database sharedDatabaseInstance] executeQuery:queryProductInCart] into:@"ProductInCart"];
    
    if (arrayProductInCart && [arrayProductInCart count])
    {
        ProductInCart *productInCart = (ProductInCart *)[arrayProductInCart objectAtIndex:0];
        [productInCart setQuantity:[[NSNumber alloc] initWithInteger:quantity]];
        [productInCart updateRow];
    }
    else
    {
        ProductInCart *productInCart = [[ProductInCart alloc] init];
        [productInCart setCart:cart.uid];
        [productInCart setProduct:[[NSNumber alloc] initWithInteger:productUid]];
        [productInCart setQuantity:[[NSNumber alloc] initWithInteger:quantity]];
        [productInCart insertRow];
    }
    
    return YES;
}

////////////////////////////////////////////////////////////////////////////////
// ENUMERATE PRODUCT CATRGORIES
////////////////////////////////////////////////////////////////////////////////
-(NSArray *)enumerateProductCategories
{
    NSString *queryProductCategory = [ProductCategory selectStatementWithCriteria:nil orderBy:@"name"];
    NSArray  *arrayProductCategory = [[Database sharedDatabaseInstance] load:[[Database sharedDatabaseInstance] executeQuery:queryProductCategory] into:@"ProductCategory"];
    
    _NSLog(@"enumerateProductCategories : Found %d categories",[arrayProductCategory count]);
    
    return arrayProductCategory;
}

////////////////////////////////////////////////////////////////////////////////
// ENUMERATE PRODUCTS BY CRITERIA
////////////////////////////////////////////////////////////////////////////////
-(NSArray *)enumerateProductsForCriteria:(NSString *)criteria
{
    NSString *queryProduct = [Product selectStatementWithCriteria:criteria orderBy:@"title"];
    NSArray  *arrayProduct = [[Database sharedDatabaseInstance] load:[[Database sharedDatabaseInstance] executeQuery:queryProduct] into:@"Product"];
    
    return arrayProduct;
}

////////////////////////////////////////////////////////////////////////////////
// ENUMERATE PRODUCTS BY CATEGORY
////////////////////////////////////////////////////////////////////////////////
-(NSArray *)enumerateProductsForCategory:(NSInteger)categoryUid
{
    NSString *categoryCriteria = nil;
    if (categoryUid >= 0)
        categoryCriteria = [NSString stringWithFormat:@" category = %d ",categoryUid];

    NSString *queryProduct = [Product selectStatementWithCriteria:categoryCriteria orderBy:@"title"];
    _NSLog(@"Product SQL = %@",queryProduct);

    NSArray  *arrayProduct = [[Database sharedDatabaseInstance] load:[[Database sharedDatabaseInstance] executeQuery:queryProduct] into:@"Product"];
    
    return arrayProduct;
}

////////////////////////////////////////////////////////////////////////////////
// ENUMERATE PRODUCTS BY FEATURED STATUS
////////////////////////////////////////////////////////////////////////////////
-(NSArray *)enumerateFeaturedProducts
{
    NSString *queryProduct = [Product selectStatementWithCriteria:@" featured = 1 " orderBy:@"title"];
    NSArray  *arrayProduct = [[Database sharedDatabaseInstance] load:[[Database sharedDatabaseInstance] executeQuery:queryProduct] into:@"Product"];
    
    return arrayProduct;
}

////////////////////////////////////////////////////////////////////////////////
// ENUMERATE PRODUCTS BY PROMOTED STATUS
////////////////////////////////////////////////////////////////////////////////
-(NSArray *)enumeratePromotedProducts
{
    NSString *queryProduct = [Product selectStatementWithCriteria:@" promoted = 1 " orderBy:@"title"];
    NSArray  *arrayProduct = [[Database sharedDatabaseInstance] load:[[Database sharedDatabaseInstance] executeQuery:queryProduct] into:@"Product"];
    
    return arrayProduct;
}

////////////////////////////////////////////////////////////////////////////////
// ENUMERATE PRODUCTS IN SHOPPING CART
////////////////////////////////////////////////////////////////////////////////
-(NSArray *)enumerateProductsInShoppingCartForAccount:(NSInteger)accountUid
{
    Cart *cart = [self createOrFindShoppingCartForAccount:accountUid];
    
    NSString *queryProductInCart = [ProductInCart selectStatementWithCriteria:[NSString stringWithFormat:@" cart = %d ",[cart.uid intValue]] orderBy:nil];
    
    _NSLog(@"Shopping Cart SQL : %@",queryProductInCart);
    
    NSArray  *arrayProductInCart = [[Database sharedDatabaseInstance] load:[[Database sharedDatabaseInstance] executeQuery:queryProductInCart] into:@"ProductInCart"];
    NSMutableArray *arrayProducts = [[NSMutableArray alloc] init];
    
    for(ProductInCart *productInCart in arrayProductInCart)
    {
        NSString *queryProduct = [Product selectStatementWithCriteria:[NSString stringWithFormat:@" uid = %d ",[productInCart.product intValue]] orderBy:@"title"];
        
        _NSLog(@"Shopping Cart Product SQL : %@",queryProduct);

        NSArray  *arrayProduct = [[Database sharedDatabaseInstance] load:[[Database sharedDatabaseInstance] executeQuery:queryProduct] into:@"Product"];
        [arrayProducts addObjectsFromArray:arrayProduct];
    }

    return arrayProducts;
}

-(NSArray *)enumerateProductInCartForAccount:(NSInteger)accountUid
{
    Cart *cart = [self createOrFindShoppingCartForAccount:accountUid];
    NSString *queryProductInCart = [ProductInCart selectStatementWithCriteria:[NSString stringWithFormat:@" cart = %d ",[cart.uid intValue]] orderBy:nil];
    NSArray  *arrayProductInCart = [[Database sharedDatabaseInstance] load:[[Database sharedDatabaseInstance] executeQuery:queryProductInCart] into:@"ProductInCart"];
    return arrayProductInCart;
}

-(NSArray *)enumerateProductInCartForOrder:(Cart *)cart
{
    NSString *queryProductInCart = [ProductInCart selectStatementWithCriteria:[NSString stringWithFormat:@" cart = %d ",[cart.uid intValue]] orderBy:nil];
    NSArray  *arrayProductInCart = [[Database sharedDatabaseInstance] load:[[Database sharedDatabaseInstance] executeQuery:queryProductInCart] into:@"ProductInCart"];
    return arrayProductInCart;
}

////////////////////////////////////////////////////////////////////////////////
// ENUMERATE PRODUCTS IN WISHLIST
////////////////////////////////////////////////////////////////////////////////
-(NSArray *)enumerateProductsInWishlistForAccount:(NSInteger)accountUid
{
    Cart *cart = [self createOrFindWishlistForAccount:accountUid];
    
    NSString *queryProductInCart = [ProductInCart selectStatementWithCriteria:[NSString stringWithFormat:@" cart = %d ",[cart.uid intValue]] orderBy:nil];
    NSArray  *arrayProductInCart = [[Database sharedDatabaseInstance] load:[[Database sharedDatabaseInstance] executeQuery:queryProductInCart] into:@"ProductInCart"];
    NSMutableArray *arrayProducts = [[NSMutableArray alloc] init];
    
    for(ProductInCart *productInCart in arrayProductInCart)
    {
        NSString *queryProduct = [Product selectStatementWithCriteria:[NSString stringWithFormat:@" uid = %d ",[productInCart.product intValue]] orderBy:@"title"];
        NSArray  *arrayProduct = [[Database sharedDatabaseInstance] load:[[Database sharedDatabaseInstance] executeQuery:queryProduct] into:@"Product"];
        [arrayProducts addObjectsFromArray:arrayProduct];
    }
    
    return arrayProductInCart;
}

@end
