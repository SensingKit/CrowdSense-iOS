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
    
    // Create the Configuration
    self.configuration = [CSGenericSensorSetup createConfigurationForSensor:self.sensorType];
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

+ (SKConfiguration *)createConfigurationForSensor:(SKSensorType)sensorType
{
    SKConfiguration *configuration;
    
    switch (sensorType) {
            
        case Accelerometer:
            configuration = [[SKAccelerometerConfiguration alloc] init];
            break;
            
        case Gyroscope:
            configuration = [[SKGyroscopeConfiguration alloc] init];
            break;
            
        case Magnetometer:
            configuration = [[SKMagnetometerConfiguration alloc] init];
            break;
            
        case DeviceMotion:
            configuration = [[SKDeviceMotionConfiguration alloc] init];
            break;
            
        case Activity:
            configuration = [[SKActivityConfiguration alloc] init];
            break;
            
        case Pedometer:
            configuration = [[SKPedometerConfiguration alloc] init];
            break;
            
        case Altimeter:
            configuration = [[SKAltimeterConfiguration alloc] init];
            break;
            
        case Location:
            configuration = [[SKLocationConfiguration alloc] init];
            break;
            
        case iBeaconProximity:
            configuration = [[SKiBeaconProximityConfiguration alloc] init];
            break;
            
        case EddystoneProximity:
            configuration = [[SKEddystoneProximityConfiguration alloc] init];
            break;
            
        case Battery:
            configuration = [[SKBatteryConfiguration alloc] init];
            break;
            
        case Microphone:
            configuration = [[SKMicrophoneConfiguration alloc] init];
            break;
            
        default:
            NSLog(@"Unknown sensorSetupType: %ld", (long)sensorType);
            abort();
    }
    
    return configuration;
}

@end
