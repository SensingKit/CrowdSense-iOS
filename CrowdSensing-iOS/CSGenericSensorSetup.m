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
    [self alertWithTitle:[NSString stringWithFormat:@"%@ Sensor", self.title]
             withMessage:@"Sensor is not available on this device."
             withHandler:nil];
}

- (void)updateConfiguration
{
    if (self.delegate)
    {
        [self.delegate updateConfiguration:self.configuration forSensor:self.sensorType];
    }
}

- (void)alertWithTitle:(NSString *)title withMessage:(NSString *)message
           withHandler:(void (^ __nullable)(UIAlertAction *action))handler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:handler];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
