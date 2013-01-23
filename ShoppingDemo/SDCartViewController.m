#import "SDCartViewController.h"

#import "Debug.h"
#import "SDAppDelegate.h"

#import "SDTagManSDKAPI.h"

@implementation SDCartViewController

@synthesize cell          = _cell;
@synthesize tableViewCart = _tableViewCart;
@synthesize labelItems    = _labelItems;
@synthesize labelTotal    = _labelTotal;

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
    _products   = [[NSMutableArray alloc] init];
}

-(void)viewDidAppear:(BOOL)animated
{
    [_products   removeAllObjects];

    SDAppDelegate *app = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
    _products          = [NSMutableArray arrayWithArray:[[SDDatabaseUtils defaultInstance] enumerateProductInCartForAccount:[[app.account uid] intValue]]];

    _NSLog(@"Post cart to TagMan");
    Cart *cart = [[SDDatabaseUtils defaultInstance] createOrFindShoppingCartForAccount:[[app.account uid] intValue]];
    [SDTagManSDKAPI tagManPostCart:cart];

    _NSLog(@"Cart contains %d items",[_products count]);

    [_tableViewCart reloadData];
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark IBActions

-(IBAction)buttonDeletePressed:(id)sender
{
    NSObject *obj = [sender superview];
    
    if ([obj isKindOfClass:[SDCartCell class]])
    {
        SDCartCell  *cartCell  = (SDCartCell *)[sender superview];
        NSIndexPath *indexPath = [_tableViewCart indexPathForCell:cartCell];
        NSInteger    row       = [indexPath row];
        
        ProductInCart *productInCart = (ProductInCart *)[_products objectAtIndex:row];
        NSInteger      quantity      = [productInCart.quantity integerValue];
        
        if ( quantity > 1)
        {
            [productInCart setQuantity:[NSNumber numberWithInteger:(quantity - 1)]];
            [productInCart updateRow];
        }
        else
        {
            [productInCart deleteRow];
            [_products removeObjectAtIndex:row];
        }

        [_tableViewCart reloadData];
        [self refresh];
    }
    else
        _NSLog(@"Delete button superview is not of type SDCartCell");
}

#pragma mark -
#pragma mark Refresh totals

-(void)refresh
{
    int lines             = [_products count];
    NSString *itemsString = [NSString stringWithFormat:@"%d item%@",lines,(lines == 1 ? @"" : @"s")];

    CGFloat total = 0.0f;

    for(ProductInCart *productInCart in _products)
    {
        Product *product = (Product *)[Product selectRow:[productInCart.product integerValue]];
        CGFloat quantity = [productInCart.quantity floatValue];
        CGFloat price    = (product ? ([product.price floatValue]) : 0.0f);
        total += (quantity * price);
    }

    NSString *totalString = [NSString stringWithFormat:@"£%2.2f",total];

    [_labelItems setText:itemsString];
    [_labelTotal setText:totalString];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 101;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _ENTER
    static NSString *CartCell = @"SDCartCell";
    SDCartCell *cell = [tableView dequeueReusableCellWithIdentifier:CartCell];
    if (cell == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:@"SDCartCell" owner:self options:nil];
        cell = [self cell];
        [self setCell:cell];
    }
    
    int row = [indexPath row];
    
    // Make sure that there is something in the array and all is well
    if ([_products count] > 0)
    {
        ProductInCart   *productInCart   = (ProductInCart *)[_products objectAtIndex:row];
        Product         *product         = (productInCart ? (Product *)[Product selectRow:[productInCart.product integerValue]]          : nil);
        Manufacturer    *manufacturer    = (product       ? (Manufacturer *)[Manufacturer selectRow:[product.manufacturer integerValue]] : nil);

        [cell.labelManufacturer setText:(manufacturer ? manufacturer.title : @"Unknown")];
        [cell.labelName         setText:(product ? product.title : @"")];
        [cell.labelReference    setText:(product ? [product.uid stringValue] : @"")];
        [cell.labelPrice        setText:[NSString stringWithFormat:@"£%2.2f",(product ? [product.price floatValue] : 0.0f)]];
        [cell.textQuantity      setText:[productInCart.quantity stringValue]];
        [cell.textQuantity      setDelegate:self];
        [cell.buttonDelete      addTarget:self action:@selector(buttonDeletePressed:) forControlEvents:UIControlEventTouchUpInside];

        NSString *thumbQuery = [NSString stringWithFormat:@"SELECT image FROM ProductPhoto WHERE product = %d AND useAsThumbnail = %@",[product.uid intValue],__DATABASE_TRUE__];
        NSString *thumbPath  = [[Database sharedDatabaseInstance] executeStringQuery:thumbQuery column:@"image"];
        [cell.imageViewThumb setImage:[UIImage imageWithContentsOfFile:thumbPath]];
    }

    _LEAVE
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_products count];
}

#pragma mark -

@end
