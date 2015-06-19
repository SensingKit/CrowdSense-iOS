//
//  CSMainTableTableViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 19/06/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import "CSMainTableTableViewController.h"
#import "CSRecordViewController.h"
#import "Recording.h"
#import "Recording+Create.h"

@interface CSMainTableTableViewController ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation CSMainTableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [self setupFetchedResultsController];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Recording Cell" forIndexPath:indexPath];
    
    // Get the recording
    Recording *recording = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Configure the cell.
    cell.textLabel.text = recording.title;
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:recording.createDate];
    
    return cell;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"New Recording"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        CSRecordViewController *recordViewController = (CSRecordViewController *)navigationController.topViewController;
        
        recordViewController.recording = [Recording recordingWithTitle:@"New Recording"
                                                        withCreateDate:[NSDate date]
                                                inManagedObjectContext:self.managedObjectContext];
        
    }
}

@end
