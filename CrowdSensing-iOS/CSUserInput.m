//
//  CSNumericUserInput.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSUserInput.h"

@interface CSUserInput ()

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (strong, nonatomic) NSCharacterSet *validCharacters;

@property (nonatomic) UIKeyboardType keyboardType;

@end

@implementation CSUserInput

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the delegate
    self.textField.delegate = self;
    self.textField.text = self.userInputDefaultValue;
    self.textField.placeholder = self.userInputPlaceholder;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Make keyboard appear
    self.textField.keyboardType = self.keyboardType;
    [self.textField becomeFirstResponder];
}

- (void)setMode:(CSUserInputMode)mode
{
    switch (mode)
    {
        case CSNUserInputIntegerMode:
            self.keyboardType = UIKeyboardTypeNumberPad;
            self.validCharacters = [NSCharacterSet decimalDigitCharacterSet].invertedSet;
            break;
            
        case CSNUserInputTextMode:
            self.keyboardType = UIKeyboardTypeASCIICapable;
            self.validCharacters = [NSCharacterSet alphanumericCharacterSet].invertedSet;
            break;
            
        case CSNUserInputHexMode:
            self.keyboardType = UIKeyboardTypeASCIICapable;
            self.validCharacters = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFabcdef"].invertedSet;
            break;
            
        default:
            NSLog(@"Unknown UserInputMode: %lu", (unsigned long)mode);
            abort();
    }
    
    _mode = mode;
}

- (IBAction)doneAction:(id)sender
{
    if (self.mode == CSNUserInputIntegerMode)
    {
        // Parse as integer
        NSUInteger value = self.textField.text.integerValue;
        
        if (self.zeroIsNil && value == 0)
        {
            self.textField.text = nil;
        }
        else
        {
            if (value < self.minValue)
            {
                value = self.minValue;
            }
            
            if (value > self.maxValue)
            {
                value = self.maxValue;
            }
            
            self.textField.text = [NSString stringWithFormat:@"%lu", (long)value];
        }
    }
    
    if (self.delegate) {
        [self.delegate userInputWithIdentifier:self.identifier withValue:self.textField.text];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // allow backspace
    if (!string.length) { return YES; }
    
    // Check string for validity
    if (![self isStringValid:string]) { return NO; }
    
    // Check the length of the string
    NSString *updatedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (updatedText.length > self.maxCharacters) { return NO; }
    
    // All ok
    return YES;
}

- (BOOL)isStringValid:(NSString *)string
{
    return ([string rangeOfCharacterFromSet:self.validCharacters].location == NSNotFound);
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
