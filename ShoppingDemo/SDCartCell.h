#import <UIKit/UIKit.h>

@interface SDCartCell : UITableViewCell
{
    UIImageView *_imageViewThumb;
    UILabel     *_labelManufacturer;
    UILabel     *_labelName;
    UILabel     *_labelReference;
    UILabel     *_labelPrice;
    UITextField *_textQuantity;
    UIButton    *_buttonDelete;
}

@property (strong,nonatomic) IBOutlet UIImageView *imageViewThumb;
@property (strong,nonatomic) IBOutlet UILabel     *labelManufacturer;
@property (strong,nonatomic) IBOutlet UILabel     *labelName;
@property (strong,nonatomic) IBOutlet UILabel     *labelReference;
@property (strong,nonatomic) IBOutlet UILabel     *labelPrice;
@property (strong,nonatomic) IBOutlet UITextField *textQuantity;
@property (strong,nonatomic) IBOutlet UIButton    *buttonDelete;

@end
