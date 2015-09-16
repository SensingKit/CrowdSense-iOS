//
//  CSSensingSession.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 13/07/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import "CSSensingSession.h"
#import "CSModelWriter.h"
#import "CSRecordingLogModelWriter.h"
#import <SensingKit/NSString+SensorType.h>

#define TOTAL_SENSOR_MODULES 12

@interface CSSensingSession ()

@property (nonatomic, strong) NSURL* folderPath;
@property (nonatomic, strong) NSMutableArray *modelWriters;
@property (nonatomic, strong) CSRecordingLogModelWriter *recordingLogModelWriter;

@end

@implementation CSSensingSession

- (instancetype)initWithFolderName:(NSString *)folderName
{
    if (self = [super init])
    {
        // Init SensingKitLib
        self.sensingKitLib = [SensingKitLib sharedSensingKitLib];
        
        self.folderPath = [self createFolderWithName:folderName];
        
        self.modelWriters = [[NSMutableArray alloc] initWithCapacity:TOTAL_SENSOR_MODULES];
        self.recordingLogModelWriter = [[CSRecordingLogModelWriter alloc] initWithFilename:@"RecordingLog.csv"
                                                                                    inPath:self.folderPath];
    }
    return self;
}

- (NSURL *)createFolderWithName:(NSString *)folderName
{
    NSError *error = nil;
    
    NSURL *folderPath = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:folderName];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:folderPath
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:&error];
    
    if (error != nil) {
        NSLog(@"Error creating directory: %@", error);
    }
    
    return folderPath;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (CSModelWriter *)getModuleWriterWithType:(SKSensorType)sensorType
{
    for (CSModelWriter *moduleWriter in self.modelWriters) {
        if (moduleWriter.sensorType == sensorType) { return moduleWriter; }
    }
    
    return nil;
}

- (void)enableSensor:(SKSensorType)sensorType withConfiguration:(SKConfiguration *)configuration
{
    // Get the csv header
    NSString *header = [self.sensingKitLib csvHeaderForSensor:sensorType];
    
    // Create ModelWriter
    NSString *filename = [[NSString stringWithSensorType:sensorType] stringByAppendingString:@".csv"];
    CSModelWriter *modelWriter = [[CSModelWriter alloc] initWithSensorType:sensorType
                                                                withHeader:header
                                                              withFilename:filename
                                                                    inPath:self.folderPath];
    
    // Register and Subscribe sensor
    [self.sensingKitLib registerSensor:sensorType withConfiguration:configuration];
    [self.sensingKitLib subscribeToSensor:sensorType
                              withHandler:^(SKSensorType sensorType, SKSensorData *sensorData) {
                                  
                                  // Feed the writer with data
                                  [modelWriter readData:sensorData];
                              }];
    
    // Add sensorType and modelWriter to the arrays
    [self.modelWriters addObject:modelWriter];
}

- (void)disableSensor:(SKSensorType)sensorType
{
    [self.sensingKitLib deregisterSensor:sensorType];
    
    // Search for the moduleWriter in the Array
    CSModelWriter *moduleWriter = [self getModuleWriterWithType:sensorType];
    
    // Close the fileWriter
    [moduleWriter close];
    
    // Remove fileWriter
    [self.modelWriters removeObject:moduleWriter];
}

- (void)disableAllRegisteredSensors
{
    for (int i = 0; i < TOTAL_SENSOR_MODULES; i++)
    {
        SKSensorType sensorType = i;
        
        if ([self isSensorEnabled:sensorType]) {
            [self disableSensor:sensorType];
        }
    }
}

- (void)setConfiguration:(SKConfiguration *)configuration toSensor:(SKSensorType)sensorType
{
    [self.sensingKitLib setConfiguration:configuration toSensor:sensorType];
}

- (SKConfiguration *)getConfigurationFromSensor:(SKSensorType)sensorType
{
    if ([self isSensorEnabled:sensorType])
    {
        return [self.sensingKitLib getConfigurationFromSensor:sensorType];
    }
    else
    {
        return [self createConfigurationForSensor:sensorType];
    }
}

- (SKConfiguration *)createConfigurationForSensor:(SKSensorType)sensorType
{
    SKConfiguration *configuration;
    
    switch (sensorType) {
            
        case Accelerometer:
            configuration = [[SKAccelerometerConfiguration alloc] init];
            break;
            
        case Gyroscope:
            configuration = [[SKGyroscopeConfiguration alloc] init];
            break;
            
        case Magnetometer:
            configuration = [[SKMagnetometerConfiguration alloc] init];
            break;
            
        case DeviceMotion:
            configuration = [[SKDeviceMotionConfiguration alloc] init];
            break;
            
        case Activity:
            configuration = [[SKActivityConfiguration alloc] init];
            break;
            
        case Pedometer:
            configuration = [[SKPedometerConfiguration alloc] init];
            break;
            
        case Altimeter:
            configuration = [[SKAltimeterConfiguration alloc] init];
            break;
            
        case Location:
            configuration = [[SKLocationConfiguration alloc] init];
            break;
            
        case iBeaconProximity:
            configuration = [[SKiBeaconProximityConfiguration alloc] init];
            break;
            
        case EddystoneProximity:
            configuration = [[SKEddystoneProximityConfiguration alloc] init];
            break;
            
        case Battery:
            configuration = [[SKBatteryConfiguration alloc] init];
            break;
            
        case Microphone:
            configuration = [[SKMicrophoneConfiguration alloc] init];
            break;
            
        default:
            NSLog(@"Unknown sensorSetupType: %ld", (long)sensorType);
            abort();
    }
    
    return configuration;
}

- (BOOL)isSensorAvailable:(SKSensorType)sensorType
{
     return [self.sensingKitLib isSensorAvailable:sensorType];
}

- (BOOL)isSensorEnabled:(SKSensorType)sensorType
{
    return [self.sensingKitLib isSensorRegistered:sensorType];
}

- (void)start
{
    [self.sensingKitLib startContinuousSensingWithAllRegisteredSensors];
}

- (void)stop
{
    [self.sensingKitLib stopContinuousSensingWithAllRegisteredSensors];
}

- (void)close
{
    NSLog(@"Close Session");
    
    [self.recordingLogModelWriter close];
}

- (void)addRecordingLog:(NSString *)recordingLog;
{
    [self.recordingLogModelWriter addRecordingLog:recordingLog];
}

@end
