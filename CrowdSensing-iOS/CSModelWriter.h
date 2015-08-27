//
//  CSModelWriter.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 13/07/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SensingKit/SensingKitLib.h>

@interface CSModelWriter : NSObject

@property (nonatomic, readonly) SKSensorModuleType moduleType;

- (instancetype)initWithSensorModuleType:(SKSensorModuleType)moduleType
                              withHeader:(NSString *)header
                            withFilename:(NSString *)filename
                                  inPath:(NSURL *)path;

- (void)readData:(SKSensorData *)sensorData;

- (void)close;

@end
