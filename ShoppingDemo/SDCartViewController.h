#import <UIKit/UIKit.h>

#import "SDBaseViewController.h"

#import "SDDatabaseUtils.h"
#import "SDCartCell.h"

@interface SDCartViewController : SDBaseViewController <UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_products;

    SDCartCell     *_cell;
    UITableView    *_tableViewCart;
    UILabel        *_labelItems;
    UILabel        *_labelTotal;
}

@property (strong,nonatomic) IBOutlet SDCartCell  *cell;
@property (strong,nonatomic) IBOutlet UITableView *tableViewCart;
@property (strong,nonatomic) IBOutlet UILabel     *labelItems;
@property (strong,nonatomic) IBOutlet UILabel     *labelTotal;

-(IBAction)buttonDeletePressed:(id)sender;
-(void)refresh;

@end
