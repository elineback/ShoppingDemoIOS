#import "SDProductBrowserViewController.h"

#import "Debug.h"
#import "SDAppDelegate.h"
#import "SDDatabaseUtils.h"
#import "SDProductInfoViewController.h"

@implementation SDProductBrowserViewController

@synthesize scrollView      = _scrollView;
@synthesize contentView     = _contentView;
@synthesize pageControl     = _pageControl;

#pragma mark -
#pragma mark View Life Cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _arrayOfProducts = [[NSMutableArray alloc] init];
        _productCategory = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewDidAppear:(BOOL)animated
{
    [self reload];
}

-(void)setProductCategory:(NSInteger)category
{
    _NSLog(@"BEFORE _productCategory %d, category %d",_productCategory,category);

    _productCategory = category;
    
    _NSLog(@"AFTER  _productCategory %d, category %d",_productCategory,category);
}

-(void) reload
{
    NSArray *subviews = [[NSArray alloc] initWithArray:_contentView.subviews];
    for( UIView *v in subviews)
        [v removeFromSuperview];
    
    _NSLog(@"Product Category is %d",_productCategory);
    
    [_arrayOfProducts addObjectsFromArray:[[SDDatabaseUtils defaultInstance] enumerateProductsForCategory:_productCategory]];
    
    CGFloat numberOfProducts = (CGFloat)[_arrayOfProducts count];
    CGFloat productsPerPage  = 3.0f;
    CGFloat numberOfPages    = ceilf(numberOfProducts/productsPerPage);
    
    CGFloat w = 320.0f * numberOfPages;
    
    [_contentView setFrame:CGRectMake(_contentView.frame.origin.x,_contentView.frame.origin.y,w,_contentView.frame.size.height)];
    [_scrollView setContentSize:(CGSizeMake(w,_scrollView.frame.size.height))];
    [_pageControl setNumberOfPages:(int)numberOfPages];
    
    for(int i = 0 ; i < [_arrayOfProducts count] ; i++)
    {
        NSArray       *nibObjects  = [[NSBundle mainBundle] loadNibNamed:@"SDProductView" owner:self options:nil];
        SDProductView *productView = (SDProductView *)[nibObjects objectAtIndex:0];
        Product       *product     = (Product *)[_arrayOfProducts objectAtIndex:i];
        
        [productView                     setProductUID:product.uid];
        [productView.productManufacturer setText:[[Database sharedDatabaseInstance]
                                                  executeStringQuery:[NSString stringWithFormat:@"SELECT title FROM Manufacturer WHERE uid = %d",[product.manufacturer intValue]] column:@"title"]];
        [productView.productName         setText:product.title];
        [productView.productPrice        setText:[NSString stringWithFormat:@"%.2f",[product.price floatValue]]];
        
        [productView addTarget:self action:@selector(productSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *thumbQuery = [NSString stringWithFormat:@"SELECT image FROM ProductPhoto WHERE product = %d AND useAsThumbnail = %@",[product.uid intValue],__DATABASE_TRUE__];
        NSString *thumbPath  = [[Database sharedDatabaseInstance] executeStringQuery:thumbQuery column:@"image"];
        
        [productView.productThumbnail setImage:[UIImage imageWithContentsOfFile:thumbPath]];
        
        CGFloat w            = 320.0 / 3.0f;
        CGFloat productViewX = (i * w) + ((w - productView.frame.size.width) / 2.0f);
        CGFloat productViewY = 6.0f;
        
        [productView setFrame:CGRectMake(productViewX,productViewY,productView.frame.size.width,productView.frame.size.height)];
        [_contentView addSubview:productView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)changePage
{
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    _pageControlBeingUsed = YES;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

- (IBAction)productSelected:(id)sender
{
    SDProductView *selectedProductView = (SDProductView *)sender;

    _NSLog(@"Product Selected : %@", selectedProductView.productName.text);
    
    SDAppDelegate *app = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
    SDProductInfoViewController *productInfoViewController = [[SDProductInfoViewController alloc] initWithNibName:@"SDProductInfoViewController" bundle:nil];
    [app pushViewController:productInfoViewController];
    
    [productInfoViewController                  setUid:selectedProductView.productUID];
    [productInfoViewController.imageViewProduct setImage:selectedProductView.productThumbnail.image];
    [productInfoViewController.labelName        setText:selectedProductView.productName.text];
    [productInfoViewController.labelPrice       setText:selectedProductView.productPrice.text];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if (!_pageControlBeingUsed)
    {
        CGFloat pageWidth = self.scrollView.frame.size.width;
        int     page      = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.pageControl.currentPage = page;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControlBeingUsed = NO;
}

@end
