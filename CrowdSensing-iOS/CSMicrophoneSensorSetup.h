//
//  CSMicrophoneSensorSetup.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 17/09/2015.
//  Copyright © 2015 Kleomenis Katevas. All rights reserved.
//

#import "CSGenericSensorSetup.h"

@interface CSMicrophoneSensorSetup : CSGenericSensorSetup

@property (weak, nonatomic) IBOutlet UILabel *sensorLabel;
@property (weak, nonatomic) IBOutlet UISwitch *sensorSwitch;

@property (weak, nonatomic) IBOutlet UILabel *recordingFormatLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordingQualityLabel;
@property (weak, nonatomic) IBOutlet UILabel *sampleRateLabel;
@end
