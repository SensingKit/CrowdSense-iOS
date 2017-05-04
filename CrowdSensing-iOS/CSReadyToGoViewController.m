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
    
    [self.navigationItem setHidesBackButton:YES];
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
    [self askPassword:@"1928" toPerformSegueWithIdentifier:@"Show Experiment"];
}

- (void)askPassword:(NSString *)password toPerformSegueWithIdentifier:(NSString *)identifier {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Enter Password"
                                          message:@"Please enter the password given by the instructor in order to continue to the next step."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action) {
                                   
                                   NSString *text = ((UITextField *)[alertController.textFields objectAtIndex:0]).text;
                                   
                                   if ([text isEqualToString:password])
                                   {
                                       [self performSegueWithIdentifier:identifier sender:self];
                                   }
                                   else
                                   {
                                       // Ask for Password again
                                       [self askPassword:password toPerformSegueWithIdentifier:identifier];
                                   }
                                   
                               }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    // Show the alert
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
