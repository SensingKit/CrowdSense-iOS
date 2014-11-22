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

@interface CSRecordViewController : UIViewController<UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) SKRecording *recording;

@end
