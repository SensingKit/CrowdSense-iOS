//
//  CSiBeaconProximitySensorSetup.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSiBeaconProximitySensorSetup.h"
#import "CSUserInput.h"
#import "CSSelectProperty.h"

@interface CSiBeaconProximitySensorSetup () <CSUserInputDelegate, CSSelectPropertyDelegate>

@end

@implementation CSiBeaconProximitySensorSetup

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the label from title
    self.sensorLabel.text = self.title;
    
    // Update sensor properties
    [self updateSensorSwitch];
    [self updateProperties];
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

- (NSString *)sensorModeString
{
    switch (self.iBeaconConfiguration.mode)
    {
        case SKiBeaconProximityModeScanOnly:
            return @"Scan only";
            
        case SKiBeaconProximityModeBroadcastOnly:
            return @"Broadcast only";
            
        case SKiBeaconProximityModeScanAndBroadcast:
            return @"Scan and Broadcast";
            
        default:
            NSLog(@"Unknown SKLocationAccuracy: %lu", (unsigned long)self.iBeaconConfiguration.mode);
            abort();
    }
}

- (NSString *)majorString
{
    return [NSString stringWithFormat:@"%lu", (long)self.iBeaconConfiguration.major];
}

- (NSString *)minorString
{
    return [NSString stringWithFormat:@"%lu", (long)self.iBeaconConfiguration.minor];
}

- (NSString *)measuredPowerString
{
    if (self.iBeaconConfiguration.measuredPower)
    {
        return [NSString stringWithFormat:@"%lu", (unsigned long)self.iBeaconConfiguration.measuredPower.unsignedIntegerValue];
    }
    else
    {
        return @"Default";
    }
}

- (SKiBeaconProximityConfiguration *)iBeaconConfiguration
{
    return (SKiBeaconProximityConfiguration *)self.configuration;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.textLabel.text isEqualToString:@"Sensor Mode"])
    {
        // Configure the selectProperty controller
        CSSelectProperty *selectProperty = [self.storyboard instantiateViewControllerWithIdentifier:@"selectProperty"];
        selectProperty.identifier = @"Sensor Mode";
        selectProperty.delegate = self;
        selectProperty.elements = @[@"Scan only", @"Broadcast only", @"Scan and Broadcast"];
        selectProperty.selectedIndex = self.iBeaconConfiguration.mode;
        selectProperty.title = @"Sensor Mode";
        
        // Show the userInput controller
        [self.navigationController pushViewController:selectProperty animated:YES];
    }
    else if ([cell.textLabel.text isEqualToString:@"Major Identifier"])
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
        userInput.noneValueAllowed = NO;
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
        userInput.noneValueAllowed = NO;
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
        userInput.noneValueAllowed = YES;
        
        if (self.iBeaconConfiguration.measuredPower)
        {
            userInput.userInputDefaultValue = [NSString stringWithFormat:@"%lu", (long)self.iBeaconConfiguration.measuredPower.integerValue];
        }
        else
        {
            userInput.userInputDefaultValue = nil;
        }
        
        userInput.userInputDescription = @"Type the Distance Filter of Location sensor in meters.";
        userInput.userInputPlaceholder = @"Default";
        userInput.title = @"Measured Power";
        //Power (dBµ)
        
        // Show the userInput controller
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

- (void)selectPropertyWithIdentifier:(NSString *)identifier withIndex:(NSUInteger)index withValue:(NSString *)value
{
    if ([identifier isEqualToString:@"Sensor Mode"])
    {
        SKiBeaconProximityMode mode = index;
        self.iBeaconConfiguration.mode = mode;
    }
    else
    {
        NSLog(@"Unknown identifier: %@", identifier);
        abort();
    }
    
    [self updateProperties];
}

- (void)userInputWithIdentifier:(NSString *)identifier withValue:(NSString *)value
{
    if ([identifier isEqualToString:@"Major"])
    {
        self.iBeaconConfiguration.major = value.integerValue;
    }
    else if ([identifier isEqualToString:@"Minor"])
    {
        self.iBeaconConfiguration.minor = value.integerValue;
    }
    else if ([identifier isEqualToString:@"Measured Power"])
    {
        if (value)
        {
            self.iBeaconConfiguration.measuredPower = @(value.integerValue);
        }
        else
        {
            self.iBeaconConfiguration.measuredPower = nil;
        }
    }
    else
    {
        NSLog(@"Unknown identifier: %@", identifier);
        abort();
    }
    
    [self updateProperties];
}

- (void)updateProperties
{
    // Update the UI
    self.sensorMode.text = self.sensorModeString;
    self.majorLabel.text = self.majorString;
    self.minorLabel.text = self.minorString;
    self.measuredPowerLabel.text = self.measuredPowerString;
}

@end
