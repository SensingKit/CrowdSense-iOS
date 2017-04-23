//
//  CSTestDeviceViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 10/03/2017.
//  Copyright © 2017 Kleomenis Katevas. All rights reserved.
//

#import "CSTestDeviceViewController.h"
#import <SensingKit/SensingKit.h>
#import "CSSensingSession.h"
#import "ALDisk.h"

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
    NSString *folderName = [NSString stringWithFormat:@"TestData_%@", [self.filenameDateFormatter stringFromDate:[NSDate date]]];
    self.sensingSession = [[CSSensingSession alloc] initWithFolderName:folderName];
    
    // These are the sensors to be tested
    self.sensors = @[@(Accelerometer), @(Gyroscope), @(Magnetometer), @(DeviceMotion), @(MotionActivity), @(Pedometer), @(iBeaconProximity), @(Battery), @(Microphone)];
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
    
    if ([segue.destinationViewController respondsToSelector:@selector(setInformation:)]) {
        [segue.destinationViewController setInformation:self.information];
    }
}

- (IBAction)testDeviceAction:(id)sender
{
    NSTimeInterval testingDuration = 5.0; // seconds
    
    // Test Memory
    NSString *testMemoryError = [self testMemory];
    if (testMemoryError){
        [self.errors addObject:testMemoryError];
    }
    
    
    // Test Registration
    NSArray *errors = [self testRegistration];
    if ([self testRegistration]) {
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
    
    // Report
    if (self.errors.count) {
        
        // Report errors
        for (NSString *error in self.errors) {
            [self alertWithTitle:@"Warning" withMessage:error];
        }
        
    }
    else
    {
        // Alert
        [self alertWithTitle:@"Test Passed" withMessage:@"Your device is compatible."];
        
        self.testDeviceButton.enabled = NO;
        self.nextButton.enabled = YES;
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
         return [NSString stringWithFormat:@"Sensor '%@' is not available.", [NSString stringWithSensorType:sensorType]];
    }
    
    // Create the configuration (folder path is only needed in the Microphone sensor)
    SKConfiguration *configuration = [self createConfigurationForSensor:sensorType withFolderPath:self.sensingSession.folderPath];
    
    NSError *error;
    if (![self.sensingSession enableSensor:sensorType withConfiguration:configuration withError:&error]) {
        return error.localizedDescription;
    };
        
    return nil;
}

- (NSString *)testDataCollection
{
    NSError *error;
    if (![self.sensingSession start:&error]) {
        return error.localizedDescription;
    }

    return nil;
}

- (NSString *)testStopDataCollection
{
    NSError *error;
    if (![self.sensingSession stop:&error]) {
        return error.localizedDescription;
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
        return error.localizedDescription;
    };
    
    return nil;
}

- (NSString *)testMemory {
    
    if ([ALDisk freeDiskSpaceInBytes] / 1000000 < 250) {
        return @"Your device does not have enough disk space.";
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

- (void)initSensingInFolderPath:(NSURL *)folderPath
{
    for (NSNumber *sensor in self.sensors) {
        SKSensorType sensorType = sensor.unsignedIntegerValue;
        
        if ([self.sensingSession isSensorAvailable:sensorType]) {
            
            SKConfiguration *configuration = [self createConfigurationForSensor:sensorType withFolderPath:folderPath];
            [self.sensingSession enableSensor:sensorType withConfiguration:configuration withError:nil];
            
        }
    }
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
            SKMicrophoneConfiguration *configuration = [[SKMicrophoneConfiguration alloc] initWithOutputDirectory:folderPath withFilename:@"Microphone"];
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
