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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"New Recording"])
    {
        CSRecordViewController *viewController = segue.destinationViewController;
        
        SKRecording *newRecording = [self.sensingKitLib newRecording];
        
        viewController.recording = newRecording;
    }
    
    
    
    //viewController.recording = [
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
    SKRecording *recording = self.recordings[indexPath.row];
    
    // Set up the cell...
    cell.textLabel.text = @"New Recording";
    cell.detailTextLabel.text = @"3 hours";
    
    return cell;
}

@end
