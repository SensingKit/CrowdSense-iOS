//
//  CSMainViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 18/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSMainViewController.h"
#import "CSRecordViewController.h"

@interface CSMainViewController ()

@property (nonatomic, strong) SensingKitLib *sensingKitLib;
@property (nonatomic, weak) IBOutlet UITableView *recordingsTableView;
@property (nonatomic, strong) NSArray *recordings;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation CSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Init SensingKitLib
    self.sensingKitLib = [SensingKitLib sharedSensingKitLib];
    
    // Get recordings ref
    self.recordings = self.sensingKitLib.recordings;
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *navigationVontroller = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"New Recording"])
    {
        CSRecordViewController *viewController = (CSRecordViewController *)navigationVontroller.topViewController;
        
        SKRecording *newRecording = [self.sensingKitLib newRecording];
        
        viewController.recording = newRecording;
    }
    else if ([segue.identifier isEqualToString:@"Show Recording Details"])
    {
        // Nothing at the moment
    }
    else if ([segue.identifier isEqualToString:@"About us"])
    {
        // Ignore
    }
    else
    {
        NSLog(@"WARNING: Unknown segue '%@'.", segue.identifier);
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
    return self.recordings.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Recording Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Get the item
    NSDictionary *recording = self.recordings[indexPath.row];
    
    // Set up the cell...
    cell.textLabel.text = recording[@"name"];
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:recording[@"create_date"]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the item
    NSDictionary *recording = self.recordings[indexPath.row];
    [self.sensingKitLib deleteRecordingWithDetails:recording];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

@end
