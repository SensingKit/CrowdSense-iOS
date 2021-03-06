//
//  CSEddystoneProximitySensorSetup.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 17/09/2015.
//  Copyright © 2015 Kleomenis Katevas. All rights reserved.
//

#import "CSEddystoneProximitySensorSetup.h"
#import "CSUserInput.h"

@interface CSEddystoneProximitySensorSetup () <CSUserInputDelegate>

@end

@implementation CSEddystoneProximitySensorSetup

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

- (NSString *)sensorModeString
{
    switch (self.eddystoneConfiguration.mode)
    {
        case SKEddystoneProximityModeScanOnly:
            return @"Scan Only";
            
        default:
            NSLog(@"Unknown SKEddystoneProximityMode: %lu", (unsigned long)self.eddystoneConfiguration.mode);
            abort();
    }
}

- (NSString *)namespaceFilterString
{
    if (self.eddystoneConfiguration.namespaceFilter)
    {
        return self.eddystoneConfiguration.namespaceFilter;
    }
    else
    {
        return @"None";
    }
}

- (SKEddystoneProximityConfiguration *)eddystoneConfiguration
{
    return (SKEddystoneProximityConfiguration *)self.configuration;
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
    
    if ([cell.textLabel.text isEqualToString:@"Namespace Filter"])
    {
        // Configure the userInput controller
        UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"userInput"];
        CSUserInput *userInput = (CSUserInput *)navigationController.topViewController;
        userInput.identifier = @"Namespace Filter";
        userInput.delegate = self;
        userInput.mode = CSNUserInputHexMode;
        userInput.maxCharacters = 20;
        userInput.noneValueAllowed = YES;
        userInput.userInputDefaultValue = self.eddystoneConfiguration.namespaceFilter;
        userInput.userInputDescription = @"Type the Namespace Filter of the Eddystone™ Proximity sensor in hexadecimal format. Leave the filter to None for scanning all Eddystone™ beacons in range.";
        userInput.userInputPlaceholder = @"None";
        userInput.title = @"Namespace Filter";
        
        // Show the userInput controller
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

- (void)userInputWithIdentifier:(NSString *)identifier withValue:(NSString *)value
{
    [self.eddystoneConfiguration setNamespaceFilter:value.lowercaseString error:NULL];
    
    [self updateConfiguration];
    [self updateProperties];
}

- (void)updateProperties
{
    // Update the UI
    self.sensorModeLabel.text = self.sensorModeString;
    self.namespaceFilterLabel.text = self.namespaceFilterString;
}

@end
