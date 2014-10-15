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
            
        case CSSensorSetupProximityType:
            self.title = @"Proximity";
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
