//
//  CSRecordViewController.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 18/07/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SensingKit/SensingKitLib.h>
#import "CSRoundButton.h"
#import "Recording.h"

@interface CSRecordViewController : UIViewController<UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Recording *recording;

@property (nonatomic, strong) SensingKitLib *sensingKitLib;

@end
