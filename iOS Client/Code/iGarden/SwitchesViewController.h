//
//  SwitchesViewController.h
//  iGarden
//
//  Created by Ben Voß on 1/11/2012.
//  Copyright (c) 2012 Ben Voß. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityOverlayViewController.h"

@interface SwitchesViewController : UITableViewController
{
	@private
    
	bool _raisedBedsLights;
	bool _treeLights;
	bool _fountain;
	bool _autoWatering;
	bool _treesWatering;
	bool _lawnWatering;
	bool _raisedBedsWatering;
}

// Called from the root view controller to set the initial switch state
-(void)setState: (NSArray*) state;

// Lighting
- (IBAction)raisedBedsLightsAction:(id)sender;
- (IBAction)treeLightsAction:(id)sender;

// Water Feature
- (IBAction)fountainAction:(id)sender;

// Watering
- (IBAction)autoWateringAction:(id)sender;
- (IBAction)treesWateringAction:(id)sender;
- (IBAction)lawnWateringAction:(id)sender;
- (IBAction)raisedBedsWateringAction:(id)sender;

// Lighting
@property (strong, nonatomic) IBOutlet UISwitch *raisedBedsLightsSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *treeLightsSwitch;

// Water Feature
@property (strong, nonatomic) IBOutlet UISwitch *fountainSwitch;

// Watering
@property (strong, nonatomic) IBOutlet UISwitch *autoWateringSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *treesWateringSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *lawnWateringSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *raisedBedsWateringSwitch;

@end
