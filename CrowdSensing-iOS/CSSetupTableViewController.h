//
//  CSSetupTableViewController.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSSensingSession.h"

@protocol CSSetupTableViewControllerDelegate <NSObject>

- (void)doneSensorSetup;

@end

@interface CSSetupTableViewController : UITableViewController

@property (weak, nonatomic) id <CSSetupTableViewControllerDelegate> delegate;

@property (strong, nonatomic) CSSensingSession *sensingSession;

@end
