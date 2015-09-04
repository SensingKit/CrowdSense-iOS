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

#define TOTAL_SENSOR_MODULES 11

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

- (void)enableSensorWithType:(SKSensorType)sensorType
{
    // Get the csv header
    NSString *header = [SensingKitLib csvHeaderForSensor:sensorType];
    
    // Create ModelWriter
    NSString *filename = [[self getSensorModuleInString:sensorType] stringByAppendingString:@".csv"];
    CSModelWriter *modelWriter = [[CSModelWriter alloc] initWithSensorType:sensorType
                                                                withHeader:header
                                                              withFilename:filename
                                                                    inPath:self.folderPath];
    
    // Register and Subscribe sensor
    [self.sensingKitLib registerSensor:sensorType];
    [self.sensingKitLib subscribeToSensor:sensorType
                              withHandler:^(SKSensorType sensorType, SKSensorData *sensorData) {
                                  
                                  // Feed the writer with data
                                  [modelWriter readData:sensorData];
                              }];
    
    // Add sensorType and modelWriter to the arrays
    [self.modelWriters addObject:modelWriter];
}

- (void)disableSensorWithType:(SKSensorType)sensorType
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
            [self disableSensorWithType:sensorType];
        }
    }
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

- (NSString *)getSensorModuleInString:(SKSensorType)sensorType
{
    switch (sensorType) {
            
        case Accelerometer:
            return @"Accelerometer";
            
        case Gyroscope:
            return @"Gyroscope";
            
        case Magnetometer:
            return @"Magnetometer";
            
        case DeviceMotion:
            return @"DeviceMotion";
            
        case Activity:
            return @"Activity";
            
        case Pedometer:
            return @"Pedometer";
            
        case Altimeter:
            return @"Altimeter";
            
        case Battery:
            return @"Battery";
            
        case Location:
            return @"Location";
            
        case iBeaconProximity:
            return @"iBeaconProximity";
            
        case EddystoneProximity:
            return @"EddystoneProximity";
            
        default:
            return [NSString stringWithFormat:@"Unknown SensorModule: %li", (long)sensorType];
            abort();
    }
}

- (void)addRecordingLog:(NSString *)recordingLog;
{
    [self.recordingLogModelWriter addRecordingLog:recordingLog];
}

@end
