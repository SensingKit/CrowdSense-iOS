//
//  CSSimpleSensorSetup.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSGenericSensorSetup.h"

@protocol CSSimpleSensorSetupDelegate <NSObject>

- (void)changeStatus:(CSSensorStatus)sensorStatus ofSensorWithType:(CSSensorSetupType)sensorType;

@end

@interface CSSimpleSensorSetup : CSGenericSensorSetup

@property (weak, nonatomic) id <CSSimpleSensorSetupDelegate> delegate;

@end
