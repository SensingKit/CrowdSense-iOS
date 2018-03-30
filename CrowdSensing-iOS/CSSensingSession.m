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
#import <SensingKit/SensingKit.h>

@interface CSSensingSession ()

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
        
        _folderPath = [self createFolderWithName:folderName];
        
        self.modelWriters = [[NSMutableArray alloc] initWithCapacity:TOTAL_SENSORS];
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

- (BOOL)enableSensor:(SKSensorType)sensorType withConfiguration:(SKConfiguration *)configuration withError:(NSError **)error
{
    // Get the csv header
    NSString *header = [self.sensingKitLib csvHeaderForSensor:sensorType];
    
    // Create ModelWriter
    NSString *filename = [[NSString nonspacedStringWithSensorType:sensorType] stringByAppendingString:@".csv"];
    CSModelWriter *modelWriter = [[CSModelWriter alloc] initWithSensorType:sensorType
                                                                withHeader:header
                                                               withFilename:filename
                                                                    inPath:self.folderPath];
    
    // If congiguration is nil, get the default
    if (!configuration) {
        configuration = [self getConfigurationFromSensor:sensorType];
    }
    
    // Register and Subscribe sensor
    if ([self.sensingKitLib registerSensor:sensorType withConfiguration:configuration error:error])
    {
        BOOL succeed =  [self.sensingKitLib subscribeToSensor:sensorType
                                                  withHandler:^(SKSensorType sensorType, SKSensorData *sensorData, NSError *error) {
                                                      
                                                      if (!error) {
                                                          // Feed the writer with data
                                                          [modelWriter readData:sensorData];
                                                      }
                                                  } error:error];
        
        if (!succeed) {
            return NO;
        }
        
        // Add sensorType and modelWriter to the arrays
        [self.modelWriters addObject:modelWriter];
        
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)disableSensor:(SKSensorType)sensorType withError:(NSError **)error
{
    BOOL succeed = [self.sensingKitLib deregisterSensor:sensorType error:error];
    
    if (!succeed) {
        return NO;
    }
    
    // Search for the moduleWriter in the Array
    CSModelWriter *moduleWriter = [self getModuleWriterWithType:sensorType];
    
    // Close the fileWriter
    [moduleWriter close];
    
    // Remove fileWriter
    [self.modelWriters removeObject:moduleWriter];
    
    return YES;
}

- (BOOL)disableAllRegisteredSensors:(NSError **)error
{
    for (int i = 0; i < TOTAL_SENSORS; i++)
    {
        SKSensorType sensorType = i;
        
        if ([self isSensorEnabled:sensorType]) {
            if (![self disableSensor:sensorType withError:error])
            {
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)setConfiguration:(SKConfiguration *)configuration toSensor:(SKSensorType)sensorType withError:(NSError **)error
{
    return [self.sensingKitLib setConfiguration:configuration toSensor:sensorType error:error];
}

- (SKConfiguration *)getConfigurationFromSensor:(SKSensorType)sensorType
{
    if ([self isSensorEnabled:sensorType])
    {
        return [self.sensingKitLib getConfigurationFromSensor:sensorType error:NULL];
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
            
        case MotionActivity:
            configuration = [[SKMotionActivityConfiguration alloc] init];
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
            configuration = [[SKiBeaconProximityConfiguration alloc] initWithUUID:[[NSUUID alloc] initWithUUIDString:@"eeb79aec-022f-4c05-8331-93d9b2ba6dce"]];
            break;
            
        case EddystoneProximity:
            configuration = [[SKEddystoneProximityConfiguration alloc] init];
            break;
            
        case Battery:
            configuration = [[SKBatteryConfiguration alloc] init];
            break;
            
        case Microphone:
            configuration = [[SKMicrophoneConfiguration alloc] initWithOutputDirectory:self.folderPath withFilename:@"Microphone"];
            break;
        
        case Heading:
            configuration = [[SKHeadingConfiguration alloc] init];
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

- (NSUInteger)sensorsEnabledCount
{
    NSUInteger counter = 0;
    
    for (int i = 0; i < TOTAL_SENSORS; i++)
    {
        SKSensorType sensorType = i;
        
        if ([self isSensorEnabled:sensorType]) {
            counter++;
        }
    }
    
    return counter;
}

- (BOOL)start:(NSError **)error
{
    return [self.sensingKitLib startContinuousSensingWithAllRegisteredSensors:error];
}

- (BOOL)stop:(NSError **)error
{
    return [self.sensingKitLib stopContinuousSensingWithAllRegisteredSensors:error];
}

- (void)close
{
    NSLog(@"Close Session");
    
    [self.recordingLogModelWriter close];
}

- (void)deleteSession
{
    NSLog(@"Delete Session");
    
    [[NSFileManager defaultManager] removeItemAtURL:self.folderPath error:nil];
}

- (void)addRecordingLog:(NSString *)recordingLog;
{
    [self.recordingLogModelWriter addRecordingLog:recordingLog];
}

@end
