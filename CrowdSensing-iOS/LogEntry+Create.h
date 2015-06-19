//
//  LogEntry+Create.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 19/06/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import "LogEntry.h"

@interface LogEntry (Create)

+ (LogEntry *)logEntryWithLabel:(NSString *)label
                  withTimestamp:(NSDate *)timestamp
         inManagedObjectContext:(NSManagedObjectContext *)context;

@end
