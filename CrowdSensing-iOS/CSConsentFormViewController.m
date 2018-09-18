//
//  CSConsentFormViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 10/03/2017.
//  Copyright © 2017 Kleomenis Katevas. All rights reserved.
//

#import "CSConsentFormViewController.h"
#import "CSQuestionnaireViewController.h"

@interface CSConsentFormViewController ()

@property (weak, nonatomic) IBOutlet UIButton *iAgreeButton;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation CSConsentFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationItem setHidesBackButton:YES];
    
    // Configure NSDateFormatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    self.dateFormatter = dateFormatter;
    
    NSLog(@"Testing Date: %@", [self.dateFormatter stringFromDate:[NSDate date]]);
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
    
    CSQuestionnaireViewController *controller = (CSQuestionnaireViewController *)segue.destinationViewController;
    controller.type = self.type;
    controller.sensingSession = self.sensingSession;
    controller.information = self.information;
}

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
                                       [self alertWithTitle:@"Name Is Not Valid"
                                                withMessage:@"Your name does not appear to be valid. Please enter your full name in a valid format (e.g. John Smith)."
                                                withHandler:nil];
                                   }
                                   else {
                                       
                                       // Add fullname to the dict
                                       self.information[@"ConsentForm"] = @{
                                                                            @"FullName": text,
                                                                            @"SignedDate": [self.dateFormatter stringFromDate:[NSDate date]],
                                                                            @"SystemUpTime": @([[NSProcessInfo processInfo] systemUptime]),
                                                                            };
                                       
                                       // Show next screen
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
           withHandler:(void (^ __nullable)(UIAlertAction *action))handler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:handler];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
