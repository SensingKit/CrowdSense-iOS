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
    self.samplingRateTextField.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.sampleRate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Make keyboard appear
    [self.samplingRateTextField becomeFirstResponder];
}

- (IBAction)doneAction:(id)sender
{
    NSUInteger sampleRate = self.samplingRateTextField.text.integerValue;
    
    [self.delegate updateSampleRate:sampleRate];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#define MAXLENGTH 3

// Thanks to http://stackoverflow.com/questions/12944789/allow-only-numbers-for-uitextfield-input
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // allow backspace
    if (!string.length)
    {
        return YES;
    }
    
    // Prevent invalid character input, if keyboard is numberpad
    if (textField.keyboardType == UIKeyboardTypeNumberPad)
    {
        if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
        {
            return NO;
        }
    }
    
    // verify max length has not been exceeded
    NSString *updatedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (updatedText.length > MAXLENGTH)
    {
        return NO;
    }
    
    return YES;
}

@end
