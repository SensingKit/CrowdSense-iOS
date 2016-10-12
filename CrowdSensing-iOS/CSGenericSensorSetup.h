//
//  CSGenericSensorSetup.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SensingKit/SensingKit.h>

typedef NS_ENUM(NSUInteger, CSSensorStatus) {
    CSSensorStatusEnabled,
    CSSensorStatusDisabled,
    CSSensorStatusNotAvailable
};


@protocol CSSensorSetupDelegate <NSObject>

- (void)changeStatus:(CSSensorStatus)sensorStatus ofSensor:(SKSensorType)sensorType withConfiguration:(SKConfiguration *)configuration;

- (void)updateConfiguration:(SKConfiguration *)configuration forSensor:(SKSensorType)sensorType;

@end


@interface CSGenericSensorSetup : UITableViewController

@property (weak, nonatomic) id <CSSensorSetupDelegate> delegate;

@property (nonatomic) SKSensorType sensorType;
@property (nonatomic, strong) SKConfiguration *configuration;

@property (nonatomic) CSSensorStatus sensorStatus;

@property (strong, nonatomic) NSString *sensorDescription;

- (void)alertSensorNotAvailable;
- (void)updateConfiguration;

@end
