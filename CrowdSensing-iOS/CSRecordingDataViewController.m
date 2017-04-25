//
//  CSRecordingDataViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 10/03/2017.
//  Copyright © 2017 Kleomenis Katevas. All rights reserved.
//

#import "CSRecordingDataViewController.h"
#import "CSSubmitDataViewController.h"

@import SensingKit;

@interface CSRecordingDataViewController ()

@property (weak, nonatomic) IBOutlet UIButton *iAmDoneButton;

@property (strong, nonatomic) NSArray *sensors;

@end

@implementation CSRecordingDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationItem setHidesBackButton:YES];
    
    [self initSensors];
}

- (void)initSensors
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
}

- (NSArray *)sensors
{
    if (!_sensors) {
        _sensors = @[@(Accelerometer), @(Gyroscope), @(Magnetometer), @(DeviceMotion), @(MotionActivity), @(Pedometer), @(iBeaconProximity), @(Battery)];
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
    
    CSSubmitDataViewController *controller = (CSSubmitDataViewController *)segue.destinationViewController;
    controller.type = self.type;
    controller.sensingSession = self.sensingSession;
    controller.information = self.information;
    controller.picture = self.picture;
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
