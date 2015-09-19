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

- (SKLocationConfiguration *)locationConfiguration
{
    return (SKLocationConfiguration *)self.configuration;
}

- (NSString *)desiredAccuracyString
{
    switch (self.locationConfiguration.locationAccuracy)
    {
        case SKLocationAccuracyBestForNavigation:
            return @"Best for Navigation";
            
        case SKLocationAccuracyBest:
            return @"Best";
            
        case SKLocationAccuracyNearestTenMeters:
            return @"Ten Meters";
            
        case SKLocationAccuracyHundredMeters:
            return @"Hundred Meters";
            
        case SKLocationAccuracyKilometer:
            return @"Kilometer";
            
        case SKLocationAccuracyThreeKilometers:
            return @"Three Kilometers";
            
        default:
            NSLog(@"Unknown SKLocationAccuracy: %lu", (unsigned long)self.locationConfiguration.locationAccuracy);
            abort();
    }
}

- (NSString *)distanceFilterString
{
    if (self.locationConfiguration.distanceFilter == -1)
    {
        return @"None";
    }
    else if (self.locationConfiguration.distanceFilter == 1)
    {
        return [NSString stringWithFormat:@"%lu meter", (long)self.locationConfiguration.distanceFilter];
    }
    else
    {
        return [NSString stringWithFormat:@"%lu meters", (long)self.locationConfiguration.distanceFilter];
    }
}

- (NSString *)desiredAuthorizationString
{
    switch (self.locationConfiguration.locationAuthorization)
    {
        case SKLocationAuthorizationNone:
            return @"None";
            
        case SKLocationAuthorizationWhenInUse:
            return @"When in use";
            
        case SKLocationAuthorizationAlways:
            return @"Always";
            
        default:
            NSLog(@"Unknown SKLocationAuthorization: %lu", (unsigned long)self.locationConfiguration.locationAuthorization);
            abort();
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.textLabel.text isEqualToString:@"Distance Filter"])
    {
        // Configure the userInput controller
        UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"userInput"];
        CSUserInput *userInput = (CSUserInput *)navigationController.topViewController;
        userInput.identifier = @"Distance Filter";
        userInput.delegate = self;
        userInput.mode = CSNUserInputIntegerMode;
        userInput.maxCharacters = 10;
        userInput.minValue = 0;
        userInput.maxValue = 1000000000;
        
        if (self.locationConfiguration.distanceFilter == -1)
        {
            userInput.userInputDefaultValue = nil;
        }
        else
        {
            [NSString stringWithFormat:@"%ld", (long)self.locationConfiguration.distanceFilter];
        }
        
        userInput.userInputDescription = @"Type the Distance Filter of Location sensor in meters.";
        userInput.userInputPlaceholder = @"None";
        userInput.title = @"Distance Filter";
        
        // Show the userInput controller
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

- (void)userInputWithIdentifier:(NSString *)identifier withValue:(NSString *)value
{
    self.locationConfiguration.distanceFilter = value.integerValue;

    [self updateProperties];
}

- (void)updateProperties
{
    // Update the UI
    self.desiredAccuracyLabel.text = self.desiredAccuracyString;
    self.distanceFilterLabel.text = self.distanceFilterString;
    self.authorizationLabel.text = self.desiredAuthorizationString;
}
@end
