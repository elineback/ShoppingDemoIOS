#import <UIKit/UIKit.h>

#import "SDBaseViewController.h"

#import "SDFeaturesViewController.h"
#import "SDPromotionsViewController.h"
#import "SDProductBrowserViewController.h"

@interface SDBrowseViewController : SDBaseViewController
{
    UIView                     *_featureView;
    UIView                     *_productView;
    
    UISegmentedControl         *_segmentedControl;
    
    SDFeaturesViewController       *_featuresViewController;
    SDPromotionsViewController     *_promotionsViewController;
    SDProductBrowserViewController *_productViewController;
    
    BOOL                        _featuresSegment;
    
    NSInteger                   _productCategory;
}

@property (strong,nonatomic) IBOutlet UIView             *featureView;
@property (strong,nonatomic) IBOutlet UIView             *productView;
@property (strong,nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (assign,nonatomic)          NSInteger           productCategory;

-(IBAction)featuresPromoChanged:(id)sender;

-(void) animateFlipLeft;
-(void) animateFlipRight;

@end
