//
//  CSSetupTableViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSSetupTableViewController.h"
#import "CSSensorSetupTableViewController.h"

@interface CSSetupTableViewController ()

@property (nonatomic, strong) NSDictionary *configuration;

@end

@implementation CSSetupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)doneButtonAction:(id)sender
{
    if (self.delegate)
    {
        //[self.delegate doneWithConfiguration:self.configuration];
    }
    
    [self dismissViewControllerAnimated:YES
                             completion:NULL];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Sensor Setup"]) {
        
        CSSensorSetupTableViewController *sensorSetupTableViewController = (CSSensorSetupTableViewController *)segue.destinationViewController;
        
        //sensorSetupTableViewController.delegate = self;
        sensorSetupTableViewController.sensingSession = self.sensingSession;
    }
}

@end
