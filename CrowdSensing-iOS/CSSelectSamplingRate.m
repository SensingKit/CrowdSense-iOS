//
//  CSSelectSamplingRate.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSSelectSamplingRate.h"

@interface CSSelectSamplingRate ()

@property (weak, nonatomic) IBOutlet UITextField *samplingRateTextField;

@end

@implementation CSSelectSamplingRate

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Make keyboard appear
    [self.samplingRateTextField becomeFirstResponder];
}

- (IBAction)doneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
