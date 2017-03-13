//
//  CSAlmostReadyViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 10/03/2017.
//  Copyright © 2017 Kleomenis Katevas. All rights reserved.
//

#import "CSAlmostReadyViewController.h"

@interface CSAlmostReadyViewController ()

@end

@implementation CSAlmostReadyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)NextAction:(id)sender
{
    // Ask for password before continuing
    [self askPassword:@"1111" toPerformSegueWithIdentifier:@"Show Calibration"];
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
