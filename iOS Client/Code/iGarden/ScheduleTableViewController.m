//
//  ScheduleTableViewController.m
//  iGarden
//
//  Created by Ben Voß on 26/9/2013.
//  Copyright (c) 2013 Ben Voß. All rights reserved.
//

#import "ScheduleTableViewController.h"
#import "ScheduleTableViewCell.h"
#import "ScheduleItem.h"
#import "EditScheduleViewController.h"

@interface ScheduleTableViewController ()

@end

@implementation ScheduleTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Pre-load the edit view.  This seems to prevent a pause while editing the first item
	_navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditScheduleViewController"];
	[_navigationController loadView];
	
	_dateFormatter = [[NSDateFormatter alloc] init];
	[_dateFormatter setDateFormat:@"h:mm a"];

	_scheduleItems = [[NSMutableArray alloc] init];
	
	ScheduleItem* item = [[ScheduleItem alloc] init];
	item.switchName = @"Test";
	item.fromDate = [NSDate date];
	item.toDate = [NSDate date];
	
	[_scheduleItems addObject:item];
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
	
	self.navigationController.delegate = self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _scheduleItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ScheduleCell";
    ScheduleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if (cell == nil) {
		cell = [[ScheduleTableViewCell alloc] init];
	}
	
    // Configure the cell...
	ScheduleItem* item = [_scheduleItems objectAtIndex:indexPath.row];
	
	cell.switchLabel.text = item.switchName;
    cell.fromLabel.text = [_dateFormatter stringFromDate:item.fromDate];
    cell.toLabel.text = [_dateFormatter stringFromDate:item.toDate];
	
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		// Remove the item from the schedule
		[_scheduleItems removeObjectAtIndex:indexPath.row];
		
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	NSLog(@"prepareForSegue %f", [[NSDate date] timeIntervalSince1970] );

	if ([segue.identifier isEqualToString:@"AddSchedule"]) {
		
		// The edit schedule view sits within a navigation controller (so it can have a toolbar).
		// We need to get the edit schedule view controller from the navigation controller to set the delegate
		UINavigationController * navigationController = [segue destinationViewController];
		EditScheduleViewController* editScheduleViewController = (EditScheduleViewController*)navigationController.visibleViewController;

		editScheduleViewController.scheduleItem = nil;
		editScheduleViewController.editDelegate = self;

	} else if ([segue.identifier isEqualToString:@"EditSchedule"]) {
			
		// The edit schedule view sits within a navigation controller (so it can have a toolbar).
		// We need to get the edit schedule view controller from the navigation controller to set the delegate
		UINavigationController * navigationController = [segue destinationViewController];
		EditScheduleViewController* editScheduleViewController = (EditScheduleViewController*)navigationController.visibleViewController;
		
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
		editScheduleViewController.scheduleItem = [_scheduleItems objectAtIndex:indexPath.row];
		editScheduleViewController.editDelegate = self;
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
}

-(void)saveNewScheduleItem:(ScheduleItem*)scheduleItem {
	[_scheduleItems addObject:scheduleItem];
	
	[self setEditing:NO animated:NO];
	[self.tableView reloadData];
}

-(void)updateExistingScheduleItem:(ScheduleItem*)scheduleItem {
	[self setEditing:NO animated:NO];
	[self.tableView reloadData];
}

-(void)cancelEditingScheduleItem {
	[self setEditing:NO animated:NO];
	[self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.isEditing) {
		[self performSegueWithIdentifier:@"EditSchedule" sender:self];
	}
}

@end
