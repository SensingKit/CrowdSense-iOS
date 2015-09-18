//
//  CSLocationSensorSetup.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSLocationSensorSetup.h"
#import "CSUserInput.h"

@interface CSLocationSensorSetup () <CSNUserInputDelegate>

@end

@implementation CSLocationSensorSetup

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the label from title
    self.sensorLabel.text = self.title;
    
    // Update sensor properties
    [self updateSensorSwitch];
}

- (IBAction)sensorSwitchAction:(id)sender
{
    if (self.delegate && self.sensorStatus != CSSensorStatusNotAvailable)
    {
        UISwitch *sensorSwitch = sender;
        
        if (sensorSwitch.on)
        {
            [self.delegate changeStatus:CSSensorStatusEnabled ofSensor:self.sensorType withConfiguration:self.configuration];
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

- (SKLocationConfiguration *)locationConfiguration
{
    return (SKLocationConfiguration *)self.configuration;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.textLabel.text isEqualToString:@"Distance Filter"])
    {
        // Configure the userInput controller
        UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"userInput"];
        CSUserInput *userInput = (CSUserInput *)navigationController.topViewController;
        userInput.delegate = self;
        userInput.maxDigits = 4;
        userInput.minValue = 0;
        userInput.maxValue = 1000;
        userInput.defaultValue = self.locationConfiguration.distanceFilter;
        userInput.userInputDescription = @"Type the Distance Filter of Location sensor in meters.";
        userInput.userInputPlaceholder = @"Distance Filter (m)";
        userInput.title = @"Distance Filter";
        userInput.identifier = @"Distance Filter";
        
        // Show the userInput controller
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

- (void)userInputWithIdentifier:(NSString *)identifier withValue:(NSUInteger)value
{
    //self.sampleRateConfiguration.sampleRate = value;
    //[self updateProperties];
}

@end
