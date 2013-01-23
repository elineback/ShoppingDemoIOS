#import "SDFeaturesViewController.h"

@implementation SDFeaturesViewController

@synthesize scrollView  = _scrollView;
@synthesize contentView = _contentView;
@synthesize pageControl = _pageControl;

#pragma mark -
#pragma mark View Life Cycle

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    [_pageControl setNumberOfPages:4];
}

-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark IBActions

-(IBAction) changePage
{
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    _pageControlBeingUsed = YES;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

-(void) scrollViewDidScroll:(UIScrollView *)sender
{
    if (!_pageControlBeingUsed)
    {
        CGFloat pageWidth = self.scrollView.frame.size.width;
        int     page      = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.pageControl.currentPage = page;
    }
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _pageControlBeingUsed = NO;
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControlBeingUsed = NO;
}

@end
