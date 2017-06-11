//
//  CSDemoViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 11/06/2017.
//  Copyright © 2017 Kleomenis Katevas. All rights reserved.
//

#import "CSDemoViewController.h"

@interface CSDemoViewController ()

@property (weak, nonatomic) IBOutlet UIButton *joinDemoButton;

@end

@implementation CSDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (IBAction)finishDemo:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)joinDemo:(id)sender
{
    
}

@end
