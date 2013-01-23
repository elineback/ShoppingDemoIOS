#import "SDTagManSDKAPI.h"

#import "SDAppDelegate.h"

@implementation SDTagManSDKAPI

////////////////////////////////////////////////////////////////////////////////
// Register a sign in event with TagMan (though this does not actually exist as
// a page_type in the specification, so we're using a page_type of "user").
////////////////////////////////////////////////////////////////////////////////
+(void)tagManSignIn:(Account *)account
{
    NSInteger page   = TAGMAN_SITEID_DEFAULT;
    NSString *client = TAGMAN_CLIENT_ID;
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];

    [parameters setObject:@"user" forKey:@"page_type"];
    [parameters setObject:@""     forKey:@"customer_postcode"];
    [parameters setObject:@""     forKey:@"customer_city"];
    [parameters setObject:@""     forKey:@"customer_country"];
    [parameters setObject:account.emailAddress forKey:@"customer_email"];
    [parameters setObject:account.forename forKey:@"customer_firstname"];
    [parameters setObject:account.surname forKey:@"customer_lastname"];
    [parameters setObject:[NSString stringWithFormat:@"%d",[account.serverUID intValue]] forKey:@"customer_id"];
    [parameters setObject:@"GBP" forKey:@"currency_code"];
    [parameters setObject:@"en" forKey:@"site_language"];
    [parameters setObject:@"United Kingdom" forKey:@"site_country_name"];
    [parameters setObject:@"UK" forKey:@"site_country_code"];
    [parameters setObject:@"" forKey:@"page_url"];

    TMContainer *container = [[TMSdkManager sharedSdkManager] setupContainerForPage:page withParams:parameters andClient:client onStaging:YES];
    [container run];
}

////////////////////////////////////////////////////////////////////////////////
// Post the current shopping cart to TagMan
////////////////////////////////////////////////////////////////////////////////
+(void)tagManPostCart:(Cart *)cart
{
    NSInteger page   = TAGMAN_SITEID_CART;
    NSString *client = TAGMAN_CLIENT_ID;
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    // From the specification email
    //
    //checkout/cart
    
    //window.tmParam.page_type = 'cart';
    //window.tmParam.product_id_list = product_id_list.join( '|' );
    //window.tmParam.product_name_list = product_name_list.join( '|' );
    //window.tmParam.product_price_list = product_price_list.join( '|' );
    //window.tmParam.product_quantity_list = product_quantity_list.join( '|'

    // Each list is delimited by pipe '|' characters.
    // So here we just trawl the list of products in this cart and generate the lists.
    
    NSMutableString *product_id_list       = [[NSMutableString alloc] init];
    NSMutableString *product_name_list     = [[NSMutableString alloc] init];
    NSMutableString *product_price_list    = [[NSMutableString alloc] init];
    NSMutableString *product_quantity_list = [[NSMutableString alloc] init];
    
    NSString *delimiter = @"";
    NSArray *productsInOrder = [[SDDatabaseUtils defaultInstance] enumerateProductInCartForOrder:cart];
    for (ProductInCart *cartItem in productsInOrder)
    {
        Product *product = (Product *)[Product selectRow:[cartItem.product integerValue]];
        [product_id_list        appendFormat:@"%@%@",delimiter,product.sku];
        [product_name_list      appendFormat:@"%@%@",delimiter,product.title];
        [product_price_list     appendFormat:@"%@%@",delimiter,[NSString stringWithFormat:@"%2.2f",[product.price floatValue]]];
        [product_quantity_list  appendFormat:@"%@%d",delimiter,[cartItem.quantity intValue]];
        delimiter = @"|";
    }
    
    _NSLog(@"product_id_list       : %@",product_id_list);
    _NSLog(@"product_name_list     : %@",product_name_list);
    _NSLog(@"product_price_list    : %@",product_price_list);
    _NSLog(@"product_quantity_list : %@",product_quantity_list);
    
    [parameters setObject:@"cart"            forKey:@"page_type"];

    SDAppDelegate *app = (SDAppDelegate *)[UIApplication sharedApplication].delegate;
    if (app.account)
    {
        [parameters setObject:@""     forKey:@"customer_postcode"];
        [parameters setObject:@""     forKey:@"customer_city"];
        [parameters setObject:@""     forKey:@"customer_country"];
        [parameters setObject:app.account.emailAddress forKey:@"customer_email"];
        [parameters setObject:app.account.forename forKey:@"customer_firstname"];
        [parameters setObject:app.account.surname forKey:@"customer_lastname"];
        [parameters setObject:[NSString stringWithFormat:@"%d",[app.account.serverUID intValue]] forKey:@"customer_id"];
        [parameters setObject:[NSString stringWithFormat:@"%d",[app.account.serverUID intValue]] forKey:@"tmyourid"];
        [parameters setObject:@"GBP" forKey:@"currency_code"];
        [parameters setObject:@"en" forKey:@"site_language"];
        [parameters setObject:@"United Kingdom" forKey:@"site_country_name"];
        [parameters setObject:@"UK" forKey:@"site_country_code"];
        [parameters setObject:@"" forKey:@"page_url"];
    }

    [parameters setObject:product_id_list       forKey:@"product_id_list"];
    [parameters setObject:product_name_list     forKey:@"product_name_list"];
    [parameters setObject:product_price_list    forKey:@"product_price_list"];
    [parameters setObject:product_quantity_list forKey:@"product_quantity_list"];
    
    TMContainer *container = [[TMSdkManager sharedSdkManager] setupContainerForPage:page withParams:parameters andClient:client onStaging:YES];
    [container run];
}

////////////////////////////////////////////////////////////////////////////////
// Post an order to TagMan
////////////////////////////////////////////////////////////////////////////////
+(void)tagManPostOrder:(Cart *)order
{
    NSInteger page   = TAGMAN_SITEID_CONFIRM;
    NSString *client = TAGMAN_CLIENT_ID;
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    // From the specification email
    //
    // checkout/confirm
    //
    // window.tmParam.page_type = 'confirm';
    // window.tmParam.product_id_list = product_id_list.join( '|' );
    // window.tmParam.product_name_list = product_name_list.join( '|' );
    // window.tmParam.product_price_list = product_price_list.join( '|' );
    // window.tmParam.product_quantity_list = product_quantity_list.join( '|'
    
    // Each list is delimited by pipe '|' characters.
    // So here we just trawl the list of products in this cart and generate the lists.
    
    NSMutableString *product_id_list       = [[NSMutableString alloc] init];
    NSMutableString *product_name_list     = [[NSMutableString alloc] init];
    NSMutableString *product_price_list    = [[NSMutableString alloc] init];
    NSMutableString *product_quantity_list = [[NSMutableString alloc] init];
    
    NSString *delimiter = @"";
    NSArray *productsInOrder = [[SDDatabaseUtils defaultInstance] enumerateProductInCartForOrder:order];
    for (ProductInCart *orderLine in productsInOrder)
    {
        Product *product = (Product *)[Product selectRow:[orderLine.product integerValue]];
        [product_id_list        appendFormat:@"%@%@",delimiter,product.sku];
        [product_name_list      appendFormat:@"%@%@",delimiter,product.title];
        [product_price_list     appendFormat:@"%@%@",delimiter,[NSString stringWithFormat:@"%2.2f",[product.price floatValue]]];
        [product_quantity_list  appendFormat:@"%@%d",delimiter,[orderLine.quantity intValue]];
        delimiter = @"|";
    }
    
    _NSLog(@"product_id_list       : %@",product_id_list);
    _NSLog(@"product_name_list     : %@",product_name_list);
    _NSLog(@"product_price_list    : %@",product_price_list);
    _NSLog(@"product_quantity_list : %@",product_quantity_list);
    
    [parameters setObject:@"confirm"            forKey:@"page_type"];
    
    SDAppDelegate *app = (SDAppDelegate *)[UIApplication sharedApplication].delegate;
    if (app.account)
    {
        [parameters setObject:@""     forKey:@"customer_postcode"];
        [parameters setObject:@""     forKey:@"customer_city"];
        [parameters setObject:@""     forKey:@"customer_country"];
        [parameters setObject:app.account.emailAddress forKey:@"customer_email"];
        [parameters setObject:app.account.forename forKey:@"customer_firstname"];
        [parameters setObject:app.account.surname forKey:@"customer_lastname"];
        [parameters setObject:[NSString stringWithFormat:@"%d",[app.account.serverUID intValue]] forKey:@"customer_id"];
        [parameters setObject:@"GBP" forKey:@"currency_code"];
        [parameters setObject:@"en" forKey:@"site_language"];
        [parameters setObject:@"United Kingdom" forKey:@"site_country_name"];
        [parameters setObject:@"UK" forKey:@"site_country_code"];
        [parameters setObject:@"" forKey:@"page_url"];
    }
    
    [parameters setObject:product_id_list       forKey:@"product_id_list"];
    [parameters setObject:product_name_list     forKey:@"product_name_list"];
    [parameters setObject:product_price_list    forKey:@"product_price_list"];
    [parameters setObject:product_quantity_list forKey:@"product_quantity_list"];
    
    TMContainer *container = [[TMSdkManager sharedSdkManager] setupContainerForPage:page withParams:parameters andClient:client onStaging:YES];
    [container run];
}

////////////////////////////////////////////////////////////////////////////////
// Record a view of a category and send to TagMan
////////////////////////////////////////////////////////////////////////////////
+(void)tagManViewCategory:(ProductCategory *)productCategory
{
    NSInteger page   = TAGMAN_SITEID_CATEGORY;
    NSString *client = TAGMAN_CLIENT_ID;
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    // From the specification email
    
    [parameters setObject:@"category"            forKey:@"page_type"];
    
    SDAppDelegate *app = (SDAppDelegate *)[UIApplication sharedApplication].delegate;
    if (app.account)
    {
        [parameters setObject:@""     forKey:@"customer_postcode"];
        [parameters setObject:@""     forKey:@"customer_city"];
        [parameters setObject:@""     forKey:@"customer_country"];
        [parameters setObject:app.account.emailAddress forKey:@"customer_email"];
        [parameters setObject:app.account.forename forKey:@"customer_firstname"];
        [parameters setObject:app.account.surname forKey:@"customer_lastname"];
        [parameters setObject:[NSString stringWithFormat:@"%d",[app.account.serverUID intValue]] forKey:@"customer_id"];
        [parameters setObject:@"GBP" forKey:@"currency_code"];
        [parameters setObject:@"en" forKey:@"site_language"];
        [parameters setObject:@"United Kingdom" forKey:@"site_country_name"];
        [parameters setObject:@"UK" forKey:@"site_country_code"];
        [parameters setObject:@"" forKey:@"page_url"];
    }
    
    [parameters setObject:productCategory.name forKey:@"product_category"];
    
    TMContainer *container = [[TMSdkManager sharedSdkManager] setupContainerForPage:page withParams:parameters andClient:client onStaging:YES];
    [container run];
}

////////////////////////////////////////////////////////////////////////////////
// Record a view of a product and send to TagMan
////////////////////////////////////////////////////////////////////////////////
+(void)tagManViewProduct:(Product *)product
{
    NSInteger page   = TAGMAN_SITEID_PRODUCT;
    NSString *client = TAGMAN_CLIENT_ID;

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    // From the specification email

    [parameters setObject:@"product"            forKey:@"page_type"];
    
    SDAppDelegate *app = (SDAppDelegate *)[UIApplication sharedApplication].delegate;
    if (app.account)
    {
        [parameters setObject:@""     forKey:@"customer_postcode"];
        [parameters setObject:@""     forKey:@"customer_city"];
        [parameters setObject:@""     forKey:@"customer_country"];
        [parameters setObject:app.account.emailAddress forKey:@"customer_email"];
        [parameters setObject:app.account.forename forKey:@"customer_firstname"];
        [parameters setObject:app.account.surname forKey:@"customer_lastname"];
        [parameters setObject:[NSString stringWithFormat:@"%d",[app.account.serverUID intValue]] forKey:@"customer_id"];
        [parameters setObject:@"GBP" forKey:@"currency_code"];
        [parameters setObject:@"en" forKey:@"site_language"];
        [parameters setObject:@"United Kingdom" forKey:@"site_country_name"];
        [parameters setObject:@"UK" forKey:@"site_country_code"];
        [parameters setObject:@"" forKey:@"page_url"];
    }

    [parameters setObject:(product.sku ? product.sku : @"")    forKey:@"product_sku"];
    [parameters setObject:(product.mpn ? product.mpn : @"")    forKey:@"product_id"];
    [parameters setObject:product.title   forKey:@"product_name"];
    [parameters setObject:@""     forKey:@"product_price"];
    [parameters setObject:[[Database sharedDatabaseInstance] executeStringQuery:
                           [NSString stringWithFormat:@"SELECT title FROM Manufacturer WHERE uid = %d",[product.manufacturer intValue]]
                                                                         column:@"title"] forKey:@"product_brand"];
    [parameters setObject:[[Database sharedDatabaseInstance] executeStringQuery:
                           [NSString stringWithFormat:@"SELECT name FROM ProductCategory WHERE uid = %d",[product.category intValue]]
                                                                         column:@"name"] forKey:@"product_category"];

    TMContainer *container = [[TMSdkManager sharedSdkManager] setupContainerForPage:page withParams:parameters andClient:client onStaging:YES];
    [container run];
}

////////////////////////////////////////////////////////////////////////////////
// Post Order to Trade Doubler
// - NOT STRICTLY PART OF THE TAGMAN SDK BUT ADDED HERE FOR CONVENIENCE
////////////////////////////////////////////////////////////////////////////////
+(void)tradeDoublerPostOrder:(Cart *)order
{
    // Values from the test application, should really be configurable somewhere.
    NSString *organization = @"1710346";
    NSString *event        = @"260143";
    NSString *secretCode   = @"23123";

    // Currency should really be determined from the products and the default for the account, but here is forced to USD, same as the demo products
    NSString *currency     = @"USD";

    // Order number is "aaaaaacccccc" where aaaaaa is account number with leading zeroes and cccccc is local cart number with leading zeroes
    NSString *orderNumber  = [NSString stringWithFormat:@"%06d%06d",[order.account integerValue],[order.uid integerValue]];
    
    CGFloat   total        = [order.orderTotal floatValue];
    NSString *orderValue   = [NSString stringWithFormat:@"%.2f",total];
    
    int timeout            = 5; // in seconds
    
    [MobileSDK postDownloadTrackback:organization
                           withEvent:event
                     withOrderNumber:orderNumber
                      withSecretCode:secretCode
                         withTimeout:timeout
                        withCurrency:currency
                      withOrderValue:orderValue];
}

@end
