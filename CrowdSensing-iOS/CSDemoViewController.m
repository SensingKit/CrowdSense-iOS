//
//  CSDemoViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 11/06/2017.
//  Copyright © 2017 Kleomenis Katevas. All rights reserved.
//

#import "CSDemoViewController.h"
@import SensingKit;

@interface CSDemoViewController () <NSStreamDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *joinDemoSwitch;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *serverTextField;

@property (nonatomic, strong) SensingKitLib *sensingKit;

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;

@property (nonatomic) BOOL connected;
@property (nonatomic) NSUInteger deviceID;

@end

@implementation CSDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sensingKit = [SensingKitLib sharedSensingKitLib];
    
    [self initSensing];
}

- (IBAction)finishDemo:(id)sender
{
    // TODO: Check if sensing
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initSensing
{
    [self initBeaconSensing];
    [self initHeadingSensing];
}

- (void)initBeaconSensing
{
    if (![self.sensingKit isSensorAvailable:iBeaconProximity]) {
        [self alertWithTitle:@"Error" withMessage:@"iBeaconProximity sensor is not available in your device."];
        return;
    }
    
    SKiBeaconProximityConfiguration *configuration = [[SKiBeaconProximityConfiguration alloc] initWithUUID:[[NSUUID alloc] initWithUUIDString:@"eeb79aec-022f-4c05-8331-93d9b2ba6dce"]];
    configuration.mode = SKiBeaconProximityModeScanAndBroadcast;
    configuration.major = 100;
    configuration.minor = 42;
    
    NSError *error;
    [self.sensingKit registerSensor:iBeaconProximity withConfiguration:configuration error:&error];
    
    if (error) {
        // Error
        [self alertWithTitle:@"Error" withMessage:error.localizedDescription];
        return;
    }
    
    [self.sensingKit subscribeToSensor:iBeaconProximity withHandler:^(SKSensorType sensorType, SKSensorData * _Nullable sensorData, NSError * _Nullable error) {
        
        if (!error) {
            NSString *data = [NSString stringWithFormat:@"%@,%@", @"iBeaconProximity", sensorData.csvString];
            [self sendData:data];
        }
        
    } error:&error];
    
    if (error) {
        [self alertWithTitle:@"Error" withMessage:error.localizedDescription];
        return;
    }
}

- (void)initHeadingSensing
{
    if (![self.sensingKit isSensorAvailable:Heading]) {
        [self alertWithTitle:@"Error" withMessage:@"Heading sensor is not available in your device."];
        return;
    }
    
    SKHeadingConfiguration *configuration = [[SKHeadingConfiguration alloc] init];
    configuration.displayHeadingCalibration = YES;
    
    NSError *error;
    [self.sensingKit registerSensor:Heading withConfiguration:configuration error:&error];
    
    if (error) {
        [self alertWithTitle:@"Error" withMessage:error.localizedDescription];
        return;
    }
    
    [self.sensingKit subscribeToSensor:Heading withHandler:^(SKSensorType sensorType, SKSensorData * _Nullable sensorData, NSError * _Nullable error) {
        
        if (!error) {
            NSString *data = [NSString stringWithFormat:@"%@,%@", @"Heading", sensorData.csvString];
            [self sendData:data];
        }
        
    } error:&error];
    
    if (error) {
        [self alertWithTitle:@"Error" withMessage:error.localizedDescription];
        return;
    }
}

#pragma mark Streaming Communication

- (void)initNetworkCommunication
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    NSString *ip = self.serverTextField.text;
    
    if (!ip)
    {
        self.connected = NO;
        return;
    }
    
    self.connected = YES;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ip, 50006, &readStream, &writeStream);
    self.inputStream = (__bridge NSInputStream *)readStream;
    self.outputStream = (__bridge NSOutputStream *)writeStream;
    
    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];
    
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.inputStream open];
    [self.outputStream open];
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)streamEvent
{
    switch (streamEvent) {
            
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            break;
            
        case NSStreamEventHasBytesAvailable:
            
            if (stream == self.inputStream) {
                
                uint8_t buffer[1024];
                NSInteger len;
                
                while ([self.inputStream hasBytesAvailable]) {
                    len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
                            
                            [self messageReceived:output];
                        }
                    }
                }
            }
            
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"Can not connect to the host!");
            break;
            
        case NSStreamEventEndEncountered:
            break;
            
        default:
            break;
    }
}

- (void)messageReceived:(NSString *)message
{
    NSLog(@"Server said %@", message);
    self.deviceID = message.integerValue;
    [self registerSensorsWithDeviceID:self.deviceID];
}

- (void)sendData:(NSString *)stringData
{
    NSData *data = [[NSData alloc] initWithData:[stringData dataUsingEncoding:NSASCIIStringEncoding]];
    [self.outputStream write:[data bytes] maxLength:[data length]];
}

- (NSString *)getName
{
    if (self.nameTextField.text.length > 0)
    {
        return self.nameTextField.text;
    }
    else
    {
        return @"Unknown User";
    }
}

#pragma mark MobileSensing

- (void)registerSensorsWithDeviceID:(NSUInteger)deviceID;
{
    //self.sensingManager = [[CLMSensingManager alloc] initWithMajor:0 withMinor:deviceID];
    //self.sensingManager.delegate = self;
}

- (IBAction)switchChanged:(UISwitch *)sender {
    
    if (sender.on)
    {
        self.nameTextField.enabled = NO;
        self.serverTextField.enabled = NO;
        
        // Send Name
        [self sendData:[NSString stringWithFormat:@"SET_NAME,%lu,%@", (unsigned long)self.deviceID, [self getName]]];
        
        // Proximity Monitoring and idle timer
        [UIDevice currentDevice].proximityMonitoringEnabled = YES;
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        // Start Sensing
        [self.sensingKit startContinuousSensingWithAllRegisteredSensors:nil];
    }
    else
    {
        self.nameTextField.enabled = YES;
        self.serverTextField.enabled = YES;
        
        // Stop Sensing
        [self.sensingKit stopContinuousSensingWithAllRegisteredSensors:nil];
        
        // Proximity Monitoring and idle timer
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
}

- (void)alertWithTitle:(NSString *)title withMessage:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   
                               }];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
