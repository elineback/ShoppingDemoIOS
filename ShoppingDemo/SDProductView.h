#import <UIKit/UIKit.h>

#define SD_PRODUCT_VIEW_WIDTH  102.0
#define SD_PRODUCT_VIEW_HEIGHT 165.0

@interface SDProductView : UIButton
{
    NSNumber                 *_productUID;
    UIImageView              *_productThumbnail;
    UILabel                  *_productManufacturer;
    UILabel                  *_productName;
    UILabel                  *_productPrice;
}

@property (strong,nonatomic)          NSNumber                 *productUID;
@property (strong,nonatomic) IBOutlet UIImageView              *productThumbnail;
@property (strong,nonatomic) IBOutlet UILabel                  *productManufacturer;
@property (strong,nonatomic) IBOutlet UILabel                  *productName;
@property (strong,nonatomic) IBOutlet UILabel                  *productPrice;

@end
