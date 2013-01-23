#import "DatabaseObject.h"

@interface ProductInCart : DatabaseObject
{

	@private
		NSNumber *_cart;
		NSNumber *_product;
		NSNumber *_quantity;

}

@property (strong, nonatomic, getter=cart) NSNumber *cart;
@property (strong, nonatomic, getter=product) NSNumber *product;
@property (strong, nonatomic, getter=quantity) NSNumber *quantity;

@end
