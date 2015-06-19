//
//  Recording+Create.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 19/06/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import "Recording.h"

@interface Recording (Create)

+ (Recording *)recordingWithTitle:(NSString *)title
                   withCreateDate:(NSDate *)createDate
           inManagedObjectContext:(NSManagedObjectContext *)context;

@end
