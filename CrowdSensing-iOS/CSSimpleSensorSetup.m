//
//  CSSimpleSensorSetup.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSSimpleSensorSetup.h"

@interface CSSimpleSensorSetup ()

@end

@implementation CSSimpleSensorSetup

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)sensorSwitchAction:(id)sender
{
    if (self.delegate && self.sensorStatus != CSSensorStatusNotAvailable)
    {
        UISwitch *sensorSwitch = sender;
        
        if (sensorSwitch.on)
        {
            [self.delegate changeStatus:CSSensorStatusEnabled ofSensorWithType:self.sensorSetupType];
        }
        else
        {
            [self.delegate changeStatus:CSSensorStatusDisabled ofSensorWithType:self.sensorSetupType];
        }
    }
}

- (IBAction)switchTouchedAction:(id)sender
{
    if (self.sensorStatus == CSSensorStatusNotAvailable)
    {
        NSString *title = [NSString stringWithFormat:@"%@ Sensor", self.title];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:@"Sensor is not available on this device."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
        
        [self.sensorSwitch setOn:NO animated:YES];
    }
}

@end