//
//  CSConsentFormViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 10/03/2017.
//  Copyright © 2017 Kleomenis Katevas. All rights reserved.
//

#import "CSConsentFormViewController.h"

@interface CSConsentFormViewController ()

@property (weak, nonatomic) IBOutlet UIButton *iAgreeButton;

@end

@implementation CSConsentFormViewController

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

- (IBAction)iAgreeAction:(id)sender
{
    // Ask for full name.
    [self userInput];
}

- (void)userInput {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Consent Form"
                                          message:@"I agree to take part in this study."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"I Agree"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action) {
                                   
                                   NSString *text = ((UITextField *)[alertController.textFields objectAtIndex:0]).text;
                                   NSArray *textArray = [text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                   
                                   if (text.length < 5 || textArray.count < 2) {
                                       [self alertWithTitle:@"Name Is Not Valid" withMessage:@"Your name does not appear to be valid. Please enter your full name in a valid format (e.g. John Smith)."];
                                   }
                                   else {
                                       [self performSegueWithIdentifier:@"Show Questionnaire" sender:self];
                                   }
                                   
                               }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Please enter your full name.";
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    // Show the alert
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)alertWithTitle:(NSString *)title withMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    
    [alert show];
}

@end
