//
//  CSSensingSession.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 13/07/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SensingKit/SensingKitLib.h>

@interface CSSensingSession : NSObject

@property (nonatomic, strong) SensingKitLib *sensingKitLib;
@property (nonatomic, readonly) NSURL* folderPath;

- (instancetype)initWithFolderName:(NSString *)folderName;

- (void)enableSensor:(SKSensorType)sensorType withConfiguration:(SKConfiguration *)configuration;
- (void)disableSensor:(SKSensorType)sensorType;
- (void)disableAllRegisteredSensors;

- (void)setConfiguration:(SKConfiguration *)configuration toSensor:(SKSensorType)sensorType;
- (SKConfiguration *)getConfigurationFromSensor:(SKSensorType)sensorType;

- (BOOL)isSensorAvailable:(SKSensorType)sensorType;
- (BOOL)isSensorEnabled:(SKSensorType)sensorType;

- (NSUInteger)sensorsEnabledCount;

- (void)start;
- (void)stop;
- (void)close;

- (void)addRecordingLog:(NSString *)recordingLog;

@end
