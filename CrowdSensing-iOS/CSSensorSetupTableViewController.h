//
//  CSSensorSetupTableViewController.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSSensingSession.h"

@interface CSSensorSetupTableViewController : UITableViewController

@property (strong, nonatomic) CSSensingSession *sensingSession;


@property (weak, nonatomic) IBOutlet UITableViewCell *accelerometerSensorCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *gyroscopeSensorCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *magnetometerSensorCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *deviceMotionSensorCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *ActivitySensorCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *LocationSensorCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *BatterySensorCell;

@end
