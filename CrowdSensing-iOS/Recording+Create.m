//
//  Recording+Create.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 19/06/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import "Recording+Create.h"

@implementation Recording (Create)

+ (Recording *)recordingWithTitle:(NSString *)title
                   withCreateDate:(NSDate *)createDate
           inManagedObjectContext:(NSManagedObjectContext *)context
{
    Recording *recording = [NSEntityDescription insertNewObjectForEntityForName:@"Recording"
                                                         inManagedObjectContext:context];
    
    recording.title = title;
    recording.createDate = createDate;
    
    return recording;
}

@end
