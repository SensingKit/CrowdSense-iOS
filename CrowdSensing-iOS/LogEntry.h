//
//  LogEntry.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 18/06/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Recording;

@interface LogEntry : NSManagedObject

@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) Recording *ofRecording;

@end
