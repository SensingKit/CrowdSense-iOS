//
//  CSTestDeviceViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 10/03/2017.
//  Copyright © 2017 Kleomenis Katevas. All rights reserved.
//

#import "CSTestDeviceViewController.h"
#import <SensingKit/SensingKit.h>
#import "ALDisk.h"

@interface CSTestDeviceViewController ()

@property (weak, nonatomic) IBOutlet UIButton *testDeviceButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (strong, nonatomic) SensingKitLib *sensingKit;

@property (strong, nonatomic) NSArray *sensors;

@end

@implementation CSTestDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sensingKit = [SensingKitLib sharedSensingKitLib];
    
    // These are the sensors to be tested
    self.sensors = @[@(Accelerometer), @(Gyroscope), @(Magnetometer), @(DeviceMotion), @(MotionActivity), @(Pedometer), @(Location), @(iBeaconProximity), @(Battery), @(Microphone)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    // Init a mutable array that will hold all reported erros
    NSMutableArray *allErrors = [[NSMutableArray alloc] initWithCapacity:40];
    
    // Array per test
    NSArray *errors;
    
    // Test Registration
    errors = [self testRegistration];
    if (errors) {
        [allErrors addObjectsFromArray:errors];
    }
    
    // Test DataCollection
    errors = [self testDataCollection];
    if (errors) {
        [allErrors addObjectsFromArray:errors];
    }
    
    // Test Deregistration
    errors = [self testDeregistration];
    if (errors) {
        [allErrors addObjectsFromArray:errors];
    }
    
    // Test Memory
    NSString *testMemory = [self testMemory];
    if (testMemory){
        [allErrors addObject:testMemory];
    }
    
    // Report
    if (allErrors.count) {
        
        // Report errors
        for (NSString *error in allErrors) {
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
    
    if (![self.sensingKit isSensorAvailable:sensorType]) {
         return [NSString stringWithFormat:@"Sensor '%@' is not available.", [NSString stringWithSensorType:sensorType]];
    }
    
    NSError *error;
    if (![self.sensingKit registerSensor:sensorType error:&error]) {
        return error.localizedDescription;
    };
        
    return nil;
}

- (NSArray *)testDataCollection
{
    // Array that will hold a list of errors (hopefully will remain empty)
    NSMutableArray *errorArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    for (NSNumber *sensor in self.sensors) {
        
        SKSensorType sensorType = sensor.unsignedIntegerValue;
        
        // Test registration
        NSString *errorString = [self testSensorDataCollection:sensorType];
        
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

- (NSString *)testSensorDataCollection:(SKSensorType)sensorType {
    
    if ([self.sensingKit isSensorRegistered:sensorType]) {
    
        NSError *error;
        if (![self.sensingKit subscribeToSensor:sensorType withHandler:^(SKSensorType sensorType, SKSensorData * _Nullable sensorData, NSError * _Nullable error) {
            // Nothing
        } error:&error]) {
            return error.localizedDescription;
        }
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
    if (![self.sensingKit deregisterSensor:sensorType error:&error]) {
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

@end
