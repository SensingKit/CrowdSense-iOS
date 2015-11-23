//
//  NSString+CSTimeInterval.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 23/11/2015.
//  Copyright © 2015 Kleomenis Katevas. All rights reserved.
//

#import "NSString+CSTimeInterval.h"

@implementation NSString (CSTimeInterval)

// Thanks to http://stackoverflow.com/questions/28872450/conversion-from-nstimeinterval-to-hour-minutes-seconds-milliseconds-in-swift
+ (NSString *)stringFromTimeInterval:(NSTimeInterval)timeInterval
{
    if (!isnan(timeInterval))
    {
        NSInteger interval = timeInterval;
        NSInteger ms = (fmod(timeInterval, 1) * 1000);
        long seconds = interval % 60;
        long minutes = (interval / 60) % 60;
        long hours = (interval / 3600);
    
        return [NSString stringWithFormat:@"%0.2ld:%0.2ld:%0.2ld,%0.3ld", hours, minutes, seconds, (long)ms];
    }
    else
    {
        return @"00:00:00,000";
    }
}

@end
