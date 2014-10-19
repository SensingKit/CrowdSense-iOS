//
//  CSRecordViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 18/07/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSRecordViewController.h"

enum CSStartButtonMode : NSUInteger {
    CSStartButtonStartMode,
    CSStartButtonStopMode
};

enum CSRecordViewControllerAlertType : NSUInteger {
    CSRecordViewControllerSaveRecordingAlertType,
    CSRecordViewControllerDeleteRecordingAlertType,
    CSRecordViewControllerSetNameAlertType
};

@interface CSRecordViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UITableView *logTableView;

@property (weak, nonatomic) IBOutlet CSRoundButton *setupButton;
@property (weak, nonatomic) IBOutlet CSRoundButton *startButton;
@property (weak, nonatomic) IBOutlet CSRoundButton *syncButton;

@property (nonatomic) enum CSStartButtonMode startButtonMode;

@end

@implementation CSRecordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Init Button Modes
    self.startButtonMode = CSStartButtonStartMode;
    
    self.titleLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleLabelTap:)];
    [self.titleLabel addGestureRecognizer:tapGesture];
}

- (void)setStartButtonMode:(enum CSStartButtonMode)startButtonMode
{
    switch (startButtonMode) {
        case CSStartButtonStartMode:
            [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
            break;
            
        case CSStartButtonStopMode:
            [self.startButton setTitle:@"Stop" forState:UIControlStateNormal];
            break;
            
        default:
            // Error
            break;
    }
    
    _startButtonMode = startButtonMode;
}

- (IBAction)startButtonAction:(CSRoundButton *)sender
{
    switch (self.startButtonMode) {
        case CSStartButtonStartMode:
            
            NSLog(@"Start Action");
            self.startButtonMode = CSStartButtonStopMode;
            
            break;
            
        case CSStartButtonStopMode:
            
            NSLog(@"Stop Action");
            self.startButtonMode = CSStartButtonStartMode;
            
            break;
            
        default:
            // Error
            break;
    }
}

- (IBAction)syncButtonAction:(CSRoundButton *)sender
{
    NSLog(@"Sync Action");
}

- (IBAction)doneButtonAction:(id)sender
{
    [self showSaveRecordingAlert];
}

- (void)titleLabelTap:(id)sender
{
    [self showSetNameAlertWithName:nil];
}

- (void)showSaveRecordingAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save Sensor Recording"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Delete"
                                              otherButtonTitles:@"Save", nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = CSRecordViewControllerSaveRecordingAlertType;
    
    // Preload the text with 'New Recording'
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.text = @"New Recording";
    textField.placeholder = @"New Recording";
    
    [alertView show];
}

- (void)showDeleteRecordingAlertForRecordingName:(NSString *)recordingName
{
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete\n\"%@\"?", recordingName];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Sensor Recording"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Delete"
                                              otherButtonTitles:@"Cancel", nil];
    
    alertView.tag = CSRecordViewControllerDeleteRecordingAlertType;
    
    [alertView show];
}

- (void)showSetNameAlertWithName:(NSString *)name
{
    if (!name) { name = @"New Recording"; }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Recording Name"
                                                        message:@"Enter a name for this sensor recording."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = CSRecordViewControllerSetNameAlertType;
    
    // Preload the text with 'New Recording'
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.text = name;
    textField.placeholder = name;
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    enum CSRecordViewControllerAlertType type = alertView.tag;
    
    if (type == CSRecordViewControllerSaveRecordingAlertType)
    {
        NSString *buttonText = [alertView buttonTitleAtIndex:buttonIndex];
        
        NSString *recordingName = [alertView textFieldAtIndex:0].text;
        
        if([buttonText isEqualToString:@"Delete"])
        {
            [self showDeleteRecordingAlertForRecordingName:recordingName];
            
        }
        else if ([buttonText isEqualToString:@"Save"])
        {
            NSLog(@"Save with name: %@", recordingName);
            
            // Dismiss the view
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
        else
        {
            NSLog(@"Unknown button with text '%@'", buttonText);
        }
        
    }
    else if (type == CSRecordViewControllerDeleteRecordingAlertType)
    {
        NSString *buttonText = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([buttonText isEqualToString:@"Delete"])
        {
            NSLog(@"Delete");
            
            // Dismiss the view
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
        else if ([buttonText isEqualToString:@"Cancel"])
        {
            [self showSaveRecordingAlert];
        }
        else
        {
            NSLog(@"Unknown button with text '%@'", buttonText);
        }
        
    }
    else if (type == CSRecordViewControllerSetNameAlertType)
    {
        NSString *buttonText = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([buttonText isEqualToString:@"OK"])
        {
            NSLog(@"Set name");
        }
        else if ([buttonText isEqualToString:@"Cancel"])
        {
            NSLog(@"Cancel Set name");
        }
        else
        {
            NSLog(@"Unknown button with text '%@'", buttonText);
        }
    }
    else
    {
        NSLog(@"Unknown CSRecordViewControllerAlertType: %ld", (long) type);
    }
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;  // TODO: Change this
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Log Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Get the item
    
    // Set up the cell...
    cell.textLabel.text = @"00:00:00,000";
    cell.detailTextLabel.text = @"Start";
    
    return cell;
}

@end
