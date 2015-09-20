//
//  CSGenericSensorSetup.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSGenericSensorSetup.h"

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
    switch (sensorType)
    {
        case Accelerometer:
            self.title = @"Accelerometer";
            break;
            
        case Gyroscope:
            self.title = @"Gyroscope";
            break;
            
        case Magnetometer:
            self.title = @"Magnetometer";
            break;
            
        case DeviceMotion:
            self.title = @"Device Motion";
            break;
            
        case Activity:
            self.title = @"Activity";
            break;
            
        case Pedometer:
            self.title = @"Pedometer";
            break;
            
        case Altimeter:
            self.title = @"Altimeter";
            break;
            
        case Location:
            self.title = @"Location";
            break;
            
        case iBeaconProximity:
            self.title = @"iBeacon™ Proximity";
            break;
            
        case EddystoneProximity:
            self.title = @"Eddystone™ Proximity";
            break;
            
        case Battery:
            self.title = @"Battery";
            break;
            
        case Microphone:
            self.title = @"Microphone";
            break;
            
        default:
            NSLog(@"Unknown sensorSetupType: %ld", (long)sensorType);
            abort();
    }
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
