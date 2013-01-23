#import <Foundation/Foundation.h>

#import "Database.h"

#import "Account.h"
#import "Address.h"
#import "Cart.h"
#import "CartType.h"
#import "DatabaseConstants.h"
#import "Manufacturer.h"
#import "PaymentMethod.h"
#import "PaymentMethodType.h"
#import "Product.h"
#import "ProductCategory.h"
#import "ProductInCart.h"
#import "ProductPhoto.h"
#import "ProductReview.h"

@interface SDDatabaseUtils : NSObject
{
}

+ (id)defaultInstance;

-(BOOL)prepareDatabase;
-(BOOL)cleanDatabase;

// SHOPPING CART

-(Cart *)createOrFindShoppingCartForAccount:(NSInteger)accountUid;
-(BOOL)addProduct:(NSInteger)productUid toShoppingCartWithQuantity:(NSInteger)quantity forAccount:(NSInteger)accountUid;
-(NSArray *)enumerateProductsInShoppingCartForAccount:(NSInteger)accountUid;
-(NSArray *)enumerateProductInCartForAccount:(NSInteger)accountUid;
-(NSArray *)enumerateProductInCartForOrder:(Cart *)cart;
-(CGFloat)getTotalForShoppingCartForAccount:(NSInteger)accountUid;

// WISHLIST

-(Cart *)createOrFindWishlistForAccount:(NSInteger)accountUid;
-(BOOL)addProduct:(NSInteger)productUid toWishlistWithQuantity:(NSInteger)quantity forAccount:(NSInteger)accountUid;
-(NSArray *)enumerateProductsInWishlistForAccount:(NSInteger)accountUid;

// ORDER

-(Cart *)convertShoppingCartToOrderForAccount:(NSInteger)accountUid withPaymentMethod:(NSInteger)paymentMethod;

// ENUMERATIONS

-(NSArray *)enumerateProductCategories;
-(NSArray *)enumerateProductsForCriteria:(NSString *)criteria;
-(NSArray *)enumerateProductsForCategory:(NSInteger)categoryUid;
-(NSArray *)enumerateFeaturedProducts;
-(NSArray *)enumeratePromotedProducts;

@end
