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

- (BOOL)enableSensor:(SKSensorType)sensorType withConfiguration:(SKConfiguration *)configuration withError:(NSError **)error;
- (BOOL)disableSensor:(SKSensorType)sensorType withError:(NSError **)error;
- (BOOL)disableAllRegisteredSensors:(NSError **)error;

- (BOOL)setConfiguration:(SKConfiguration *)configuration toSensor:(SKSensorType)sensorType withError:(NSError **)error;
- (SKConfiguration *)getConfigurationFromSensor:(SKSensorType)sensorType;

- (BOOL)isSensorAvailable:(SKSensorType)sensorType;
- (BOOL)isSensorEnabled:(SKSensorType)sensorType;

- (NSUInteger)sensorsEnabledCount;

- (BOOL)start:(NSError **)error;
- (BOOL)stop:(NSError **)error;
- (void)close;
- (void)deleteSession;

- (void)addRecordingLog:(NSString *)recordingLog;

@end
