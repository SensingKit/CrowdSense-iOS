//
//  CSSensingSession.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 13/07/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import "CSSensingSession.h"

@interface CSSensingSession ()

@property (nonatomic, strong) NSURL* folderPath;
@property (nonatomic, strong) NSMutableArray *sensorModules;

@end

@implementation CSSensingSession

- (instancetype)initWithFolderName:(NSString *)folderName
{
    if (self = [super init])
    {
        // Init SensingKitLib
        self.sensingKitLib = [SensingKitLib sharedSensingKitLib];
        
        self.folderPath = [self createFolderWithName:folderName];
        
        self.sensorModules = [[NSMutableArray alloc] init];
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

- (void)enableSensorWithType:(SKSensorModuleType)moduleType
{
    [self.sensingKitLib registerSensorModule:moduleType];
    [self.sensingKitLib subscribeSensorDataListenerToSensor:moduleType
                                                withHandler:^(SKSensorModuleType moduleType, SKSensorData *sensorData) {
                                                    
                                                }];
    [self.sensorModules addObject:@(moduleType)];
}

- (void)disableSensorWithType:(SKSensorModuleType)moduleType
{
    [self.sensingKitLib deregisterSensorModule:moduleType];
    [self.sensorModules removeObject:@(moduleType)];
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

@end
