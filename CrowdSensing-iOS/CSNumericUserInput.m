//
//  CSNumericUserInput.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSNumericUserInput.h"

@interface CSNumericUserInput ()

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation CSNumericUserInput

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the delegate
    self.textField.delegate = self;
    self.textField.text = [NSString stringWithFormat:@"%lu", (long)self.defaultValue];
    self.textField.placeholder = self.userInputPlaceholder;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Make keyboard appear
    [self.textField becomeFirstResponder];
}

- (IBAction)doneAction:(id)sender
{
    NSUInteger value = self.textField.text.integerValue;
    
    if (value < self.minValue)
    {
        value = self.minValue;
    }
    
    if (value > self.maxValue)
    {
        value = self.maxValue;
    }
    
    if (self.delegate) {
        [self.delegate userInputWithValue:value];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

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
    
    if (updatedText.length > self.maxDigits)
    {
        return NO;
    }
    
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.userInputDescription;
    }
    else
    {
        return nil;
    }
}

@end
