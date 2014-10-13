//
//  CSViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 18/07/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSViewController.h"

enum CSStartButtonMode : NSUInteger {
    CSStartButtonStartMode,
    CSStartButtonStopMode
};

enum CSPauseButtonMode : NSUInteger {
    CSPauseButtonPauseMode,
    CSPauseButtonResumeMode
};

@interface CSViewController ()

@property (weak, nonatomic) IBOutlet CSRoundButton *startButton;
@property (weak, nonatomic) IBOutlet CSRoundButton *pauseButton;
@property (weak, nonatomic) IBOutlet CSRoundButton *syncButton;

@property (nonatomic) enum CSStartButtonMode startButtonMode;
@property (nonatomic) enum CSPauseButtonMode pauseButtonMode;

@end

@implementation CSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Init Button Modes
    self.startButtonMode = CSStartButtonStartMode;
    self.pauseButtonMode = CSPauseButtonPauseMode;
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

- (void)setPauseButtonMode:(enum CSPauseButtonMode)pauseButtonMode
{
    switch (pauseButtonMode) {
        case CSPauseButtonPauseMode:
            [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
            break;
            
        case CSPauseButtonResumeMode:
            [self.pauseButton setTitle:@"Resume" forState:UIControlStateNormal];
            break;
            
        default:
            // Error
            break;
    }
    
    _pauseButtonMode = pauseButtonMode;
}

- (IBAction)pauseButtonAction:(CSRoundButton *)sender
{
    switch (self.pauseButtonMode) {
        case CSPauseButtonPauseMode:
            
            NSLog(@"Pause Action");
            self.pauseButtonMode = CSPauseButtonResumeMode;
            
            break;
            
        case CSPauseButtonResumeMode:
            
            NSLog(@"Resume Action");
            self.pauseButtonMode = CSPauseButtonPauseMode;
            
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

@end
