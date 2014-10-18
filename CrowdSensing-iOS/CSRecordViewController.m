//
//  CSRecordViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 18/07/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSRecordViewController.h"

enum CSStartButtonMode : NSUInteger {
    CSStartButtonStartMode,
    CSStartButtonStopMode
};

@interface CSRecordViewController ()

@property (weak, nonatomic) IBOutlet CSRoundButton *startButton;
@property (weak, nonatomic) IBOutlet CSRoundButton *syncButton;

@property (nonatomic) enum CSStartButtonMode startButtonMode;

@end

@implementation CSRecordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Init Button Modes
    self.startButtonMode = CSStartButtonStartMode;
}

- (void)setStartButtonMode:(enum CSStartButtonMode)startButtonMode
{
    switch (startButtonMode) {
        case CSStartButtonStartMode:
            [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
            break;
            
        case CSStartButtonStopMode:
            [self.startButton setTitle:@"Stop" forState:UIControlStateNormal];
            break;
            
        default:
            // Error
            break;
    }
    
    _startButtonMode = startButtonMode;
}

- (IBAction)startButtonAction:(CSRoundButton *)sender
{
    switch (self.startButtonMode) {
        case CSStartButtonStartMode:
            
            NSLog(@"Start Action");
            self.startButtonMode = CSStartButtonStopMode;
            
            break;
            
        case CSStartButtonStopMode:
            
            NSLog(@"Stop Action");
            self.startButtonMode = CSStartButtonStartMode;
            
            break;
            
        default:
            // Error
            break;
    }
}

- (IBAction)syncButtonAction:(CSRoundButton *)sender
{
    NSLog(@"Sync Action");
}

- (IBAction)doneButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
