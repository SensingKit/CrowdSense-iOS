//
//  CSSamplingRateSensorSetup.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSSamplingRateSensorSetup.h"
#import "CSNumericUserInput.h"

@interface CSSamplingRateSensorSetup () <CSNumericUserInputDelegate>

@end

@implementation CSSamplingRateSensorSetup

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.textLabel.text isEqualToString:@"Sample Rate"])
    {
        // Configure the userInput controller
        UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"userInput"];
        CSNumericUserInput *userInput = (CSNumericUserInput *)navigationController.topViewController;
        userInput.delegate = self;
        userInput.maxDigits = 3;
        userInput.minValue = 1;
        userInput.maxValue = 100;
        userInput.defaultValue = self.sampleRateConfiguration.sampleRate;
        userInput.userInputDescription = @"Type the Sample Rate of the selected sensor in Hz.";
        userInput.userInputPlaceholder = @"Sample Rate (Hz)";
        userInput.title = @"Sample Rate";
        
        // Show the userInput controller
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

- (SKSampleRateConfiguration *)sampleRateConfiguration
{
    return (SKSampleRateConfiguration *)self.configuration;
}

- (void)userInputWithValue:(NSUInteger)value
{
    self.sampleRateConfiguration.sampleRate = value;
    [self updateProperties];
}

- (void)updateProperties
{
    NSUInteger sampleRate = self.sampleRateConfiguration.sampleRate;
    
    // Update the UI
    self.samplingRateLabel.text = [NSString stringWithFormat:@"%lu Hz", (long)sampleRate];
}

@end
