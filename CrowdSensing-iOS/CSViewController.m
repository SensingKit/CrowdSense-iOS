//
//  CSViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 18/07/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSViewController.h"

@interface CSViewController ()

@property (weak, nonatomic) IBOutlet CSRoundButton *startButton;
@property (weak, nonatomic) IBOutlet CSRoundButton *pauseButton;
@property (weak, nonatomic) IBOutlet CSRoundButton *syncButton;

@end

@implementation CSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startButtonAction:(CSRoundButton *)sender
{
}

- (IBAction)pauseButtonAction:(CSRoundButton *)sender
{
}

- (IBAction)syncButtonAction:(CSRoundButton *)sender
{
}

@end
