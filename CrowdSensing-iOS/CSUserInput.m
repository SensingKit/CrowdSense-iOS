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

- (void)alertRange
{
    [self alertWithTitle:[NSString stringWithFormat:@"\"%@\" is not valid", self.textField.text]
             withMessage:[NSString stringWithFormat:@"%@ ranges from %lu to %lu", self.title, (unsigned long)self.minValue, (unsigned long)self.maxValue]
             withHandler:nil];
}

- (void)alertEmpty
{
    [self alertWithTitle: [NSString stringWithFormat:@"%@ cannot be empty", self.title]
             withMessage:@""
             withHandler:nil];
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
