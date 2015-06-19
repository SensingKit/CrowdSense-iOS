//
//  LogEntry+Create.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 19/06/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import "LogEntry+Create.h"

@implementation LogEntry (Create)

+ (LogEntry *)logEntryWithLabel:(NSString *)label
                  withTimestamp:(NSDate *)timestamp
         inManagedObjectContext:(NSManagedObjectContext *)context
{
    LogEntry *logEntry = [NSEntityDescription insertNewObjectForEntityForName:@"LogEntry"
                                                       inManagedObjectContext:context];
    
    logEntry.label = label;
    logEntry.timestamp = timestamp;
    
    return logEntry;
}

@end
