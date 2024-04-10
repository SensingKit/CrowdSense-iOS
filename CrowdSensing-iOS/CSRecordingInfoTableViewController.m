//
//  CSRecordingInfoTableViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 26/08/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import "CSRecordingInfoTableViewController.h"
#import "LogEntry.h"
#import "NSString+CSTimeInterval.h"

// ZipArchive
#import "SSZipArchive.h"

@interface CSRecordingInfoTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSDateFormatter *timestampDateFormatter;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@end

@implementation CSRecordingInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.recording.title;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    self.timestampDateFormatter = nil;
}

- (NSString *)datetimeDateFormatter:(NSDate *)date
{
    // Format: 17/10/14 12:29.15
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/YY HH:mm.ss"];
    
    return [dateFormatter stringFromDate:date];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Section 1: Recording Details
    // Section 2: Recording Log
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        // Row 1: Create Date
        // Row 2: Duration
        // Row 3: Storage Folder
        return 3;
    }
    else
    {
        // All Recording Logs
        return [self.fetchedResultsController.sections[0] numberOfObjects];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Information Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"Create Date";
            cell.detailTextLabel.text = [self datetimeDateFormatter:self.recording.createDate];
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = @"Duration";
            cell.detailTextLabel.text = [NSString stringFromTimeInterval:self.recording.duration.timeIntervalSince1970];
        }
        else if (indexPath.row == 2)
        {
            cell.textLabel.text = @"Storage Folder";
            cell.detailTextLabel.text = self.recording.storageFolder;
        }
        else
        {
            NSLog(@"Unknown row %ld for section 0.", (long)indexPath.row);
        }
    }
    else
    {
        // Get the item
        LogEntry *logEntry = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        
        // Set up the cell...
        cell.textLabel.text = [self.timestampDateFormatter stringFromDate:logEntry.timestamp];
        cell.detailTextLabel.text = logEntry.label;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"Recording Details";
    }
    if (section == 1)
    {
        return @"Recording Log";
    }
    else
    {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"Recorded data can be accessed using iTunes (through iTunes file sharing). Alternatively you can use the Share button to share the data with nearby devices or over the Internet.";
    }
    else if (section == 1)
    {
        // If recording log is empty
        if (![self.fetchedResultsController.fetchedObjects count])
        {
            return @"Empty recording log.";
        }
        else
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
}

#pragma mark - Sharing

- (IBAction)shareAction:(id)sender
{
    NSString *attachmentName = [NSString stringWithFormat:@"%@.zip", self.recording.storageFolder];
    NSURL *filesDirectory = [self storageFolderFromRecording:self.recording];
    NSURL *attachment = [self zipFileWithName:attachmentName];
    
    // Zip Directory
    if ([[NSFileManager defaultManager] fileExistsAtPath:attachment.path])
    {
        NSLog(@"File already exist. No need to create it again.");
    }
    else if (![SSZipArchive createZipFileAtPath:attachment.path withContentsOfDirectory:filesDirectory.path keepParentDirectory:YES])
    {
        NSLog(@"Zip file could not be created.");
    }
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[attachment] applicationActivities:nil];
    
    // Call this when the activity is completed
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        
        // Delete the temporary file
        [[NSFileManager defaultManager] removeItemAtURL:attachment error:nil];
    }];
    
    NSArray *array = @[UIActivityTypePostToFacebook,
                       UIActivityTypePostToTwitter,
                       UIActivityTypePostToWeibo,
                       UIActivityTypePrint,
                       UIActivityTypeCopyToPasteboard,
                       UIActivityTypeAssignToContact,
                       UIActivityTypeSaveToCameraRoll,
                       UIActivityTypeAddToReadingList,
                       UIActivityTypePostToFlickr,
                       UIActivityTypePostToVimeo,
                       UIActivityTypePostToTencentWeibo,
                       UIActivityTypeOpenInIBooks,
                       UIActivityTypeMarkupAsPDF];
    
    // Exclude Activities
    activityViewController.excludedActivityTypes = array;
    
    activityViewController.popoverPresentationController.barButtonItem = self.shareButton;
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (NSURL *)zipFileWithName:(NSString *)name
{
    return [[self applicationCachesDirectory] URLByAppendingPathComponent:name isDirectory:NO];
}

- (NSURL *)storageFolderFromRecording:(Recording *)recording
{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:self.recording.storageFolder isDirectory:YES];
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)applicationCachesDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
