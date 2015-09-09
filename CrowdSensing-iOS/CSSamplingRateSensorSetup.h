//
//  CSSamplingRateSensorSetup.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSGenericSensorSetup.h"


@interface CSSamplingRateSensorSetup : CSGenericSensorSetup

@property (weak, nonatomic) IBOutlet UILabel *sensorLabel;
@property (weak, nonatomic) IBOutlet UISwitch *sensorSwitch;
@property (weak, nonatomic) IBOutlet UILabel *samplingRateLabel;

@end
