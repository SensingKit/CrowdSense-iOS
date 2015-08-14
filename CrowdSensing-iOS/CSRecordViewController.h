//
//  CSRecordViewController.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 18/07/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSRoundButton.h"
#import "Recording.h"
#import "CSSetupTableViewController.h"

@protocol CSRecordViewControllerDelegate <NSObject>

- (void)deleteRecording:(Recording *)recording;

@end

@interface CSRecordViewController : UIViewController<UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, CSSetupTableViewControllerDelegate>

@property (weak, nonatomic) id <CSRecordViewControllerDelegate> delegate;
@property (nonatomic, strong) Recording *recording;

@end
