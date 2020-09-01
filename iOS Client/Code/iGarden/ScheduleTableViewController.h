//
//  ScheduleTableViewController.h
//  iGarden
//
//  Created by Ben Voß on 26/9/2013.
//  Copyright (c) 2013 Ben Voß. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScheduleItem.h"

@protocol ScheduleTableEditDelegate <NSObject, UINavigationControllerDelegate>
	-(void)saveNewScheduleItem:(ScheduleItem*)scheduleItem;
	-(void)updateExistingScheduleItem:(ScheduleItem*)scheduleItem;
	-(void)cancelEditingScheduleItem;
@end

@interface ScheduleTableViewController : UITableViewController<UITableViewDelegate, ScheduleTableEditDelegate> {
@private
	UINavigationController * _navigationController;
	
	NSDateFormatter* _dateFormatter;
	NSMutableArray* _scheduleItems;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;

@end
