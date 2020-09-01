//
//  ActivityOverlayViewController.m
//  iGarden
//
//  Created by Ben Voß on 28/8/2013.
//  Copyright (c) 2013 Ben Voß. All rights reserved.
//

#import "ActivityOverlayViewController.h"

@interface ActivityOverlayViewController ()

@end

@implementation ActivityOverlayViewController

-(id)initWithFrame:(CGRect)theFrame {
    if (self = [super init]) {
        frame = theFrame;
        self.view.frame = theFrame;
    }
    return self;
}

-(void)loadView {
    [super loadView];

    container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110, 30)];
    
    activityLabel = [[UILabel alloc] init];
    activityLabel.text = @"Loading";
    activityLabel.textColor = [UIColor lightGrayColor];
    activityLabel.font = [UIFont boldSystemFontOfSize:17];
	
    [container addSubview:activityLabel];
    activityLabel.frame = CGRectMake(0, 3, 70, 25);
	
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [container addSubview:activityIndicator];
    activityIndicator.frame = CGRectMake(80, 0, 30, 30);
	
    [self.view addSubview:container];
    container.center = CGPointMake(frame.size.width/2, frame.size.height/2);
    self.view.backgroundColor = [UIColor whiteColor];

    [activityIndicator startAnimating];
}

@end
