//
//  CSSelectSamplingRate.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSSelectSamplingRate.h"

@interface CSSelectSamplingRate ()

@property (weak, nonatomic) IBOutlet UITextField *samplingRateTextField;

@end

@implementation CSSelectSamplingRate

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the delegate
    self.samplingRateTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Make keyboard appear
    [self.samplingRateTextField becomeFirstResponder];
}

- (IBAction)doneAction:(id)sender
{
    NSUInteger samplingRate = self.samplingRateTextField.text.integerValue;
    
    if (self.delegate) {
        [self.delegate setSamplingRate:samplingRate];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#define MAXLENGTH 3

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= MAXLENGTH || returnKey;
}

@end
