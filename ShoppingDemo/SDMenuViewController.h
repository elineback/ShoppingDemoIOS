#import <UIKit/UIKit.h>

#import "SDBaseViewController.h"
#import "SDTableCell.h"

@interface SDMenuViewController : SDBaseViewController <UITableViewDataSource,UITableViewDelegate>
{
    SDTableCell    *_cell;
    NSArray        *_menuItems;
    
    UITableView    *_tableView;
    int             _selectedIndex;
    int             _selectedCategory;
}

@property (strong,nonatomic) IBOutlet SDTableCell    *cell;
@property (strong,nonatomic) IBOutlet NSArray        *menuItems;

@property (strong,nonatomic) IBOutlet UITableView    *tableView;

@end
