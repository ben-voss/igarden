//
//  ActivityOverlayViewController.h
//  iGarden
//
//  Created by Ben Voß on 28/8/2013.
//  Copyright (c) 2013 Ben Voß. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityOverlayViewController : UIViewController {
    UILabel *activityLabel;
    UIActivityIndicatorView *activityIndicator;
    UIView *container;
    CGRect frame;
}
-(id)initWithFrame:(CGRect) theFrame;

@end
