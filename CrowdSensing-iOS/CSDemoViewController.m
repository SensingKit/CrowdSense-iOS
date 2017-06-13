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

@property (weak, nonatomic) IBOutlet UILabel *joinDemoLabel;
@property (weak, nonatomic) IBOutlet UISwitch *joinDemoSwitch;

@property (nonatomic, strong) SensingKitLib *sensingKit;

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic) BOOL connected;
@property (nonatomic) NSUInteger deviceID;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDictionary *configuration;

@end

@implementation CSDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sensingKit = [SensingKitLib sharedSensingKitLib];
    self.configuration = [self getConfiguration];
    [self initNetworkCommunication];
}

- (IBAction)finishDemo:(id)sender
{
    if (self.joinDemoSwitch.on) {
        [self alertWithTitle:nil withMessage:@"Please stop the demo first by turning-off the switch." withHandler:nil];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setConnected:(BOOL)connected
{
    if (connected) {
        self.statusLabel.text = @"Connected!";
        self.statusLabel.textColor = [UIColor greenColor];
        self.joinDemoLabel.enabled = YES;
        self.joinDemoSwitch.enabled = YES;
    }
    else {
        self.statusLabel.text = @"Disconnected!";
        self.statusLabel.textColor = [UIColor redColor];
        self.joinDemoLabel.enabled = NO;
        self.joinDemoSwitch.enabled = NO;
    }
    
    _connected = connected;
}

- (NSString *)name
{
    if (!_name || !_name.length) {
         return @"Unknown User";
    }
    
    return _name;
}

- (void)initSensingWithID:(NSUInteger)deviceID;
{
    [self initBeaconSensingWithID:deviceID];
    
    if (self.configuration[@"heading"]) {
        [self initHeadingSensing];
        NSLog(@"Heading feature is enabled.");
    }
}

- (void)initBeaconSensingWithID:(NSUInteger)deviceID
{
    if (![self.sensingKit isSensorAvailable:iBeaconProximity]) {
        [self alertWithTitle:@"Error" withMessage:@"iBeaconProximity sensor is not available in your device." withHandler:nil];
        return;
    }
    
    SKiBeaconProximityConfiguration *configuration = [[SKiBeaconProximityConfiguration alloc] initWithUUID:[[NSUUID alloc] initWithUUIDString:@"eeb79aec-022f-4c05-8331-93d9b2ba6dce"]];
    configuration.mode = SKiBeaconProximityModeScanAndBroadcast;
    configuration.major = 100;
    configuration.minor = deviceID;
    
    NSError *error;
    [self.sensingKit registerSensor:iBeaconProximity withConfiguration:configuration error:&error];
    
    if (error) {
        // Error
        [self alertWithTitle:@"Error" withMessage:error.localizedDescription withHandler:nil];
        return;
    }
    
    [self.sensingKit subscribeToSensor:iBeaconProximity withHandler:^(SKSensorType sensorType, SKSensorData * _Nullable sensorData, NSError * _Nullable error) {
        
        if (!error) {
            NSString *data = [NSString stringWithFormat:@"%@,%lu,%@;", @"BEACON", self.deviceID, sensorData.csvString];
            [self sendData:data];
        }
        
    } error:&error];
    
    if (error) {
        [self alertWithTitle:@"Error" withMessage:error.localizedDescription withHandler:nil];
        return;
    }
}

- (void)initHeadingSensing
{
    if (![self.sensingKit isSensorAvailable:Heading]) {
        [self alertWithTitle:@"Error" withMessage:@"Heading sensor is not available in your device." withHandler:nil];
        return;
    }
    NSNumber *filter = self.configuration[@"heading_filter"];
    SKHeadingConfiguration *configuration = [[SKHeadingConfiguration alloc] init];
    if (filter) {
        NSLog(@"Heading Filter: %@", filter);
        configuration.headingFilter = filter.unsignedIntegerValue;
    }
    configuration.displayHeadingCalibration = YES;
    
    NSError *error;
    [self.sensingKit registerSensor:Heading withConfiguration:configuration error:&error];
    
    if (error) {
        [self alertWithTitle:@"Error" withMessage:error.localizedDescription withHandler:nil];
        return;
    }
    
    [self.sensingKit subscribeToSensor:Heading withHandler:^(SKSensorType sensorType, SKSensorData * _Nullable sensorData, NSError * _Nullable error) {
        
        if (!error) {
            NSString *data = [NSString stringWithFormat:@"%@,%lu,%@;", @"HEADING", self.deviceID, sensorData.csvString];
            [self sendData:data];
        }
        
    } error:&error];
    
    if (error) {
        [self alertWithTitle:@"Error" withMessage:error.localizedDescription withHandler:nil];
        return;
    }
}

#pragma mark Streaming Communication

- (NSDictionary *)getConfiguration
{
    NSURL *url = [NSURL URLWithString:@"https://www.sensingkit.org/MobiSys17-Demo.json"];
    NSData *receivedData = [NSData dataWithContentsOfURL:url];
    
    if (!receivedData)
    {
        [self alertWithTitle:@"Network Error" withMessage:@"Please make sure you are connected with MobiSys'17 Wi-Fi network." withHandler:nil];
        return nil;
    }
    
    NSError *error = nil;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:receivedData
                                                                   options:kNilOptions
                                                                     error:&error];
        
    if (error) {
        [self alertWithTitle:@"Error" withMessage:error.localizedDescription withHandler:nil];
        return nil;
    }
        
    NSLog(@"IP: %@", jsonDictionary[@"ip"]);
    return jsonDictionary;
}

- (void)initNetworkCommunication
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    NSString *ip = self.configuration[@"ip"];
    
    if (!ip)
    {
        return;
    }
    
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
            self.connected = YES;
            [self askName];
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
            [self alertWithTitle:@"Connection Error"
                     withMessage:@"We couldn't reach the server. Please tap at 'Done' and try again later."
                     withHandler:nil];
            self.connected = NO;
            self.joinDemoSwitch.on = NO;
            NSLog(@"Can not connect to the host!");
            break;
            
        case NSStreamEventEndEncountered:
            self.connected = NO;
            self.joinDemoSwitch.on = NO;
            break;
            
        default:
            break;
    }
}

- (void)messageReceived:(NSString *)message
{
    NSLog(@"Server said %@", message);
    self.deviceID = message.integerValue;
    [self initSensingWithID:self.deviceID];
}

- (void)sendData:(NSString *)stringData
{
    NSData *data = [[NSData alloc] initWithData:[stringData dataUsingEncoding:NSASCIIStringEncoding]];
    [self.outputStream write:[data bytes] maxLength:[data length]];
}

#pragma mark MobileSensing

- (IBAction)switchChanged:(UISwitch *)sender {
    
    if (sender.on)
    {
        // Send Name
        [self sendData:[NSString stringWithFormat:@"SET_NAME,%lu,%@;", (unsigned long)self.deviceID, self.name]];
        
        // Proximity Monitoring and idle timer
        [UIDevice currentDevice].proximityMonitoringEnabled = YES;
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        // Start Sensing
        [self.sensingKit startContinuousSensingWithAllRegisteredSensors:nil];
    }
    else
    {
        // Stop Sensing
        [self.sensingKit stopContinuousSensingWithAllRegisteredSensors:nil];
        
        // Proximity Monitoring and idle timer
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
}

- (void)alertWithTitle:(NSString *)title withMessage:(NSString *)message
           withHandler:(void (^ __nullable)(UIAlertAction *action))handler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:handler];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)askName {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"MobiSys 2017 Demo"
                                          message:@"Please enter your first name:"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action) {
                                   
                                   NSString *text = ((UITextField *)[alertController.textFields objectAtIndex:0]).text;;
                                   
                                   if (text.length < 2) {
                                       [self alertWithTitle:@"Name Is Not Valid" withMessage:@"Your name needs to be at least two characters long (e.g. John)." withHandler:^(UIAlertAction *action) {
                                           [self askName];
                                       }];
                                   }
                                   else {
                                       self.name = text;
                                   }
                               }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Or just a nickname...";
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    
    [alertController addAction:okAction];
    
    // Show the alert
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
