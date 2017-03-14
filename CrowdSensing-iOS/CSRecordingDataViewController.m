//
//  CSRecordingDataViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 10/03/2017.
//  Copyright © 2017 Kleomenis Katevas. All rights reserved.
//

#import "CSRecordingDataViewController.h"

@interface CSRecordingDataViewController ()

@property (weak, nonatomic) IBOutlet UIButton *iAmDoneButton;

@end

@implementation CSRecordingDataViewController

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

- (IBAction)iAmDoneAction:(id)sender
{
    // Are you sure?
    [self askAreYouDone];
}

- (void)askAreYouDone {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Finish Experiment"
                                          message:@"Are you sure you want to finish your participation?"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"I am sure"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action) {
                                   
                                   [self performSegueWithIdentifier:@"Show Submit Data" sender:self];
                                   
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    // Show the alert
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
