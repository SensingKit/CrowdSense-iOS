//
//  CSRecordViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 18/07/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSRecordViewController.h"
#import "LogEntry+Create.h"

enum CSStartButtonMode : NSUInteger {
    CSStartButtonStartMode,
    CSStartButtonStopMode,
    CSStartButtonPauseMode,
    CSStartButtonContinueMode
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

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet CSRoundButton *setupButton;
@property (weak, nonatomic) IBOutlet CSRoundButton *startButton;
@property (weak, nonatomic) IBOutlet CSRoundButton *syncButton;

@property (nonatomic) enum CSStartButtonMode startButtonMode;

@property (strong, nonatomic) NSDateFormatter *timerDateFormatter;
@property (strong, nonatomic) NSDateFormatter *timestampDateFormatter;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *startDate;
@property (nonatomic) NSTimeInterval timeElapsed;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSIndexPath *postUpdateScrollTarget;

@end

@implementation CSRecordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Init SensingKitLib
    //NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"F8E5698A-3AF5-491B-BA88-33075574F1C6"];
    NSAssert(self.recording, @"recording cannot be nil");
	
    // Init Button Modes
    self.startButtonMode = CSStartButtonStartMode;
    
    // Setup Title
    self.titleLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleLabelTap:)];
    [self.titleLabel addGestureRecognizer:tapGesture];
    
    // Setup Round Buttons
    self.setupButton.type = CSRoundButtonStrokedType;
    self.setupButton.title = @"Setup";

    self.startButton.type = CSRoundButtonFilledType;
    
    self.syncButton.type = CSRoundButtonStrokedType;
    self.syncButton.title = @"Sync";
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (NSDateFormatter *)timerDateFormatter
{
    if (!_timerDateFormatter)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss,SSS"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
        _timerDateFormatter = dateFormatter;
    }
    return _timerDateFormatter;
}

- (NSDateFormatter *)timestampDateFormatter
{
    if (!_timestampDateFormatter)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss,SSS"];
        _timestampDateFormatter = dateFormatter;
    }
    return _timestampDateFormatter;
}

- (void)setStartButtonMode:(enum CSStartButtonMode)startButtonMode
{
    switch (startButtonMode) {
        case CSStartButtonStartMode:
            [self.startButton setTitle:@"Start"];
            break;
            
        case CSStartButtonStopMode:
            [self.startButton setTitle:@"Stop"];
            break;
            
        case CSStartButtonPauseMode:
            [self.startButton setTitle:@"Stop"];
            break;
            
        case CSStartButtonContinueMode:
            [self.startButton setTitle:@"Start"];
            break;
            
        default:
            NSLog(@"Unknown CSStartButtonMode: %ld", (long) startButtonMode);
            break;
    }
    
    _startButtonMode = startButtonMode;
}

- (IBAction)startButtonAction:(CSRoundButton *)sender
{
    switch (self.startButtonMode) {
        case CSStartButtonStartMode:
            
            NSLog(@"Start Action");
            [self startTimer];
            
            // Add to the list
            [self addLogEntryWithLabel:@"Start"];
            
            // SensingKit
            //[self.recording startSensing];
            
            self.startButtonMode = CSStartButtonPauseMode;
            
            break;
            
        case CSStartButtonStopMode:
            
            NSLog(@"Stop Action");
            [self stopTimer];
            
            // Add to the list
            [self addLogEntryWithLabel:@"Stop"];
            
            // SensingKit
            //[self.recording stopSensing];
            
            self.startButtonMode = CSStartButtonStartMode;
            
            break;
            
        case CSStartButtonPauseMode:
            
            NSLog(@"Pause Action");
            [self pauseTimer];
            
            // Add to the list
            [self addLogEntryWithLabel:@"Stop"];
            
            // SensingKit
            //[self.recording pauseSensing];
            
            self.startButtonMode = CSStartButtonContinueMode;
            
            break;
            
        case CSStartButtonContinueMode:
            
            NSLog(@"Continue Action");
            [self continueTimer];
            
            // Add to the list
            [self addLogEntryWithLabel:@"Start"];
            
            // SensingKit
            //[self.recording continueSensing];
            
            self.startButtonMode = CSStartButtonPauseMode;
            
            break;
            
        default:
            NSLog(@"Unknown CSStartButtonMode: %ld", (long) self.startButtonMode);
            break;
    }
}

- (IBAction)syncButtonAction:(CSRoundButton *)sender
{
    // Add to the list
    [self addLogEntryWithLabel:@"Sync"];
    
    // SensingKit
    //[self.recording saveSyncPoint];
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
    textField.text = self.recording.title;
    textField.placeholder = self.recording.title;
    
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
        
        if ([buttonText isEqualToString:@"Delete"])
        {
            [self showDeleteRecordingAlertForRecordingName:recordingName];
            
        }
        else if ([buttonText isEqualToString:@"Save"])
        {
            NSLog(@"Save with title: %@", recordingName);
            
            // Save the title
            self.recording.title = recordingName;
            
            // Update the Label
            self.titleLabel.text = recordingName;
            
            // Dismiss the view
            [self dismissViewControllerAnimated:YES completion:^{
                
                // Save
                NSManagedObjectContext *context = self.recording.managedObjectContext;
                [context save:NULL];
            }];
        }
        else
        {
            NSLog(@"Unknown button with text '%@'", buttonText);
        }
        
    }
    else if (type == CSRecordViewControllerDeleteRecordingAlertType)
    {
        NSString *buttonText = [alertView buttonTitleAtIndex:buttonIndex];
        
        if ([buttonText isEqualToString:@"Delete"])
        {
            NSLog(@"Delete");
            
            // Dismiss the view and delete recording
            [self dismissViewControllerAnimated:YES completion:^{
                
                NSManagedObjectContext *context = self.recording.managedObjectContext;
                
                // Delete recording
                [context deleteObject:self.recording];
                
                // Save
                [context save:NULL];
            }];
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
        
        if ([buttonText isEqualToString:@"OK"])
        {
            NSString *recordingName = [alertView textFieldAtIndex:0].text;
            
            // Save the title
            self.recording.title = recordingName;
            
            // Update the Label
            self.titleLabel.text = recordingName;
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
    return [[_fetchedResultsController sections] count];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id sectionInfo = [_fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
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
    LogEntry *logEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Set up the cell...
    cell.textLabel.text = [self.timestampDateFormatter stringFromDate:logEntry.timestamp];
    cell.detailTextLabel.text = logEntry.label;
    
    return cell;
}

#pragma mark Timer methods

- (void)startTimer
{
    self.timeElapsed = 0;
    
    [self continueTimer];
}

- (void)stopTimer
{
    [self pauseTimer];
    
    self.timeElapsed = 0;
}

- (void)pauseTimer
{
    [self.timer invalidate];
    self.timer = nil;
    
    [self timerTick];
    
    self.timeElapsed += [[NSDate date] timeIntervalSinceDate:self.startDate];
}

- (void)continueTimer
{
    self.startDate = [NSDate date];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 / 12.0
                                                  target:self
                                                selector:@selector(timerTick)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)timerTick
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.startDate];
    timeInterval += self.timeElapsed;
    
    // Update the UI
    [self updateTimerLabelWithTimeInterval:timeInterval];
}

- (void)updateTimerLabelWithTimeInterval:(NSTimeInterval)timeInterval
{
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    self.timestampLabel.text = [self.timerDateFormatter stringFromDate:timerDate];
}


#pragma mark CoreData

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"LogEntry"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"ofRecording = %@", self.recording];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.recording.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}

- (void)addLogEntryWithLabel:(NSString *)label
{
    LogEntry *logEntry = [LogEntry logEntryWithLabel:label
                                       withTimestamp:[NSDate date]
                              inManagedObjectContext:self.recording.managedObjectContext];
    
    logEntry.ofRecording = self.recording;
}


#pragma mark NSFetchedResultsController delegates

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            
            // For scrolling to bottom
            self.postUpdateScrollTarget = newIndexPath;
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    
    if (self.postUpdateScrollTarget)
    {
        [self.tableView scrollToRowAtIndexPath:self.postUpdateScrollTarget atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    self.postUpdateScrollTarget = nil;
}

@end
