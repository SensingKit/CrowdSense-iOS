//
//  CSLocationSensorSetup.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSLocationSensorSetup.h"
#import "CSUserInput.h"
#import "CSSelectProperty.h"

@interface CSLocationSensorSetup () <CSUserInputDelegate, CSSelectPropertyDelegate>

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
        
        // Reload TableView (show/hide configuration)
        [self.tableView reloadData];
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
            return @"Best for navigation";
            
        case SKLocationAccuracyBest:
            return @"Best";
            
        case SKLocationAccuracyNearestTenMeters:
            return @"Ten meters";
            
        case SKLocationAccuracyHundredMeters:
            return @"Hundred meters";
            
        case SKLocationAccuracyKilometer:
            return @"Kilometer";
            
        case SKLocationAccuracyThreeKilometers:
            return @"Three kilometers";
            
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 44;
    }
    else
    {
        if (!self.sensorSwitch.on)
        {
            return 0;
        }
        else
        {
            return 44;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.textLabel.text isEqualToString:@"Desired Accuracy"])
    {
        // Configure the selectProperty controller
        CSSelectProperty *selectProperty = [self.storyboard instantiateViewControllerWithIdentifier:@"selectProperty"];
        selectProperty.identifier = @"Desired Accuracy";
        selectProperty.delegate = self;
        selectProperty.elements = @[@"Best for navigation", @"Best", @"Ten meters", @"Hundred meters", @"Kilometer", @"Three kilometers"];
        selectProperty.selectedIndex = self.locationConfiguration.locationAccuracy;
        selectProperty.title = @"Desired Accuracy";
        
        // Show the userInput controller
        [self.navigationController pushViewController:selectProperty animated:YES];
    }
    else if ([cell.textLabel.text isEqualToString:@"Distance Filter"])
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
        userInput.noneValueAllowed = YES;
        
        if (self.locationConfiguration.distanceFilter == -1)
        {
            userInput.userInputDefaultValue = nil;
        }
        else
        {
            userInput.userInputDefaultValue = [NSString stringWithFormat:@"%ld", (long)self.locationConfiguration.distanceFilter];
        }
        
        userInput.userInputDescription = @"Type the Sample Rate of Distance Filter of Location sensor in meters.";
        userInput.userInputPlaceholder = @"None";
        userInput.title = @"Distance Filter";
        
        // Show the userInput controller
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    else if ([cell.textLabel.text isEqualToString:@"Authorization"])
    {
        // Configure the selectProperty controller
        CSSelectProperty *selectProperty = [self.storyboard instantiateViewControllerWithIdentifier:@"selectProperty"];
        selectProperty.identifier = @"Authorization";
        selectProperty.delegate = self;
        selectProperty.elements = @[@"None", @"When in use", @"Always"];
        selectProperty.selectedIndex = self.locationConfiguration.locationAuthorization;
        selectProperty.title = @"Desired Accuracy";
        
        // Show the userInput controller
        [self.navigationController pushViewController:selectProperty animated:YES];
    }
}

- (void)selectPropertyWithIdentifier:(NSString *)identifier withIndex:(NSUInteger)index withValue:(NSString *)value
{
    if ([identifier isEqualToString:@"Desired Accuracy"])
    {
        SKLocationAccuracy locationAccuracy = index;
        self.locationConfiguration.locationAccuracy = locationAccuracy;
    }
    else if ([identifier isEqualToString:@"Authorization"])
    {
        SKLocationAuthorization locationAuthorization = index;
        self.locationConfiguration.locationAuthorization = locationAuthorization;
    }
    else
    {
        NSLog(@"Unknown identifier: %@", identifier);
        abort();
    }

    [self updateConfiguration];
    [self updateProperties];
}

- (void)userInputWithIdentifier:(NSString *)identifier withValue:(NSString *)value
{
    if (!value)
    {
        self.locationConfiguration.distanceFilter = -1;
    }
    else
    {
        self.locationConfiguration.distanceFilter = value.integerValue;
    }

    [self updateConfiguration];
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
