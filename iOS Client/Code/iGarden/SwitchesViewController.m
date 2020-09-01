//
//  SwitchesViewController.m
//  iGarden
//
//  Created by Ben Voß on 1/11/2012.
//  Copyright (c) 2012 Ben Voß. All rights reserved.
//

#import "SwitchesViewController.h"
#import "RootViewController.h"

@interface SwitchesViewController ()

@end

@implementation SwitchesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	if (section == 0)
		return 2;
	
	if (section == 1)
		return 1;
	
	if (section == 2)
	{
		//if (_autoWatering)
		//	return 1;
		//else
			return 3;
	}
	
	return 0;
}

#pragma mark - Table view delegate

- (IBAction)raisedBedsLightsAction:(id)sender {
	_raisedBedsLights = _raisedBedsLightsSwitch.on;
	[self uploadState];
}

- (IBAction)treeLightsAction:(id)sender {
	_treeLights = _treeLightsSwitch.on;
	[self uploadState];
}

- (IBAction)fountainAction:(id)sender {
	_fountain = _fountainSwitch.on;
	[self uploadState];
}

- (IBAction)autoWateringAction:(id)sender {
	_autoWatering = _autoWateringSwitch.on;

	[self.tableView reloadData];
	//NSIndexSet* set = [NSIndexSet indexSetWithIndex:2];
	//[self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)treesWateringAction:(id)sender {
	UISwitch* s = (UISwitch*)sender;

	_treesWatering = s.on;
	[self uploadState];
}

- (IBAction)lawnWateringAction:(id)sender {
	_lawnWatering = _lawnWateringSwitch.on;
	[self uploadState];
}

- (IBAction)raisedBedsWateringAction:(id)sender {
	_raisedBedsWatering = _raisedBedsWateringSwitch.on;
	[self uploadState];
}

-(void)setState: (NSArray*) state {
	_treeLights = [[state objectAtIndex:0] boolValue];
	_fountain = [[state objectAtIndex:1] boolValue];
	_raisedBedsLights = [[state objectAtIndex:2] boolValue];
	
	_lawnWatering = [[state objectAtIndex:4] boolValue];
	_raisedBedsWatering = [[state objectAtIndex:5] boolValue];
	_treesWatering = [[state objectAtIndex:6] boolValue];
	
	self.raisedBedsLightsSwitch.on = _raisedBedsLights;
	self.treeLightsSwitch.on = _treeLights;
	self.fountainSwitch.on = _fountain;
	self.treesWateringSwitch.on = _treesWatering;
	self.lawnWateringSwitch.on = _lawnWatering;
	self.raisedBedsWateringSwitch.on = _raisedBedsWatering;
}

-(void)uploadState {

	NSArray *objects = [NSArray arrayWithObjects:
						[NSNumber numberWithBool:_treeLights],
						[NSNumber numberWithBool:_fountain],
						[NSNumber numberWithBool:_raisedBedsLights],
						[NSNumber numberWithBool:false],
						[NSNumber numberWithBool:_lawnWatering],
						[NSNumber numberWithBool:_raisedBedsWatering],
						[NSNumber numberWithBool:_treesWatering],
						nil];

    RootViewController* rootViewController = (RootViewController*)self.parentViewController.parentViewController;
    [rootViewController saveState:objects];
}

@end
