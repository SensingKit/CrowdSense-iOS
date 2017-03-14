//
//  CSReadyToGoViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 10/03/2017.
//  Copyright © 2017 Kleomenis Katevas. All rights reserved.
//

#import "CSReadyToGoViewController.h"

@interface CSReadyToGoViewController ()

@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation CSReadyToGoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.destinationViewController respondsToSelector:@selector(setInformation:)]) {
        [segue.destinationViewController setInformation:self.information];
    }
    
    if ([segue.destinationViewController respondsToSelector:@selector(setPicture:)]) {
        [segue.destinationViewController setPicture:self.picture];
    }
}

- (IBAction)startAction:(id)sender
{
    // Ask for 2nd pin
}

@end
