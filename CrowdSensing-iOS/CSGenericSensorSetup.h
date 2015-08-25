//
//  CSGenericSensorSetup.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CSSensorSetupType) {
    CSSensorSetupAccelerometerType,
    CSSensorSetupGyroscopeType,
    CSSensorSetupMagnetometerType,
    CSSensorSetupDeviceMotionType,
    CSSensorSetupActivityType,
    CSSensorSetupPedometerType,
    CSSensorSetupLocationType,
    CSSensorSetupBeaconType,
    CSSensorSetupEddystoneType,
    CSSensorSetupBatteryType
};

typedef NS_ENUM(NSUInteger, CSSensorStatus) {
    CSSensorStatusEnabled,
    CSSensorStatusDisabled
};

@interface CSGenericSensorSetup : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *sensorLabel;
@property (weak, nonatomic) IBOutlet UISwitch *sensorSwitch;

@property (nonatomic) CSSensorSetupType sensorSetupType;

@property (nonatomic) CSSensorStatus sensorStatus;

@property (strong, nonatomic) NSString *sensorDescription;

@end
