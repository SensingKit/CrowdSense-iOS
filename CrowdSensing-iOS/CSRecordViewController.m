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

#import <SensingKit/SensingKit.h>
#import "NSString+CSTimeInterval.h"

@import CoreText;

typedef NS_ENUM(NSUInteger, CSStartButtonMode) {
    CSStartButtonStartMode,
    CSStartButtonPauseMode,
    CSStartButtonContinueMode
};

typedef NS_ENUM(NSUInteger, CSRecordViewControllerAlertType) {
    CSRecordViewControllerSaveRecordingAlertType,
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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bookmarkButton;

@property (nonatomic) CSStartButtonMode startButtonMode;

@property (strong, nonatomic) NSDateFormatter *timestampDateFormatter;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic, readonly) NSDate *duration;
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
    
    // Set fond of the timestamp label
    NSArray *monospacedSetting = @[@{UIFontFeatureTypeIdentifierKey: @(kNumberSpacingType),
                                     UIFontFeatureSelectorIdentifierKey: @(kMonospacedNumbersSelector)}];
    
    UIFontDescriptor *newDescriptor = [[self.timestampLabel.font fontDescriptor] fontDescriptorByAddingAttributes:@{UIFontDescriptorFeatureSettingsAttribute: monospacedSetting}];
    
    self.timestampLabel.font = [UIFont fontWithDescriptor:newDescriptor size:0];
    
    // Set in the model
    self.recording.createDate = createDate;
    self.recording.storageFolder = folderName;
    
    // Create the SensingSession
    self.sensingSession = [[CSSensingSession alloc] initWithFolderName:folderName];
    
    // Update the status of the Start Button
    [self updateStartButtonStatus];
}

- (NSDate *)duration
{
    return [NSDate dateWithTimeIntervalSince1970:self.timeElapsed];
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

- (void)setStartButtonMode:(CSStartButtonMode)startButtonMode
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
            
            if (self.sensingSession.sensorsEnabledCount == 0)
            {
                [self alertEnableSensors];
                return;
            }
            
            NSLog(@"Start Action");
            [self startTimer];
            
            // Disable Done and Setup buttons
            self.doneButton.enabled = NO;
            self.bookmarkButton.enabled = NO;
            self.setupButton.enabled = NO;
            self.setupButton.type = CSRoundButtonStrokedDeactivatedType;
            
            // Add to the list
            [self addLogEntryWithLabel:@"Start"];
            
            // Sensing
            [self.sensingSession start:nil];
            
            // Proximity Monitoring and idle timer
            [UIDevice currentDevice].proximityMonitoringEnabled = YES;
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            
            self.startButtonMode = CSStartButtonPauseMode;
            
            break;
            
        case CSStartButtonPauseMode:
            
            NSLog(@"Pause Action");
            [self pauseTimer];
            
            // Enable Done and Setup buttons
            self.doneButton.enabled = YES;
            self.bookmarkButton.enabled = YES;
            self.setupButton.enabled = YES;
            self.setupButton.type = CSRoundButtonStrokedType;
            
            // Add to the list
            [self addLogEntryWithLabel:@"Stop"];
            
            // Sensing
            [self.sensingSession stop:nil];
            
            // Proximity Monitoring
            [UIDevice currentDevice].proximityMonitoringEnabled = NO;
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            
            self.startButtonMode = CSStartButtonContinueMode;
            
            // Save duration in the Model
            self.recording.duration = self.duration;
            
            break;
            
        case CSStartButtonContinueMode:
            
            if (self.sensingSession.sensorsEnabledCount == 0)
            {
                [self alertEnableSensors];
                return;
            }
            
            NSLog(@"Continue Action");
            [self continueTimer];
            
            // Disable Done and Setup buttons
            self.doneButton.enabled = NO;
            self.bookmarkButton.enabled = NO;
            self.setupButton.enabled = NO;
            self.setupButton.type = CSRoundButtonStrokedDeactivatedType;
            
            // Add to the list
            [self addLogEntryWithLabel:@"Start"];
            
            // Sensing
            [self.sensingSession start:nil];
            
            // Proximity Monitoring
            [UIDevice currentDevice].proximityMonitoringEnabled = YES;
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            
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

- (IBAction)bookmarkButtonAction:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Load Configuration"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *loadAudioAction = [UIAlertAction actionWithTitle:@"Audio"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                                                                      [self loadAudioConfiguration];
                                                                  }];
    
    UIAlertAction *loadMotionProximityAction = [UIAlertAction actionWithTitle:@"Motion & iBeacon™ Proximity"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction *action) {
                                                                          [self loadMotionAndProximityConfiguration];
                                                                      }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             
                                                             // Nothing
                                                         }];
    
    [alertController addAction:loadAudioAction];
    [alertController addAction:loadMotionProximityAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)loadAudioConfiguration
{
    // Set Name
    self.recording.title = @"Audio Recording";
    self.titleLabel.text = self.recording.title;
    
    // Set Sensors
    if ([self.sensingSession isSensorAvailable:Microphone]) {
        [self.sensingSession enableSensor:Microphone withConfiguration:nil withError:nil];
    }
    
    // Update the UI
    [self updateStartButtonStatus];
}

- (void)loadMotionAndProximityConfiguration
{
    // Set Name
    self.recording.title = @"Motion & Proximity Recording";
    self.titleLabel.text = self.recording.title;
    
    // Set Sensors
    if ([self.sensingSession isSensorAvailable:Accelerometer]) {
        [self.sensingSession enableSensor:Accelerometer withConfiguration:nil withError:nil];
    }
    
    if ([self.sensingSession isSensorAvailable:Gyroscope]) {
        [self.sensingSession enableSensor:Gyroscope withConfiguration:nil withError:nil];
    }
    
    if ([self.sensingSession isSensorAvailable:Magnetometer]) {
        [self.sensingSession enableSensor:Magnetometer withConfiguration:nil withError:nil];
    }
    
    if ([self.sensingSession isSensorAvailable:DeviceMotion]) {
        [self.sensingSession enableSensor:DeviceMotion withConfiguration:nil withError:nil];
    }
    
    if ([self.sensingSession isSensorAvailable:MotionActivity]) {
        [self.sensingSession enableSensor:MotionActivity withConfiguration:nil withError:nil];
    }
    
    if ([self.sensingSession isSensorAvailable:Pedometer]) {
        [self.sensingSession enableSensor:Pedometer withConfiguration:nil withError:nil];
    }
    
    if ([self.sensingSession isSensorAvailable:Location]) {
        SKLocationConfiguration *configuration = [[SKLocationConfiguration alloc] init];
        configuration.locationAccuracy = SKLocationAccuracyThreeKilometers;
        configuration.locationAuthorization = SKLocationAuthorizationAlways;
        [self.sensingSession enableSensor:Location withConfiguration:configuration withError:nil];
    }
    
    if ([self.sensingSession isSensorAvailable:iBeaconProximity]) {
        SKiBeaconProximityConfiguration *configuration = [[SKiBeaconProximityConfiguration alloc] initWithUUID:[[NSUUID alloc] initWithUUIDString:@"eeb79aec-022f-4c05-8331-93d9b2ba6dce"]];
        configuration.mode = SKiBeaconProximityModeScanOnly;
        [self.sensingSession enableSensor:iBeaconProximity withConfiguration:configuration withError:nil];
    }
    
    if ([self.sensingSession isSensorAvailable:Battery]) {
        [self.sensingSession enableSensor:Battery withConfiguration:nil withError:nil];
    }
    
    if ([self.sensingSession isSensorAvailable:Heading]) {
        [self.sensingSession enableSensor:Heading withConfiguration:nil withError:nil];
    }
    
    // Update the UI
    [self updateStartButtonStatus];
}

- (void)alertEnableSensors
{
    [self alertWithTitle:@"Unable to Start Recording"
             withMessage:@"Please enable some sensors first using the Setup button."
             withHandler:nil];
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

- (void)showSaveRecordingAlertWithName:(NSString *)name
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Save Recording"
                                                                             message:@"Enter a name for this recording."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // Preload the text with 'New Recording'
        textField.text = name;
        textField.placeholder = name;
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             
                                                             NSString *recordingName = alertController.textFields
                                                             [0].text;
                                                             
                                                             [self showDeleteRecordingAlertForRecordingName:recordingName];
                                                            
                                                         }];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             
                                                             NSString *recordingName = alertController.textFields
                                                             [0].text;
                                                             
                                                             if (recordingName.length > 0)
                                                             {
                                                                 NSLog(@"Save with title: %@", recordingName);
                                                                 
                                                                 // Disable sensors
                                                                 [self.sensingSession disableAllRegisteredSensors:nil];
                                                                 
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
                                                             
                                                         }];
    
    [alertController addAction:saveAction];
    [alertController addAction:deleteAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showDeleteRecordingAlertForRecordingName:(NSString *)recordingName
{
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete\n\"%@\"?", recordingName];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete Recording"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             
                                                             [self showSaveRecordingAlertWithName:self.recording.title];
                                                         }];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction *action) {
                                                             
                                                             NSLog(@"Delete");
                                                             
                                                             // Disable sensors
                                                             [self.sensingSession disableAllRegisteredSensors:nil];
                                                             
                                                             // Close Session
                                                             [self.sensingSession close];
                                                             self.sensingSession = nil;
                                                             
                                                             // Dismiss the view and delete recording
                                                             [self dismissViewControllerAnimated:YES completion:^{
                                                                 
                                                                 // Delete the recording
                                                                 [self.delegate deleteRecording:self.recording];
                                                             }];
                                                         }];
    
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showSetNameAlertWithName:(NSString *)name
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Recording Name"
                                                                             message:@"Enter a name for this recording."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // Preload the text with 'New Recording'
        textField.text = name;
        textField.placeholder = name;
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             
                                                             NSString *recordingName = alertController.textFields
                                                             [0].text;
                                                             
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
                                                         }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction *action) {
                                                         
                                                             NSLog(@"Cancel Set name");
                                                         }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
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

- (void)doneSensorSetup
{
    [self updateStartButtonStatus];
}

- (void)updateStartButtonStatus
{
    if ([self.sensingSession sensorsEnabledCount] > 0)
    {
        self.startButton.type = CSRoundButtonFilledType;
    }
    else
    {
        self.startButton.type = CSRoundButtonFilledDeactivatedType;
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
    // Only update when the screen is on
    if (![UIDevice currentDevice].proximityState)
    {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.startDate];
        timeInterval += self.timeElapsed;
        
        // Update the UI
        [self updateTimerLabelWithTimeInterval:timeInterval];
    }
}

- (void)updateTimerLabelWithTimeInterval:(NSTimeInterval)timeInterval
{
    self.timestampLabel.text = [NSString stringFromTimeInterval:timeInterval];
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
    SKSensorTimestamp *sensorTimestamp = [SKSensorTimestamp sensorTimestampFromTimeInterval:[NSProcessInfo processInfo].systemUptime];
    
    // Add to the Model
    LogEntry *logEntry = [LogEntry logEntryWithLabel:label
                                       withTimestamp:sensorTimestamp.timestamp
                              inManagedObjectContext:self.recording.managedObjectContext];
    
    logEntry.ofRecording = self.recording;
    
    // Also write it in RecordingLog.csv
    NSString *log = [NSString stringWithFormat:@"\"%@\",%f,%@", sensorTimestamp.timestampString, sensorTimestamp.timeIntervalSince1970, label];
    [self.sensingSession addRecordingLog:log];
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
