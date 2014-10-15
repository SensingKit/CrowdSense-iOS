//
//  CSGenericSensorSetup.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import <UIKit/UIKit.h>

enum CSSensorSetupType : NSUInteger {
    CSSensorSetupAccelerometerType,
    CSSensorSetupGyroscopeType,
    CSSensorSetupMagnetometerType,
    CSSensorSetupDeviceMotionType,
    CSSensorSetupActivityType,
    CSSensorSetupLocationType,
    CSSensorSetupProximityType,
    CSSensorSetupBatteryType
};

@interface CSGenericSensorSetup : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *sensorLabel;
@property (weak, nonatomic) IBOutlet UISwitch *sensorSwitch;

//@property (nonatomic, strong) SensingKitLib sensingKitLib;
@property (nonatomic) enum CSSensorSetupType sensorSetupType;

@end
