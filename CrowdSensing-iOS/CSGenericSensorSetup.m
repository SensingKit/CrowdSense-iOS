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
    
    // Set the label from title
    self.sensorLabel.text = self.title;
    
    [self updateSensorSwitch];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return self.sensorDescription;
}

- (void)updateSensorSwitch
{
    switch (self.sensorStatus)
    {
        case CSSensorStatusDisabled:
            self.sensorSwitch.on = NO;
            break;
            
        case CSSensorStatusEnabled:
            self.sensorSwitch.on = YES;
            break;
            
        case CSSensorStatusNotAvailable:
            self.sensorSwitch.on = NO;
            break;
            
        default:
            NSLog(@"Unknown CSSensorStatus: %lu", (unsigned long)self.sensorStatus);
            abort();
    }
}

- (void)setSensorSetupType:(enum CSSensorSetupType)sensorSetupType
{
    switch (sensorSetupType)
    {
        case CSSensorSetupAccelerometerType:
            self.title = @"Accelerometer";
            break;
            
        case CSSensorSetupGyroscopeType:
            self.title = @"Gyroscope";
            break;
            
        case CSSensorSetupMagnetometerType:
            self.title = @"Magnetometer";
            break;
            
        case CSSensorSetupDeviceMotionType:
            self.title = @"Device Motion";
            break;
            
        case CSSensorSetupActivityType:
            self.title = @"Activity";
            break;
            
        case CSSensorSetupPedometerType:
            self.title = @"Pedometer";
            break;
            
        case CSSensorSetupAltimeterType:
            self.title = @"Altimeter";
            break;
            
        case CSSensorSetupLocationType:
            self.title = @"Location";
            break;
            
        case CSSensorSetupBeaconType:
            self.title = @"iBeacon™ Proximity";
            break;
            
        case CSSensorSetupEddystoneType:
            self.title = @"Eddystone™ Proximity";
            break;
            
        case CSSensorSetupBatteryType:
            self.title = @"Battery";
            break;
            
        case CSSensorSetupMicrophoneType:
            self.title = @"Microphone";
            break;
            
        default:
            NSLog(@"Unknown sensorSetupType: %ld", (long)sensorSetupType);
            abort();
    }
    
    _sensorSetupType = sensorSetupType;
}

@end
