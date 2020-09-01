//
//  ScheduleItem.h
//  iGarden
//
//  Created by Ben Voß on 26/9/2013.
//  Copyright (c) 2013 Ben Voß. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScheduleItem : NSObject

@property NSDate* fromDate;
@property NSDate* toDate;
@property NSString* switchName;

@end
