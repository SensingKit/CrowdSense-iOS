//
//  CSSensingSession.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 13/07/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import "CSSensingSession.h"
#import "CSModelWriter.h"

@interface CSSensingSession ()

@property (nonatomic, strong) NSURL* folderPath;
@property (nonatomic, strong) NSMutableArray *sensorModules;
@property (nonatomic, strong) NSMutableArray *modelWriters;

@end

@implementation CSSensingSession

- (instancetype)initWithFolderName:(NSString *)folderName
{
    if (self = [super init])
    {
        // Init SensingKitLib
        self.sensingKitLib = [SensingKitLib sharedSensingKitLib];
        
        self.folderPath = [self createFolderWithName:folderName];
        
        self.sensorModules = [[NSMutableArray alloc] initWithCapacity:8];
        self.modelWriters = [[NSMutableArray alloc] initWithCapacity:8];
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

- (CSModelWriter *)getModuleWriterWithType:(SKSensorModuleType)moduleType
{
    for (CSModelWriter *moduleWriter in self.modelWriters) {
        if (moduleWriter.moduleType == moduleType) { return moduleWriter; }
    }
    
    return nil;
}

- (void)enableSensorWithType:(SKSensorModuleType)moduleType
{
    // Create ModelWriter
    NSString *filename = [[self getSensorModuleInString:moduleType] stringByAppendingString:@".csv"];
    CSModelWriter *modelWriter = [[CSModelWriter alloc] initWithSensorModuleType:moduleType
                                                                    withFilename:filename
                                                                          inPath:self.folderPath];
    
    // Register and Subscribe sensor
    [self.sensingKitLib registerSensorModule:moduleType];
    [self.sensingKitLib subscribeSensorDataListenerToSensor:moduleType
                                                withHandler:^(SKSensorModuleType moduleType, SKSensorData *sensorData) {
                                                    
                                                    // Feed the writer with data
                                                    [modelWriter readData:sensorData];
                                                }];
    
    // Add sensorType and modelWriter to the arrays
    [self.sensorModules addObject:@(moduleType)];
    [self.modelWriters addObject:modelWriter];
}

- (void)disableSensorWithType:(SKSensorModuleType)moduleType
{
    [self.sensingKitLib deregisterSensorModule:moduleType];
    [self.sensorModules removeObject:@(moduleType)];
    
    // Search for the moduleWriter in the Array
    CSModelWriter *moduleWriter = [self getModuleWriterWithType:moduleType];
    
    // Close the fileWriter
    [moduleWriter close];
    
    // Remove fileWriter
    [self.modelWriters removeObject:moduleWriter];
}

- (void)disableAllRegisteredSensors
{
    // Copy to avoid error "NSArray was mutated while being enumerated."
    for (NSNumber *moduleType in [self.sensorModules copy]) {
        [self disableSensorWithType:moduleType.unsignedIntegerValue];
    }
}

- (BOOL)isSensorEnabled:(SKSensorModuleType)moduleType
{
    return [self.sensorModules containsObject:@(moduleType)];
}

- (void)start
{
    for (NSNumber *moduleType in self.sensorModules)
    {
        [self.sensingKitLib startContinuousSensingWithSensor:moduleType.unsignedIntegerValue];
    }
}

- (void)stop
{
    for (NSNumber *moduleType in self.sensorModules)
    {
        [self.sensingKitLib stopContinuousSensingWithSensor:moduleType.unsignedIntegerValue];
    }
}

- (void)close
{
    NSLog(@"Close Session");
}

- (NSString *)getSensorModuleInString:(SKSensorModuleType)moduleType
{
    switch (moduleType) {
            
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
            
        case Battery:
            return @"Battery";
            
        case Location:
            return @"Location";
            
        case Proximity:
            return @"Proximity";
            
        default:
            return [NSString stringWithFormat:@"Unknown SensorModule: %li", (long)moduleType];
    }
}

@end
