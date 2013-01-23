#import <UIKit/UIKit.h>

#import "SDBaseViewController.h"

@interface SDProductInfoViewController : SDBaseViewController
{
    NSNumber    *_uid;
    
    UIImageView *_imageViewProduct;
    UILabel     *_labelName;
    UILabel     *_labelPrice;
    
    UIButton    *_buttonAddToCart;
    UIButton    *_buttonPhotoGallery;
    UIButton    *_buttonAddToWishList;
}

@property (strong,nonatomic)          NSNumber    *uid;

@property (strong,nonatomic) IBOutlet UIImageView *imageViewProduct;
@property (strong,nonatomic) IBOutlet UILabel     *labelName;
@property (strong,nonatomic) IBOutlet UILabel     *labelPrice;

@property (strong,nonatomic) IBOutlet UIButton    *buttonAddToCart;
@property (strong,nonatomic) IBOutlet UIButton    *buttonPhotoGallery;
@property (strong,nonatomic) IBOutlet UIButton    *buttonAddToWishList;

-(IBAction)buttonAddToCartPressed:(id)sender;
-(IBAction)buttonAddToWishlistPressed:(id)sender;

@end
