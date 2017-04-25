//
//  CSQuestionnaireViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 10/03/2017.
//  Copyright © 2017 Kleomenis Katevas. All rights reserved.
//

#import "CSQuestionnaireViewController.h"
#import "ALDisk.h"
#import "CSAlmostReadyViewController.h"

@interface CSQuestionnaireViewController ()

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
    
    [self.navigationItem setHidesBackButton:YES];
    
    [self.ageTextField becomeFirstResponder];
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
    
    CSAlmostReadyViewController *controller = (CSAlmostReadyViewController *)segue.destinationViewController;
    controller.type = self.type;
    controller.sensingSession = self.sensingSession;
    controller.information = self.information;

}

- (IBAction)submitAction:(id)sender
{
    // Check if all input is complete and valid. Save data
    if ([self checkInput]) {
        
        // Add Questionnaire information to the dict
        self.information[@"Questionnaire"] = @{
                                               @"Gender": [self.genderOutlet titleForSegmentAtIndex:self.genderOutlet.selectedSegmentIndex],
                                               @"Age": self.ageTextField.text,
                                               @"Height": self.heightTextField.text,
                                               @"Weight": self.weightTextField.text
                                               };
        
        // Add Device information to the dict
        self.information[@"DeviceInfo"] = @{@"Name": [[UIDevice currentDevice] name],
                                            @"Model": [[UIDevice currentDevice] model],
                                            @"IdentifierForVendor": [[UIDevice currentDevice] identifierForVendor].UUIDString,
                                            @"SystemVersion": [[UIDevice currentDevice] systemVersion],
                                            @"TotalDiskSpace": [ALDisk totalDiskSpace],
                                            @"FreeDiskSpace": [ALDisk freeDiskSpace],
                                            @"UsedDiskSpace": [ALDisk usedDiskSpace]
                                            };

        // Show next screen
        [self performSegueWithIdentifier:@"Show Almost Ready" sender:self];
    }
}

- (BOOL)checkInput {
    
    // gender
    if (self.genderOutlet.selectedSegmentIndex == UISegmentedControlNoSegment) {
        [self alertWithTitle:@"Gender" withMessage:@"Please choose your gender."];
        return NO;
    }
    
    // age
    if (self.ageTextField.text.length == 0 || self.ageTextField.text.integerValue < 18 || self.ageTextField.text.integerValue > 90) {
        [self alertWithTitle:@"Invalid Age" withMessage:@"You should be over 18 years old in order to participate in this study."];
        return NO;
    }
    
    // height
    if (self.heightTextField.text.length == 0 || self.heightTextField.text.integerValue < 100 || self.heightTextField.text.integerValue > 230) {
        [self alertWithTitle:@"Invalid Height" withMessage:@"Please make sure you have entered your height in cm (e.g. for 1.70m you should enter 170)."];
        return NO;
    }
    
    // weight
    if (self.weightTextField.text.length == 0 || self.weightTextField.text.integerValue < 35 || self.weightTextField.text.integerValue > 200) {
        [self alertWithTitle:@"Invalid Weight" withMessage:@"Please make sure you have entered your weight in kg."];
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
