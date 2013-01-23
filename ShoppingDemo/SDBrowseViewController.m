#import "SDBrowseViewController.h"

@implementation SDBrowseViewController

@synthesize featureView      = _featureView;
@synthesize segmentedControl = _segmentedControl;
@synthesize productCategory  = _productCategory;

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

    _productViewController = [[SDProductBrowserViewController alloc] initWithNibName:@"SDProductBrowserViewController" bundle:nil];
    [self addChildViewController:_productViewController];
    [self.productView addSubview:_productViewController.view];
}

- (void)viewDidAppear:(BOOL)animated
{
    _featuresViewController = [[SDFeaturesViewController alloc] initWithNibName:@"SDFeaturesViewController" bundle:nil];
    [self addChildViewController:_featuresViewController];
    [self.featureView addSubview:_featuresViewController.view];
    UIScrollView *scrollView = (UIScrollView *)_featuresViewController.view;
    [scrollView setContentSize:CGSizeMake(1280,132)];
    [scrollView setPagingEnabled:YES];
    
    _promotionsViewController = [[SDPromotionsViewController alloc] initWithNibName:@"SDPromotionsViewController" bundle:nil];
    [self addChildViewController:_promotionsViewController];

    _featuresSegment = YES;
    [_segmentedControl setSelectedSegmentIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)setProductCategory:(NSInteger)category
{
    _productCategory = category;
    
    _NSLog(@"Setting category %d",category);

    [_productViewController setProductCategory:category];
}

#pragma mark -
#pragma mark IBActions

-(IBAction)featuresPromoChanged:(id)sender
{
    int i = _segmentedControl.selectedSegmentIndex;
    
    _featuresSegment = (i == 0);
    
    switch(i)
    {
        case 0:
            // Switch to _featuresView
            [self animateFlipRight];
            break;
        case 1:
            // Switch to _promotionsView
            [self animateFlipLeft];
            break;
    }
}

#pragma mark -
#pragma mark Animations

-(void) animateFlipLeft
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationDelegate:nil];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:_featureView cache:YES];
	[_featuresViewController.view removeFromSuperview];
	[_featureView addSubview:_promotionsViewController.view];
	[UIView commitAnimations];
}

-(void) animateFlipRight
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationDelegate:nil];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:_featureView cache:YES];
	[_promotionsViewController.view removeFromSuperview];
	[_featureView addSubview:_featuresViewController.view];
	[UIView commitAnimations];
}

@end
