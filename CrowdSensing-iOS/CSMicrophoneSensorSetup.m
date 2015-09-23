//
//  CSMicrophoneSensorSetup.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 17/09/2015.
//  Copyright © 2015 Kleomenis Katevas. All rights reserved.
//

#import "CSMicrophoneSensorSetup.h"
#import "CSUserInput.h"
#import "CSSelectProperty.h"

@interface CSMicrophoneSensorSetup () <CSUserInputDelegate, CSSelectPropertyDelegate>

@end

@implementation CSMicrophoneSensorSetup

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
    
    // Reload TableView (show/hide configuration)
    [self.tableView reloadData];
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

- (NSString *)recordingFormatString
{
    switch (self.microphoneConfiguration.recordingFormat)
    {
        case SKMicrophoneRecordingFormatLinearPCM:
            return @"PCM";
            
        case SKMicrophoneRecordingFormatMPEG4AAC:
            return @"AAC";
            
        default:
            NSLog(@"Unknown SKMicrophoneRecordingFormat: %lu", (unsigned long)self.microphoneConfiguration.recordingFormat);
            abort();
    }
}

- (NSString *)recordingQualityString
{
    switch (self.microphoneConfiguration.recordingQuality)
    {
        case SKMicrophoneRecordingQualityMin:
            return @"Min";
            
        case SKMicrophoneRecordingQualityLow:
            return @"Low";
            
        case SKMicrophoneRecordingQualityMedium:
            return @"Medium";
            
        case SKMicrophoneRecordingQualityHigh:
            return @"High";
            
        case SKMicrophoneRecordingQualityMax:
            return @"Max";
            
        default:
            NSLog(@"Unknown SKMicrophoneRecordingQuality: %lu", (unsigned long)self.microphoneConfiguration.recordingQuality);
            abort();
    }
}

- (NSString *)sampleRateString
{
    return [NSString stringWithFormat:@"%.01f Hz", self.microphoneConfiguration.sampleRate];
}

- (SKMicrophoneConfiguration *)microphoneConfiguration
{
    return (SKMicrophoneConfiguration *)self.configuration;
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
    
    if ([cell.textLabel.text isEqualToString:@"Recording Format"])
    {
        // Configure the selectProperty controller
        CSSelectProperty *selectProperty = [self.storyboard instantiateViewControllerWithIdentifier:@"selectProperty"];
        selectProperty.identifier = @"Recording Format";
        selectProperty.delegate = self;
        selectProperty.elements = @[@"PCM", @"AAC"];
        selectProperty.selectedIndex = self.microphoneConfiguration.recordingFormat;
        selectProperty.title = @"Recording Format";
        
        // Show the userInput controller
        [self.navigationController pushViewController:selectProperty animated:YES];
    }
    else if ([cell.textLabel.text isEqualToString:@"Recording Quality"])
    {
        // Configure the selectProperty controller
        CSSelectProperty *selectProperty = [self.storyboard instantiateViewControllerWithIdentifier:@"selectProperty"];
        selectProperty.identifier = @"Recording Quality";
        selectProperty.delegate = self;
        selectProperty.elements = @[@"Min", @"Low", @"Medium", @"High", @"Max"];
        selectProperty.selectedIndex = self.microphoneConfiguration.recordingQuality;
        selectProperty.title = @"Recording Quality";
        
        // Show the userInput controller
        [self.navigationController pushViewController:selectProperty animated:YES];
    }
    else if ([cell.textLabel.text isEqualToString:@"Sample Rate"])
    {
        // Configure the userInput controller
        UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"userInput"];
        CSUserInput *userInput = (CSUserInput *)navigationController.topViewController;
        userInput.identifier = @"Sample Rate";
        userInput.delegate = self;
        userInput.mode = CSNUserInputIntegerMode;
        userInput.maxCharacters = 5;
        userInput.minValue = 8000;
        userInput.maxValue = 48000;
        userInput.noneValueAllowed = NO;
        userInput.userInputDefaultValue = [NSString stringWithFormat:@"%.0f", self.microphoneConfiguration.sampleRate];
        userInput.userInputDescription = @"Type the Sample Rate of Microphone sensor in Hz.";
        userInput.userInputPlaceholder = @"Sample Rate (Hz)";
        userInput.title = @"Sample Rate";
        
        // Show the userInput controller
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

- (void)updateProperties
{
    // Update the UI
    self.recordingFormatLabel.text = self.recordingFormatString;
    self.recordingQualityLabel.text = self.recordingQualityString;
    self.sampleRateLabel.text = self.sampleRateString;
}
    
- (void)selectPropertyWithIdentifier:(NSString *)identifier withIndex:(NSUInteger)index withValue:(NSString *)value
{
    if ([identifier isEqualToString:@"Recording Format"])
    {
        SKMicrophoneRecordingFormat recordingFormat = index;
        self.microphoneConfiguration.recordingFormat = recordingFormat;
    }
    else if ([identifier isEqualToString:@"Recording Quality"])
    {
        SKMicrophoneRecordingQuality recordingQuality = index;
        self.microphoneConfiguration.recordingQuality = recordingQuality;
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
    if ([identifier isEqualToString:@"Sample Rate"])
    {
        self.microphoneConfiguration.sampleRate = value.floatValue;
    }
    else
    {
        NSLog(@"Unknown identifier: %@", identifier);
        abort();
    }
    
    [self updateConfiguration];
    [self updateProperties];
}

@end
