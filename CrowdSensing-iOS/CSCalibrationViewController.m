//
//  CSCalibrationViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 10/03/2017.
//  Copyright © 2017 Kleomenis Katevas. All rights reserved.
//

#import "CSCalibrationViewController.h"
#import <SensingKit/SensingKit.h>
#import "CSReadyToGoViewController.h"

@interface CSCalibrationViewController ()

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (strong, nonatomic) NSDateFormatter *filenameDateFormatter;

@end

@implementation CSCalibrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SKMicrophoneConfiguration *configuration = [[SKMicrophoneConfiguration alloc] initWithOutputDirectory:self.sensingSession.folderPath withFilename:@"Calibration"];
    configuration.recordingQuality = SKMicrophoneRecordingQualityMax;
    
    NSError *error;
    [self.sensingSession enableSensor:Microphone withConfiguration:configuration withError:&error];
    if (error) {
        // TODO
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    CSReadyToGoViewController *controller = (CSReadyToGoViewController *)segue.destinationViewController;
    controller.type = self.type;
    controller.information = self.information;
    controller.picture = self.picture;
    controller.sensingSession = self.sensingSession;
}

- (IBAction)recordAction:(id)sender
{
    NSTimeInterval recordingDuration = 30.0; // seconds
    
    NSError *error;
    [self.sensingSession start:&error];
    
    if (error) {
        // TODO
    }
    
    self.recordButton.enabled = NO;
    
    // Schedule a stop in testingDuration seconds
    [self performSelector:@selector(stopRecording) withObject:self afterDelay:recordingDuration];
}

- (void)stopRecording
{
    NSError *error;
    [self.sensingSession stop:&error];
    
    if (error) {
        // TODO
    }
    
    [self.sensingSession disableSensor:Microphone withError:&error];
    
    if (error) {
        // TODO
    }
    
    self.recordButton.hidden = YES;
    self.nextButton.enabled = YES;
    
    [self alertWithTitle:@"Calibration Completed" withMessage:@"Please tap at 'Next' button to continue."];
}

- (IBAction)nextAction:(id)sender
{

    [self askPassword:@"2957" toPerformSegueWithIdentifier:@"Show Ready to Go"];
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
