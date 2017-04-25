//
//  CSReadyToGoViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 10/03/2017.
//  Copyright © 2017 Kleomenis Katevas. All rights reserved.
//

#import "CSReadyToGoViewController.h"
#import "CSRecordingDataViewController.h"

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
    
    CSRecordingDataViewController *controller = (CSRecordingDataViewController *)segue.destinationViewController;
    controller.type = self.type;
    controller.sensingSession = self.sensingSession;
    controller.information = self.information;
    controller.picture = self.picture;
}

- (IBAction)startAction:(id)sender
{
    // Ask for 2nd pin
}

@end
