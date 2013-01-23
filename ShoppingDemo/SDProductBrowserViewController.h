#import <UIKit/UIKit.h>

#import "SDOpenCartAPI.h"
#import "SDProductView.h"

@interface SDProductBrowserViewController : UIViewController
{
    UIScrollView   *_scrollView;
    UIView         *_contentView;
    UIPageControl  *_pageControl;

    NSMutableArray *_arrayOfProducts;
    NSMutableArray *_productViews;
    
    BOOL            _pageControlBeingUsed;
    
    NSInteger       _productCategory;
}

@property (strong,nonatomic) IBOutlet UIScrollView   *scrollView;
@property (strong,nonatomic) IBOutlet UIView         *contentView;
@property (strong,nonatomic) IBOutlet UIPageControl  *pageControl;

- (IBAction)changePage;
- (IBAction)productSelected:(id)sender;

- (void)setProductCategory:(NSInteger)category;

- (void)reload;

@end
