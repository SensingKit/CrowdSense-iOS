//
//  CSTestDeviceViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 10/03/2017.
//  Copyright © 2017 Kleomenis Katevas. All rights reserved.
//

#import "CSTestDeviceViewController.h"
#import "CSConsentFormViewController.h"
#import "CSSubmitDataViewController.h"
#import "CSTestReportingViewController.h"

#import <SensingKit/SensingKit.h>
#import "CSSensingSession.h"

#import "ALDisk.h"

@import AVFoundation;
@import CoreBluetooth;

@interface CSTestDeviceViewController ()

@property (weak, nonatomic) IBOutlet UIButton *testDeviceButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (strong, nonatomic) CSSensingSession *sensingSession;
@property (strong, nonatomic) NSDateFormatter *filenameDateFormatter;

@property (strong, nonatomic) NSArray *sensors;
@property (strong, nonatomic) NSMutableArray *errors;

@end

@implementation CSTestDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.errors = [[NSMutableArray alloc] initWithCapacity:40];
    
    // Init Sensing Session
    NSString *folderName = [NSString stringWithFormat:@"ExperimentData_%@", [self.filenameDateFormatter stringFromDate:[NSDate date]]];
    self.sensingSession = [[CSSensingSession alloc] initWithFolderName:folderName];
    
    // These are the sensors to be tested
    self.sensors = @[@(Accelerometer), @(Gyroscope), @(Magnetometer), @(Heading), @(DeviceMotion), @(MotionActivity), @(Pedometer), @(iBeaconProximity), @(Battery), @(Microphone)];
}

- (NSDateFormatter *)filenameDateFormatter
{
    if (!_filenameDateFormatter)
    {
        _filenameDateFormatter = [[NSDateFormatter alloc] init];
        _filenameDateFormatter.dateFormat = @"yyyy_MM_dd_HH_mm_ss";
        _filenameDateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
        _filenameDateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    }
    return _filenameDateFormatter;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"Show Consent Form"]) {
        
        CSConsentFormViewController *controller = (CSConsentFormViewController *)segue.destinationViewController;
        controller.type = self.type;
        controller.sensingSession = self.sensingSession;
        controller.information = self.information;
    }
    else if ([segue.identifier isEqualToString:@"Show Submit Data"]) {
        
        CSSubmitDataViewController *controller = (CSSubmitDataViewController *)segue.destinationViewController;
        controller.type = self.type;
        controller.sensingSession = self.sensingSession;
        controller.information = self.information;
    }
    else if ([segue.identifier isEqualToString:@"Report Errors"]) {
        
        CSTestReportingViewController *controller = (CSTestReportingViewController *)segue.destinationViewController;
        controller.errors = self.errors;
    }
}

- (IBAction)nextButtonAction:(id)sender
{
    if ([self.type isEqualToString:@"Test"]) {
        [self performSegueWithIdentifier:@"Show Submit Data" sender:self];
    }
    else if ([self.type isEqualToString:@"Experiment"]) {
        [self performSegueWithIdentifier:@"Show Consent Form" sender:self];
    }
}

- (IBAction)testDeviceAction:(id)sender
{
    self.testDeviceButton.enabled = NO;
    
    NSTimeInterval testingDuration = 30.0; // seconds
    
    // Test Memory
    NSString *testMemoryError = [self testMemory];
    if (testMemoryError){
        [self.errors addObject:testMemoryError];
    }
    
    // Test Registration
    NSArray *errors = [self testRegistration];
    if (errors) {
        [self.errors addObjectsFromArray:errors];
    }
    
    // Test DataCollection
    NSString *error = [self testDataCollection];
    if (error) {
        [self.errors addObject:error];
    }

    // Schedule a stop in testingDuration seconds
    [self performSelector:@selector(stopSensors) withObject:self afterDelay:testingDuration];
}

- (void)stopSensors
{
    // Test Stop
    NSString *error = [self testStopDataCollection];
    if (error) {
        [self.errors addObject:error];
    }
    
    // Test Deregistration
    NSArray *errors = [self testDeregistration];
    if (errors) {
        [self.errors addObjectsFromArray:errors];
    }
    
    // Close session
    [self.sensingSession close];
    
    // Test Permissions
    errors = [self testPermissions];
    if (errors) {
        [self.errors addObjectsFromArray:errors];
    }
    
    // Report
    if (self.errors.count) {
        
        [self performSegueWithIdentifier:@"Report Errors" sender:self];
        
    }
    else
    {
        // Alert
        [self alertWithTitle:@"Test Passed" withMessage:@"Your device is compatible. Please tap at 'Next' button to continue."];
        
        self.nextButton.enabled = YES;
    }
    
    self.testDeviceButton.hidden = YES;
}

 - (NSArray *)testPermissions
{
    // Array that will hold a list of errors (hopefully will remain empty)
    NSMutableArray *errorArray = [[NSMutableArray alloc] initWithCapacity:5];
    
    // Check Microphone permission
    if ([AVAudioSession sharedInstance].recordPermission == AVAudioSessionRecordPermissionDenied) {
        [errorArray addObject:@"- Microphone permission is denied. Please visit Settings > Privacy > Microphone and enable the access for the app CrowdSense."];
    }
    else if ([AVAudioSession sharedInstance].recordPermission == AVAudioSessionRecordPermissionUndetermined) {
        [errorArray addObject:@"- Microphone permission is undetermined."];
    }
    // else all ok (AVAudioSessionRecordPermissionGranted)
    
    
    // Check Location permission
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [errorArray addObject:@"- Location Services permission is undetermined."];
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        [errorArray addObject:@"- Location Services permission is restricted. Please visit Settings > Privacy > Location Services and change the access for the app CrowdSense to 'While Using the App' or 'Always'."];
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [errorArray addObject:@"- Location Services permission is denied. Please visit Settings > Privacy > Location Services and change the access for the app CrowdSense to 'While Using the App' or 'Always'."];
    }
    // else all ok
    
    
    // Check Motion permission
    // Not possible at the moment
    
    
    // return
    if (errorArray.count) {
        return errorArray;
    }
    else {
        return nil;
    }
}

- (NSArray *)testRegistration
{
    // Array that will hold a list of errors (hopefully will remain empty)
    NSMutableArray *errorArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    for (NSNumber *sensor in self.sensors) {
        
        SKSensorType sensorType = sensor.unsignedIntegerValue;
        
        // Test registration
        NSString *errorString = [self testSensorRegistration:sensorType];
        
        // In case an error occured, append it to the list
        if (errorString) {
            [errorArray addObject:errorString];
        }
    }
    
    // return
    if (errorArray.count) {
        return errorArray;
    }
    else {
        return nil;
    }
}

- (NSString *)testSensorRegistration:(SKSensorType)sensorType {
    
    if (![self.sensingSession isSensorAvailable:sensorType]) {
         return [NSString stringWithFormat:@"- Sensor '%@' is not available.", [NSString stringWithSensorType:sensorType]];
    }
    
    // Create the configuration (folder path is only needed in the Microphone sensor)
    SKConfiguration *configuration = [self createConfigurationForSensor:sensorType withFolderPath:self.sensingSession.folderPath];
    
    NSError *error;
    if (![self.sensingSession enableSensor:sensorType withConfiguration:configuration withError:&error]) {
        return [NSString stringWithFormat:@"- %@", error.localizedDescription];
    };
        
    return nil;
}

- (NSString *)testDataCollection
{
    NSError *error;
    if (![self.sensingSession start:&error]) {
        return [NSString stringWithFormat:@"- %@", error.localizedDescription];
    }

    return nil;
}

- (NSString *)testStopDataCollection
{
    NSError *error;
    if (![self.sensingSession stop:&error]) {
        return [NSString stringWithFormat:@"- %@", error.localizedDescription];
    }
    
    return nil;
}

- (NSArray *)testDeregistration
{
    // Array that will hold a list of errors (hopefully will remain empty)
    NSMutableArray *errorArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    for (NSNumber *sensor in self.sensors) {
        
        SKSensorType sensorType = sensor.unsignedIntegerValue;
        
        // Test registration
        NSString *errorString = [self testSensorDeregistration:sensorType];
        
        // In case an error occured, append it to the list
        if (errorString) {
            [errorArray addObject:errorString];
        }
    }
    
    // return
    if (errorArray.count) {
        return errorArray;
    }
    else {
        return nil;
    }
}

- (NSString *)testSensorDeregistration:(SKSensorType)sensorType {
    
    NSError *error;
    if (![self.sensingSession disableSensor:sensorType withError:&error]) {
        return [NSString stringWithFormat:@"- %@", error.localizedDescription];
    };
    
    return nil;
}

- (NSString *)testMemory {
    
    if ([ALDisk freeDiskSpaceInBytes] / 1000000 < 300) {
        return @"- Your device does not have enough disk space. Please free up some space and try again.";
    }
    
    return nil;
}

- (void)alertWithTitle:(NSString *)title withMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    
    [alert show];
}

- (SKConfiguration *)createConfigurationForSensor:(SKSensorType)sensorType withFolderPath:(NSURL *)folderPath
{
    NSUInteger sampleRate = 100;
    
    switch (sensorType) {
            
        case Accelerometer:
        {
            SKAccelerometerConfiguration *configuration = [[SKAccelerometerConfiguration alloc] init];
            configuration.sampleRate = sampleRate;
            return configuration;
        }
            
        case Gyroscope:
        {
            SKGyroscopeConfiguration *configuration = [[SKGyroscopeConfiguration alloc] init];
            configuration.sampleRate = sampleRate;
            return configuration;
        }
            
        case Magnetometer:
        {
            SKMagnetometerConfiguration *configuration = [[SKMagnetometerConfiguration alloc] init];
            configuration.sampleRate = sampleRate;
            return configuration;
        }
            
        case Heading:
        {
            SKHeadingConfiguration *configuration = [[SKHeadingConfiguration alloc] init];
            configuration.displayHeadingCalibration = YES;
            return configuration;
        }
            
        case DeviceMotion:
        {
            SKDeviceMotionConfiguration *configuration = [[SKDeviceMotionConfiguration alloc] init];
            configuration.sampleRate = sampleRate;
            return configuration;
        }
            
        case MotionActivity:
        {
            SKMotionActivityConfiguration *configuration = [[SKMotionActivityConfiguration alloc] init];
            return configuration;
        }
            
        case Pedometer:
        {
            SKPedometerConfiguration *configuration = [[SKPedometerConfiguration alloc] init];
            return configuration;
        }
            
        case iBeaconProximity:
        {
            SKiBeaconProximityConfiguration *configuration = [[SKiBeaconProximityConfiguration alloc] initWithUUID:[[NSUUID alloc] initWithUUIDString:@"eeb79aec-022f-4c05-8331-93d9b2ba6dce"]];
            configuration.mode = SKiBeaconProximityModeScanOnly;
            return configuration;
        }
            
        case Battery:
        {
            SKBatteryConfiguration *configuration = [[SKBatteryConfiguration alloc] init];
            return configuration;
        }
            
        case Microphone:
        {
            SKMicrophoneConfiguration *configuration = [[SKMicrophoneConfiguration alloc] initWithOutputDirectory:folderPath withFilename:@"Test"];
            return configuration;
        }
            
        default:
        {
            NSLog(@"Unknown sensorSetupType: %ld", (long)sensorType);
            abort();
        }
    }
}


@end
