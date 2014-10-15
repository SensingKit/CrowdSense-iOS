//
//  CSSensorSetupTableViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSSensorSetupTableViewController.h"

#import "CSSimpleSensorSetup.h"
#import "CSSamplingRateSensorSetup.h"
#import "CSLocationSensorSetup.h"
#import "CSProximitySensorSetup.h"

@interface CSSensorSetupTableViewController ()

@end

@implementation CSSensorSetupTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"Accelerometer Sensor Segue"])
    {
        CSSamplingRateSensorSetup *tableViewController = [segue destinationViewController];
        
        tableViewController.sensorSetupType = CSSensorSetupAccelerometerType;
    }
    else if ([segue.identifier isEqual:@"Gyroscope Sensor Segue"])
    {
        CSSamplingRateSensorSetup *tableViewController = [segue destinationViewController];
        
        tableViewController.sensorSetupType = CSSensorSetupGyroscopeType;
    }
    else if ([segue.identifier isEqual:@"Magnetometer Sensor Segue"])
    {
        CSSamplingRateSensorSetup *tableViewController = [segue destinationViewController];
        
        tableViewController.sensorSetupType = CSSensorSetupMagnetometerType;
    }
    else if ([segue.identifier isEqual:@"Device Motion Sensor Segue"])
    {
        CSSamplingRateSensorSetup *tableViewController = [segue destinationViewController];
        
        tableViewController.sensorSetupType = CSSensorSetupDeviceMotionType;
    }
    else if ([segue.identifier isEqual:@"Activity Sensor Segue"])
    {
        CSSimpleSensorSetup *tableViewController = [segue destinationViewController];
        
        tableViewController.sensorSetupType = CSSensorSetupActivityType;
    }
    else if ([segue.identifier isEqual:@"Location Sensor Segue"])
    {
        CSLocationSensorSetup *tableViewController = [segue destinationViewController];
        
        tableViewController.sensorSetupType = CSSensorSetupLocationType;
    }
    else if ([segue.identifier isEqual:@"Proximity Sensor Segue"])
    {
        CSProximitySensorSetup *tableViewController = [segue destinationViewController];
        
        tableViewController.sensorSetupType = CSSensorSetupProximityType;
    }
    else if ([segue.identifier isEqual:@"Battery Sensor Segue"])
    {
        CSSimpleSensorSetup *tableViewController = [segue destinationViewController];
        
        tableViewController.sensorSetupType = CSSensorSetupBatteryType;
    }
    else
    {
        NSLog(@"Unknown segue identifier '%@'", segue.identifier);
    }
}

@end
