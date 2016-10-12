//
//  SKBattery.m
//  SensingKit
//
//  Copyright (c) 2014. Queen Mary University of London
//  Kleomenis Katevas, k.katevas@qmul.ac.uk
//
//  This file is part of SensingKit-iOS library.
//  For more information, please visit http://www.sensingkit.org
//
//  SensingKit-iOS is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  SensingKit-iOS is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with SensingKit-iOS.  If not, see <http://www.gnu.org/licenses/>.
//

#import "SKBattery.h"
#import "SKBatteryData.h"


@implementation SKBattery

- (instancetype)initWithConfiguration:(SKBatteryConfiguration *)configuration
{
    if (self = [super init])
    {
        // Register for battery level and state change notifications.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(batteryLevelChanged:)
                                                     name:UIDeviceBatteryLevelDidChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(batteryStateChanged:)
                                                     name:UIDeviceBatteryStateDidChangeNotification object:nil];
        
        self.configuration = configuration;
    }
    return self;
}


#pragma mark Configuration

- (void)setConfiguration:(SKConfiguration *)configuration
{
    // Check if the correct configuration type provided
    if (configuration.class != SKBatteryConfiguration.class)
    {
        NSLog(@"Wrong SKConfiguration class provided (%@) for sensor Battery.", configuration.class);
        abort();
    }
    
    super.configuration = configuration;
    
    // Cast the configuration instance
    // SKBatteryConfiguration *batteryConfiguration = (SKBatteryConfiguration *)configuration;
    
    // Make the required updates on the sensor
    //
}


#pragma mark Sensing

+ (BOOL)isSensorAvailable
{
    // Always available
    return YES;
}

- (void)startSensing
{
    [super startSensing];
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
}

- (void)stopSensing
{
    [UIDevice currentDevice].batteryMonitoringEnabled = NO;
    
    [super stopSensing];
}

- (CGFloat)batteryLevel
{
    return [UIDevice currentDevice].batteryLevel;
}

- (UIDeviceBatteryState)batteryState
{
    return [UIDevice currentDevice].batteryState;
}

- (void)batteryLevelChanged:(NSNotification *)notification
{
    SKBatteryData *data = [[SKBatteryData alloc] initWithLevel:[self batteryLevel]
                                                     withState:[self batteryState]];
    [self submitSensorData:data];
}

- (void)batteryStateChanged:(NSNotification *)notification
{
    SKBatteryData *data = [[SKBatteryData alloc] initWithLevel:[self batteryLevel]
                                                     withState:[self batteryState]];
    [self submitSensorData:data];
}

@end
