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

- (void)alertRange
{
    NSString *title = [NSString stringWithFormat:@"\"%@\" is not a valid value", self.textField.text];
    NSString *message = [NSString stringWithFormat:@"%@ ranges from %lu to %lu", self.title, (unsigned long)self.minValue, (unsigned long)self.maxValue];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView show];
}

- (void)alertEmpty
{
    NSString *title = [NSString stringWithFormat:@"%@ cannot be empty", self.title];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView show];
}

- (IBAction)doneAction:(id)sender
{
    // Trim textField
    NSString *text = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (text.length == 0)
    {
        text = nil;
    }
    
    // Check if value is empty
    if (!text && !self.noneValueAllowed)
    {
        [self alertEmpty];
        return;
    }
    
    if (self.mode == CSNUserInputIntegerMode && text)
    {
        // Parse as integer
        NSUInteger value = text.integerValue;
        
        if (value < self.minValue || value > self.maxValue)
        {
            [self alertRange];
            return;
        }
    }
    
    if (self.delegate) {
        [self.delegate userInputWithIdentifier:self.identifier withValue:text];
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
    
    // Check new character for validity
    if (![self isStringValid:string]) { return NO; }
    
    // Check the length of the new string
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
