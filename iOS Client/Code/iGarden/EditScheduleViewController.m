//
//  EditScheduleViewController.m
//  iGarden
//
//  Created by Ben Voß on 24/9/2013.
//  Copyright (c) 2013 Ben Voß. All rights reserved.
//

#import "EditScheduleViewController.h"

@interface EditScheduleViewController ()

@end

@implementation EditScheduleViewController

@synthesize editDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		NSLog(@"initWithNibName");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSLog(@"viewDidLoad - start %f", [[NSDate date] timeIntervalSince1970] );
	
	_dateFormatter = [[NSDateFormatter alloc] init];
	[_dateFormatter setDateFormat:@"h:mm a"];

	self.switchPicker.dataSource = self;
	self.switchPicker.delegate = self;
	
	_rowHeights = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:44], [NSNumber numberWithInt:0], [NSNumber numberWithInt:44], [NSNumber numberWithInt:0], [NSNumber numberWithInt:44], [NSNumber numberWithInt:0], [NSNumber numberWithInt:44], nil];
	
	_switchNames = [[NSArray alloc] initWithObjects:@"Raised Bed Lights", @"Tree Lights", @"Fountain", @"Tree Watering", @"Lawn Watering", @"Raised Bed Watering", nil];
	
	self.switchLabel.text = [_switchNames objectAtIndex: [self.switchPicker selectedRowInComponent:0]];
	self.startsLabel.text = [_dateFormatter stringFromDate:self.startsTimePicker.date];
	self.endsLabel.text = [_dateFormatter stringFromDate:self.endsTimePicker.date];
	
	NSLog(@"viewDidLoad - end %f", [[NSDate date] timeIntervalSince1970] );

}

//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
//}

- (IBAction)doneAction:(id)sender {
	
	if (self.editDelegate != nil) {
		if (self.scheduleItem == nil) {
			if ( [self.editDelegate respondsToSelector:@selector(saveNewScheduleItem:)] ) {
        
				ScheduleItem* item = [[ScheduleItem alloc] init];
				item.fromDate	 = self.startsTimePicker.date;
				item.toDate = self.endsTimePicker.date;
				item.switchName = [_switchNames objectAtIndex: [self.switchPicker selectedRowInComponent:0]];
	
				[self.editDelegate saveNewScheduleItem:item];
			}
		} else {
			if ( [self.editDelegate respondsToSelector:@selector(saveNewScheduleItem:)] ) {
			
				self.scheduleItem.fromDate	 = self.startsTimePicker.date;
				self.scheduleItem.toDate = self.endsTimePicker.date;
				self.scheduleItem.switchName = [_switchNames objectAtIndex: [self.switchPicker selectedRowInComponent:0]];
				
				[self.editDelegate updateExistingScheduleItem:self.scheduleItem];
			}
		
		}
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"viewWillAppear %f", [[NSDate date] timeIntervalSince1970] );

	if (self.scheduleItem == nil) {
		self.title = @"Add Schedule";
	} else {
		self.title = @"Edit Schedule";
	}
}
- (IBAction)cancelAction:(id)sender {
	if (self.editDelegate != nil) {
		if ( [self.editDelegate respondsToSelector:@selector(cancelEditingScheduleItem)] ) {
			[self.editDelegate cancelEditingScheduleItem];
		}
	}

	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.row % 2 == 0) {
		int rowNum = (int)(indexPath.row + 1);
		
		if ([[_rowHeights objectAtIndex:rowNum] integerValue] == 0) {
			[_rowHeights setObject:[NSNumber numberWithInt:210] atIndexedSubscript:rowNum];
		} else {
			[_rowHeights setObject:[NSNumber numberWithInt:0] atIndexedSubscript:rowNum];
		}
		
		for (int i = 1; i < 6; i+=2) {
			if (i != rowNum) {
				[_rowHeights setObject:[NSNumber numberWithInt:0] atIndexedSubscript:i];
			}
		}
	}
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

	[tableView beginUpdates];
	[tableView endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[_rowHeights objectAtIndex:indexPath.row] integerValue];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [_switchNames count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [_switchNames objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	NSString* item = [_switchNames objectAtIndex:row];
	
	self.switchLabel.text = item;
}

- (IBAction)startsTimePickerChanged:(UIDatePicker *)sender {
	self.startsLabel.text = [_dateFormatter stringFromDate:sender.date];
}

- (IBAction)endsDatePickerChanged:(UIDatePicker *)sender {
	self.endsLabel.text = [_dateFormatter stringFromDate:sender.date];
}

@end
