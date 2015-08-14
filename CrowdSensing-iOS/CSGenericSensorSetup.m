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
            
        case CSSensorSetupLocationType:
            self.title = @"Location";
            break;
            
        case CSSensorSetupBatteryType:
            self.title = @"Battery";
            break;
            
        default:
            NSLog(@"Unknown sensorSetupType: %ld", (long)sensorSetupType);
            break;
    }
    
    _sensorSetupType = sensorSetupType;
}

@end
