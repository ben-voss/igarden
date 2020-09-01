//
//  EditScheduleViewController.h
//  iGarden
//
//  Created by Ben Voß on 24/9/2013.
//  Copyright (c) 2013 Ben Voß. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScheduleItem.h"
#import "ScheduleTableViewController.h"

@interface EditScheduleViewController : UITableViewController<UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
	NSMutableArray* _rowHeights;
	NSArray* _switchNames;
	NSDateFormatter *_dateFormatter;
}

- (IBAction)doneAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@property (strong, nonatomic) IBOutlet UIPickerView *switchPicker;
@property (strong, nonatomic) IBOutlet UILabel *switchLabel;

@property (strong, nonatomic) IBOutlet UILabel *startsLabel;
@property (strong, nonatomic) IBOutlet UIDatePicker *startsTimePicker;
- (IBAction)startsTimePickerChanged:(UIDatePicker *)sender;

@property (strong, nonatomic) IBOutlet UILabel *endsLabel;
@property (strong, nonatomic) IBOutlet UIDatePicker *endsTimePicker;
- (IBAction)endsDatePickerChanged:(UIDatePicker *)sender;

@property (strong, nonatomic) ScheduleItem *scheduleItem;

@property (nonatomic, assign) id<ScheduleTableEditDelegate> editDelegate;

@end
