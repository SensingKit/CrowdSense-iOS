//
//  CSQuestionnaireViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 10/03/2017.
//  Copyright © 2017 Kleomenis Katevas. All rights reserved.
//

#import "CSQuestionnaireViewController.h"

@interface CSQuestionnaireViewController ()

@property (weak, nonatomic) IBOutlet UITextField *participantIdTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderOutlet;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextField *heightTextField;
@property (weak, nonatomic) IBOutlet UITextField *weightTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation CSQuestionnaireViewController

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

- (IBAction)submitAction:(id)sender
{
    // Check if all input is complete and valid. Save data
    if ([self checkInput]) {
        [self performSegueWithIdentifier:@"Show Almost Ready" sender:self];
    }
}

- (BOOL)checkInput {
    
    // id
    if (self.participantIdTextField.text.length == 0) {
        [self alertWithTitle:@"Invalid Participant ID" withMessage:nil];
        return NO;
    }
    
    // gender
    if (self.genderOutlet.selectedSegmentIndex == UISegmentedControlNoSegment) {
        [self alertWithTitle:@"Please choose your gender" withMessage:nil];
        return NO;
    }
    
    // age
    if (self.ageTextField.text.length == 0 || self.ageTextField.text.integerValue < 18 || self.ageTextField.text.integerValue > 90) {
        [self alertWithTitle:@"Invalid Age" withMessage:nil];
        return NO;
    }
    
    // height
    if (self.heightTextField.text.length == 0 || self.heightTextField.text.integerValue < 100 || self.heightTextField.text.integerValue > 230) {
        [self alertWithTitle:@"Invalid Height" withMessage:nil];
        return NO;
    }
    
    // weight
    if (self.weightTextField.text.length == 0 || self.weightTextField.text.integerValue < 35 || self.weightTextField.text.integerValue > 200) {
        [self alertWithTitle:@"Invalid Weight" withMessage:nil];
        return NO;
    }
    
    return YES;
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
