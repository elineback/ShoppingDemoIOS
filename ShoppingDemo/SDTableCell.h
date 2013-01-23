#import <UIKit/UIKit.h>

@interface SDTableCell : UITableViewCell
{
    UIImageView *_background;
    UILabel     *_label;
}

@property (strong,nonatomic) IBOutlet UIImageView *background;
@property (strong,nonatomic) IBOutlet UILabel     *label;

@end
