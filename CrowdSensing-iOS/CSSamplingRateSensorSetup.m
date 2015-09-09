//
//  CSSamplingRateSensorSetup.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSSamplingRateSensorSetup.h"
#import "CSSelectSamplingRate.h"

@interface CSSamplingRateSensorSetup () <CSSelectSamplingRateDelegate>

@property (nonatomic) NSUInteger samplingRate;

@end

@implementation CSSamplingRateSensorSetup

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the label from title
    self.sensorLabel.text = self.title;
    
    // Update sensor specific properties
    [self updateProperties];
}

- (IBAction)sensorSwitchAction:(id)sender
{
    if (self.delegate && self.sensorStatus != CSSensorStatusNotAvailable)
    {
        UISwitch *sensorSwitch = sender;
        
        if (sensorSwitch.on)
        {
            [self.delegate changeStatus:CSSensorStatusEnabled ofSensor:self.sensorType withConfiguration:nil];
        }
        else
        {
            [self.delegate changeStatus:CSSensorStatusDisabled ofSensor:self.sensorType withConfiguration:nil];
        }
    }
}

- (IBAction)switchTouchedAction:(id)sender
{
    if (self.sensorStatus == CSSensorStatusNotAvailable)
    {
        [self alertSensorNotAvailable];
        
        [self.sensorSwitch setOn:NO animated:YES];
    }
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

- (SKAccelerometerConfiguration *)accelerometerConfiguration
{
    return (SKAccelerometerConfiguration *)self.configuration;
}

- (SKGyroscopeConfiguration *)gyroscopeConfiguration
{
    return (SKGyroscopeConfiguration *)self.configuration;
}

- (SKMagnetometerConfiguration *)magnetometerConfiguration
{
    return (SKMagnetometerConfiguration *)self.configuration;
}

- (SKDeviceMotionConfiguration *)deviceMotionConfiguration
{
    return (SKDeviceMotionConfiguration *)self.configuration;
}

- (void)setSamplingRate:(NSUInteger)samplingRate
{
    // Update the UI
    self.samplingRateLabel.text = [NSString stringWithFormat:@"%lu Hz", (long)samplingRate];
    
    _samplingRate = samplingRate;
}

- (void)updateProperties
{
    NSUInteger samplingRate;
    
    if (self.sensorType == Accelerometer)
    {
        samplingRate = [self accelerometerConfiguration].samplingRate;
    }
    else if (self.sensorType == Gyroscope)
    {
        samplingRate = [self gyroscopeConfiguration].samplingRate;
    }
    else if (self.sensorType == Magnetometer)
    {
        samplingRate = [self magnetometerConfiguration].samplingRate;
    }
    else if (self.sensorType == DeviceMotion)
    {
        samplingRate = [self deviceMotionConfiguration].samplingRate;
    }
    else
    {
        NSLog(@"Sensor %lu is not supported from this SensorSetup class", (unsigned long)self.sensorType);
        abort();
    }
    
    // Update the property and the UI
    self.samplingRate = samplingRate;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Select Sampling Rate"])
    {
        // set delegate
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        CSSelectSamplingRate *selectSamplingRate = (CSSelectSamplingRate *)navigationController.topViewController;
        selectSamplingRate.delegate = self;
    }
}

@end
