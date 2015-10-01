//
//  CSGenericSensorSetup.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSGenericSensorSetup.h"
#import <SensingKit/NSString+SensorType.h>

@interface CSGenericSensorSetup ()

@end

@implementation CSGenericSensorSetup

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.sensorDescription;
    }
    else
    {
        return nil;
    }
}

- (void)setSensorType:(SKSensorType)sensorType
{
    // Update the title first
    [self updateTitleForSensor:sensorType];
    
    _sensorType = sensorType;
}

- (void)updateTitleForSensor:(SKSensorType)sensorType
{
    self.title = [NSString stringWithSensorType:sensorType];
}

- (void)alertSensorNotAvailable
{
    NSString *title = [NSString stringWithFormat:@"%@ Sensor", self.title];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:@"Sensor is not available on this device."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
}

- (void)updateConfiguration
{
    if (self.delegate)
    {
        [self.delegate updateConfiguration:self.configuration forSensor:self.sensorType];
    }
}

@end
