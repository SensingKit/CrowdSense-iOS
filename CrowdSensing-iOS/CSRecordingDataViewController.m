//
//  CSRecordingDataViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 10/03/2017.
//  Copyright © 2017 Kleomenis Katevas. All rights reserved.
//

#import "CSRecordingDataViewController.h"
#import "CSSensingSession.h"
#import "CSSubmitDataViewController.h"

@import SensingKit;

@interface CSRecordingDataViewController ()

@property (weak, nonatomic) IBOutlet UIButton *iAmDoneButton;

@property (strong, nonatomic) CSSensingSession *sensingSession;
@property (strong, nonatomic) NSArray *sensors;

@property (strong, nonatomic) NSDateFormatter *filenameDateFormatter;

@end

@implementation CSRecordingDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Init Sensing Session
    NSString *folderName = [NSString stringWithFormat:@"ExperimentData_%@", [self.filenameDateFormatter stringFromDate:[NSDate date]]];
    self.sensingSession = [[CSSensingSession alloc] initWithFolderName:folderName];
    
    [self initSensing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSensing
{
    for (NSNumber *sensor in self.sensors) {
        SKSensorType sensorType = sensor.unsignedIntegerValue;
        
        if ([self.sensingSession isSensorAvailable:sensorType]) {
            
            SKConfiguration *configuration = [self createConfigurationForSensor:sensorType];
            [self.sensingSession enableSensor:sensorType withConfiguration:configuration withError:nil];
        
        }
        
    }
    
    // Stast sensing after one second
    [self performSelector:@selector(startSensing) withObject:nil afterDelay:1.0];
}

- (void)startSensing
{
    // Proximity Monitoring
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Start Sensing
    [self.sensingSession start:nil];
}

- (void)stopSensing
{
    // Proximity Monitoring
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    // Stop Sensing
    [self.sensingSession stop:nil];
    [self.sensingSession disableAllRegisteredSensors:nil];
    [self.sensingSession close];
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

- (NSArray *)sensors
{
    if (!_sensors) {
        _sensors = @[@(Accelerometer), @(Gyroscope), @(Magnetometer), @(DeviceMotion), @(MotionActivity), @(Pedometer), @(Location), @(iBeaconProximity), @(Battery)];
    }
    return _sensors;
}

- (SKConfiguration *)createConfigurationForSensor:(SKSensorType)sensorType
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
            
        case Location:
        {
            SKLocationConfiguration *configuration = [[SKLocationConfiguration alloc] init];
            configuration.locationAuthorization = SKLocationAuthorizationAlways;
            configuration.locationAccuracy = SKLocationAccuracyThreeKilometers;
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
            
        default:
        {
            NSLog(@"Unknown sensorSetupType: %ld", (long)sensorType);
            abort();
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    CSSubmitDataViewController *controller = segue.destinationViewController;
    
    controller.information = self.information;
    controller.picture = self.picture;
    controller.dataPath = self.sensingSession.folderPath;
}

- (IBAction)iAmDoneAction:(id)sender
{
    // Are you sure?
    [self askAreYouDone];
}

- (void)askAreYouDone {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Finish Experiment"
                                          message:@"Are you sure you want to finish your participation?"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"I am sure"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action) {
                                   
                                   [self stopSensing];
                                   
                                   [self performSegueWithIdentifier:@"Show Submit Data" sender:self];
                                   
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    // Show the alert
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
