//
//  ScheduleTableViewCell.h
//  iGarden
//
//  Created by Ben Voß on 26/9/2013.
//  Copyright (c) 2013 Ben Voß. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *switchLabel;
@property (strong, nonatomic) IBOutlet UILabel *fromLabel;
@property (strong, nonatomic) IBOutlet UILabel *toLabel;

@end
