//
//  RootViewController.h
//  iGarden
//
//  Created by Ben Voß on 11/06/2014.
//  Copyright (c) 2014 Ben Voß. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityOverlayViewController.h"

@interface RootViewController : UITabBarController
{
    @private

    NSOperationQueue *_ioQueue;

    ActivityOverlayViewController *_overlayViewController;
}

// Called to save the state
-(void)saveState:(NSArray*) switchState;

@end
