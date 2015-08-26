//
//  CSRecordingInfoTableViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 26/08/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import "CSRecordingInfoTableViewController.h"
#import "LogEntry.h"
#import "GZIP.h"

@interface CSRecordingInfoTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSDateFormatter *timestampDateFormatter;

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
        // Row 2: Storage Folder
        return 2;
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

#pragma mark - Sharing

- (IBAction)shareAction:(id)sender
{
    NSString *text = @"TEXT";
    
    NSString *path = [NSString stringWithFormat:@"%@/Information.csv", self.recording.storageFolder];
    NSURL *attachment = [NSURL URLWithString:path relativeToURL:[self applicationDocumentsDirectory]];

    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[text, attachment] applicationActivities:nil];
    
    // Exclude Activities
    activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook,
                                                     UIActivityTypePostToTwitter,
                                                     UIActivityTypePostToWeibo,
                                                     UIActivityTypeMessage,
                                                     UIActivityTypePrint,
                                                     UIActivityTypeCopyToPasteboard,
                                                     UIActivityTypeAssignToContact,
                                                     UIActivityTypeSaveToCameraRoll,
                                                     UIActivityTypeAddToReadingList,
                                                     UIActivityTypePostToFlickr,
                                                     UIActivityTypePostToVimeo,
                                                     UIActivityTypePostToTencentWeibo];
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
