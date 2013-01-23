#import "SDMenuViewController.h"

#import "SDAppDelegate.h"
#import "SDSignInViewController.h"
#import "SDBrowseViewController.h"

#import "SDTagManSDKAPI.h"

@implementation SDMenuViewController

@synthesize cell      = _cell;
@synthesize menuItems = _menuItems;
@synthesize tableView = _tableView;

#pragma mark -
#pragma mark View Life Cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _menuItems              = [[NSArray alloc] initWithArray:[[SDDatabaseUtils defaultInstance] enumerateProductCategories]];
    _selectedIndex          =  0;
    _selectedCategory       = -1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SDAppDelegate *app      = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
    BOOL           signedIn = (BOOL)(app.account != nil);
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    _selectedIndex = [indexPath row];

    if (_selectedIndex == 0)
    {
        _selectedCategory = -1;
        _NSLog(@"You pressed SIGN IN/OUT");
        if (signedIn)
        {
            [app setAccount:nil];
        }
        else
        {
            SDSignInViewController *signInViewController = [[SDSignInViewController alloc] initWithNibName:@"SDSignInViewController" bundle:nil];
            [app pushViewController:signInViewController];
        }
        // Force a repaint of visible cells - not efficient, but we've only got a small menu
        [tableView reloadData];
        return;
    }
    else if (_selectedIndex == 1)
    {
        _NSLog(@"You pressed ALL CATEGORIES");
        _selectedCategory = -1;
    }
    else
    {
        ProductCategory *productCategory = (ProductCategory *)[_menuItems objectAtIndex:_selectedIndex - 2];
        _selectedCategory = [productCategory.uid intValue];
        _NSLog(@"You pressed CATEGORY '%@', UID %d",productCategory.name,_selectedCategory);
        
        [SDTagManSDKAPI tagManViewCategory:productCategory];
    }

    SDBrowseViewController *browseViewController = [[SDBrowseViewController alloc] initWithNibName:@"SDBrowseViewController" bundle:nil];
    [app pushViewController:browseViewController];
    [browseViewController setProductCategory:_selectedCategory];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];

    _NSLog(@"tableView:cellForRowAtIndexPath:%d",row);
    
    SDAppDelegate *app      = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
    BOOL           signedIn = (BOOL)(app.account != nil);

    static NSString *TableCell = @"SDTableCell";
    SDTableCell *cell = [tableView dequeueReusableCellWithIdentifier:TableCell];
    if (cell == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:@"SDTableCell" owner:self options:nil];
        cell = [self cell];
        [self setCell:cell];
    }

    if (row == _selectedIndex)
    {
        if (row == 0)
            [cell.background setImage:[UIImage imageNamed:@"mainMenuSigninCellTouched.png"]];
        else
            [cell.background setImage:[UIImage imageNamed:@"mainMenuCellTouched.png"]];
    }
    else
    {
        if (row == 0)
            [cell.background setImage:[UIImage imageNamed:@"mainMenuSigninCell.png"]];
        else
            [cell.background setImage:[UIImage imageNamed:@"mainMenuCell.png"]];
    }
    
    if (row == 0)
    {
        [cell.label setText:(signedIn ? @"Sign Out" : @"Sign In")];
    }
    else if (row == 1)
    {
        [cell.label setText:@"All Categories"];
    }
    else
    {
        ProductCategory *productCategory = (ProductCategory *)[_menuItems objectAtIndex:row - 2];
        
        _NSLog(@"Product Category %d %@",(row - 2),productCategory.name);
        
        [cell.label setText:productCategory.name];
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_menuItems count] + 2;
}

#pragma mark -

@end
