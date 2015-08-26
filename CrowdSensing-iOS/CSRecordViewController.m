//
//  CSRecordViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 18/07/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSRecordViewController.h"
#import "LogEntry+Create.h"
#import "CSSensingSession.h"

enum CSStartButtonMode : NSUInteger {
    CSStartButtonStartMode,
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

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic) enum CSStartButtonMode startButtonMode;

@property (strong, nonatomic) NSDateFormatter *timerDateFormatter;
@property (strong, nonatomic) NSDateFormatter *timestampDateFormatter;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *duration;
@property (nonatomic) NSTimeInterval timeElapsed;
@property (nonatomic) NSUInteger syncCounter;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSIndexPath *postUpdateScrollTarget;

@property (strong, nonatomic) CSSensingSession *sensingSession;

@end

@implementation CSRecordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    self.syncCounter = 0;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    // Get current date and folder name
    NSDate *createDate = [NSDate date];
    NSString *folderName = [self folderNameForDate:createDate];
    
    // Set it in the UI
    self.timeLabel.text = [self datetimeDateFormatter:createDate];
    
    // Set in the model
    self.recording.createDate = createDate;
    self.recording.storageFolder = folderName;
    
    // Create the SensingSession
    self.sensingSession = [[CSSensingSession alloc] initWithFolderName:folderName];
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

- (NSString *)folderNameForDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH.mm.ss"];
    
    return [dateFormatter stringFromDate:date];
}

- (NSString *)datetimeDateFormatter:(NSDate *)date
{
    // Format: 17/10/14 12:29.15
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/YY HH:mm.ss"];
    
    return [dateFormatter stringFromDate:date];
}

- (void)setStartButtonMode:(enum CSStartButtonMode)startButtonMode
{
    switch (startButtonMode) {
        case CSStartButtonStartMode:
            [self.startButton setTitle:@"Start"];
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
            
            // Disable Done and Setup buttons
            self.doneButton.enabled = NO;
            self.setupButton.enabled = NO;
            
            // Add to the list
            [self addLogEntryWithLabel:@"Start"];
            
            // Sensing
            [self.sensingSession start];
            
            // Proximity Monitoring
            [UIDevice currentDevice].proximityMonitoringEnabled = YES;
            
            self.startButtonMode = CSStartButtonPauseMode;
            
            break;
            
        case CSStartButtonPauseMode:
            
            NSLog(@"Pause Action");
            [self pauseTimer];
            
            // Enable Done and Setup buttons
            self.doneButton.enabled = YES;
            self.setupButton.enabled = YES;
            
            // Add to the list
            [self addLogEntryWithLabel:@"Stop"];
            
            // Sensing
            [self.sensingSession stop];
            
            // Proximity Monitoring
            [UIDevice currentDevice].proximityMonitoringEnabled = NO;
            
            self.startButtonMode = CSStartButtonContinueMode;
            
            // Save duration in the Model
            self.recording.duration = self.duration;
            
            break;
            
        case CSStartButtonContinueMode:
            
            NSLog(@"Continue Action");
            [self continueTimer];
            
            // Disable Done and Setup buttons
            self.doneButton.enabled = NO;
            self.setupButton.enabled = NO;
            
            // Add to the list
            [self addLogEntryWithLabel:@"Start"];
            
            // Sensing
            [self.sensingSession start];
            
            // Proximity Monitoring
            [UIDevice currentDevice].proximityMonitoringEnabled = YES;
            
            self.startButtonMode = CSStartButtonPauseMode;
            
            break;
            
        default:
            NSLog(@"Unknown CSStartButtonMode: %ld", (long) self.startButtonMode);
            break;
    }
}

- (IBAction)syncButtonAction:(CSRoundButton *)sender
{
    // Increase counter
    self.syncCounter += 1;
    
    // Add to the list
    [self addLogEntryWithLabel:[NSString stringWithFormat:@"Sync %lu", (unsigned long)self.syncCounter]];
}

- (IBAction)doneButtonAction:(id)sender
{
    [self showSaveRecordingAlertWithName:self.recording.title];
}

- (void)titleLabelTap:(id)sender
{
    if (self.startButtonMode != CSStartButtonPauseMode)
    {
        [self showSetNameAlertWithName:self.recording.title];
    }
}

- (void)showSaveRecordingAlertWithName:(NSString *)name
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save Recording"
                                                        message:@"Enter a name for this recording."
                                                       delegate:self
                                              cancelButtonTitle:@"Delete"
                                              otherButtonTitles:@"Save", nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = CSRecordViewControllerSaveRecordingAlertType;
    
    // Preload the text with 'New Recording'
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.text = name;
    textField.placeholder = name;
    textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    [alertView show];
}

- (void)showDeleteRecordingAlertForRecordingName:(NSString *)recordingName
{
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete\n\"%@\"?", recordingName];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Sensor Recording"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Delete", nil];
    
    alertView.tag = CSRecordViewControllerDeleteRecordingAlertType;
    
    [alertView show];
}

- (void)showSetNameAlertWithName:(NSString *)name
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Recording Name"
                                                        message:@"Enter a name for this recording."
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
            if (recordingName.length > 0)
            {
                NSLog(@"Save with title: %@", recordingName);
                
                // Disable sensors
                [self.sensingSession disableAllRegisteredSensors];
                
                // Close Session
                [self.sensingSession close];
                self.sensingSession = nil;
                
                // Save the title
                self.recording.title = recordingName;
                
                // Save the duration
                self.recording.duration = self.duration;
                
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
                // Ask again
                [self showSaveRecordingAlertWithName:self.recording.title];
            }
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
                
                // Delete the recording
                [self.delegate deleteRecording:self.recording];
            }];
        }
        else if ([buttonText isEqualToString:@"Cancel"])
        {
            [self showSaveRecordingAlertWithName:self.recording.title];
        }
        else
        {
            NSLog(@"Unknown button with text '%@'", buttonText);
        }
        
    }
    else if (type == CSRecordViewControllerSetNameAlertType)
    {
        // When tapping on the Title Label
        NSString *buttonText = [alertView buttonTitleAtIndex:buttonIndex];
        
        if ([buttonText isEqualToString:@"OK"])
        {
            NSString *recordingName = [alertView textFieldAtIndex:0].text;
            
            if (recordingName.length > 0)
            {
                // Save the title
                self.recording.title = recordingName;
            
                // Update the Label
                self.titleLabel.text = recordingName;
            }
            else
            {
                // Ask again
                [self showSetNameAlertWithName:self.recording.title];
            }
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Setup"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        CSSetupTableViewController *setupTableViewController = (CSSetupTableViewController *)navigationController.topViewController;
        
        setupTableViewController.delegate = self;
        setupTableViewController.sensingSession = self.sensingSession;
    }
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fetchedResultsController.sections[section] numberOfObjects];
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
    self.duration = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    self.timestampLabel.text = [self.timerDateFormatter stringFromDate:self.duration];
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
    // Add to the Model
    LogEntry *logEntry = [LogEntry logEntryWithLabel:label
                                       withTimestamp:[NSDate date]
                              inManagedObjectContext:self.recording.managedObjectContext];
    
    logEntry.ofRecording = self.recording;
    
    // Also write it in Information.csv
    double timestampEpoch = logEntry.timestamp.timeIntervalSince1970;
    NSString *timestamp = [self.timestampDateFormatter stringFromDate:logEntry.timestamp];
    NSString *information = [NSString stringWithFormat:@"%f,%@,%@", timestampEpoch, timestamp, label];
    [self.sensingSession addInformation:information];
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
