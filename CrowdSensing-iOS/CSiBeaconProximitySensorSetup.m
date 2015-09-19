//
//  CSiBeaconProximitySensorSetup.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSiBeaconProximitySensorSetup.h"
#import "CSUserInput.h"

@interface CSiBeaconProximitySensorSetup () <CSNUserInputDelegate>

@end

@implementation CSiBeaconProximitySensorSetup

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

- (SKiBeaconProximityConfiguration *)iBeaconConfiguration
{
    return (SKiBeaconProximityConfiguration *)self.configuration;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.textLabel.text isEqualToString:@"Major Identifier"])
    {
        // Configure the userInput controller
        UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"userInput"];
        CSUserInput *userInput = (CSUserInput *)navigationController.topViewController;
        userInput.identifier = @"Major";
        userInput.delegate = self;
        userInput.mode = CSNUserInputIntegerMode;
        userInput.maxCharacters = 5;
        userInput.minValue = 0;
        userInput.maxValue = 65535;
        userInput.userInputDefaultValue = [NSString stringWithFormat:@"%lu", (long)self.iBeaconConfiguration.major];
        userInput.userInputDescription = @"Type the Distance Filter of Location sensor in meters.";
        userInput.userInputPlaceholder = @"Major";
        userInput.title = @"Major Identifier";
        
        // Show the userInput controller
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    else if ([cell.textLabel.text isEqualToString:@"Minor Identifier"])
    {
        // Configure the userInput controller
        UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"userInput"];
        CSUserInput *userInput = (CSUserInput *)navigationController.topViewController;
        userInput.identifier = @"Minor";
        userInput.delegate = self;
        userInput.mode = CSNUserInputIntegerMode;
        userInput.maxCharacters = 5;
        userInput.minValue = 0;
        userInput.maxValue = 65535;
        userInput.userInputDefaultValue = [NSString stringWithFormat:@"%lu", (long)self.iBeaconConfiguration.minor];
        userInput.userInputDescription = @"Type the Distance Filter of Location sensor in meters.";
        userInput.userInputPlaceholder = @"Minor";
        userInput.title = @"Minor Identifier";
        
        // Show the userInput controller
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    else if ([cell.textLabel.text isEqualToString:@"Measured Power"])
    {
        // Configure the userInput controller
        UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"userInput"];
        CSUserInput *userInput = (CSUserInput *)navigationController.topViewController;
        userInput.identifier = @"Measured Power";
        userInput.delegate = self;
        userInput.mode = CSNUserInputIntegerMode;
        userInput.maxCharacters = 3;
        userInput.minValue = 0;
        userInput.maxValue = 100;
        userInput.userInputDefaultValue = [NSString stringWithFormat:@"%lu", (long)self.iBeaconConfiguration.measuredPower.integerValue];
        userInput.userInputDescription = @"Type the Distance Filter of Location sensor in meters.";
        userInput.userInputPlaceholder = @"Power (dBµ)";
        userInput.title = @"Measured Power";
        
        // Show the userInput controller
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

- (void)userInputWithIdentifier:(NSString *)identifier withValue:(NSString *)value
{
    if ([identifier isEqualToString:@"Major"])
    {
        //self.sampleRateConfiguration.sampleRate = value;
        //[self updateProperties];
    }
    else if ([identifier isEqualToString:@"Minor"])
    {
        
    }
    else if ([identifier isEqualToString:@"Measured Power"])
    {
        
    }
    else
    {
        NSLog(@"Unknown identifier: %@", identifier);
        abort();
    }
}


@end
