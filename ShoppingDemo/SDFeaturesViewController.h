#import <UIKit/UIKit.h>

#import "SDOpenCartAPI.h"

@interface SDFeaturesViewController : UIViewController
{
    UIScrollView   *_scrollView;
    UIView         *_contentView;
    UIPageControl  *_pageControl;

    BOOL            _pageControlBeingUsed;
}

@property (strong,nonatomic) IBOutlet UIScrollView   *scrollView;
@property (strong,nonatomic) IBOutlet UIView         *contentView;
@property (strong,nonatomic) IBOutlet UIPageControl  *pageControl;

- (IBAction)changePage;

@end
