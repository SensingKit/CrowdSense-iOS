//
//  CSMainTableTableViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 19/06/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import "CSMainTableTableViewController.h"
#import "CSRecordViewController.h"
#import "CSRecordingInfoTableViewController.h"
#import "Recording.h"
#import "Recording+Create.h"

@interface CSMainTableTableViewController () <CSRecordViewControllerDelegate>

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSFileManager *fileManager;

@property (nonnull, strong) NSString *experimentType;
@property (nonnull, strong) NSString *experimentCoupon;

@property (nonatomic, strong) NSDictionary *configuration;

@end

@implementation CSMainTableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setupFetchedResultsController];
    
    //self.configuration = [self getConfiguration];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.fileManager = nil;
    self.dateFormatter = nil;
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
        _dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    }
    return _dateFormatter;
}

- (NSFileManager *)fileManager
{
    if (!_fileManager)
    {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}

- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recording"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Recording Cell" forIndexPath:indexPath];
    
    // Get the recording
    Recording *recording = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Configure the cell.
    cell.textLabel.text = recording.title;
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:recording.createDate];
    
    return cell;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Get the recording
        Recording *recording = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        // Delete recording data and folder
        [self deleteRecording:recording];
    }
}

- (void)deleteRecording:(Recording *)recording
{
    // Delete recording data
    [self deleteFolderWithName:recording.storageFolder];
    
    // Delete the recording
    [self.managedObjectContext deleteObject:recording];
}

- (void)deleteFolderWithName:(NSString *)folderName
{
    NSURL *folderPath = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:folderName];
    
    NSError *error;
    [self.fileManager removeItemAtURL:folderPath error:&error];
    
    if (error)
    {
        NSLog(@"Error: %@", error.localizedDescription);
    }
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"New Recording"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        CSRecordViewController *recordViewController = (CSRecordViewController *)navigationController.topViewController;
        
        recordViewController.recording = [Recording recordingWithTitle:@"New Recording"
                                                        withCreateDate:[NSDate date]
                                                inManagedObjectContext:self.managedObjectContext];
        
        recordViewController.delegate = self;
        if (@available(iOS 13.0, *)) {
            recordViewController.modalInPresentation = YES;
        } else {
            // Fallback on earlier versions
            recordViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        }
    }
    else if ([segue.identifier isEqualToString:@"Recording Info"]) {
        
        CSRecordingInfoTableViewController *recordingInfoController = (CSRecordingInfoTableViewController *)segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Recording *recording = [self.fetchedResultsController objectAtIndexPath:indexPath];
        recordingInfoController.recording = recording;
    }
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

@end
