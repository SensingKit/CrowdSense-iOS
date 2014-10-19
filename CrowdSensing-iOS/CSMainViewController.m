//
//  CSMainViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 18/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSMainViewController.h"
//#import "SensingKitLib"

@interface CSMainViewController ()

//@property (nonatomic, strong) SensingKitLib *sensingKitLib;
@property (weak, nonatomic) IBOutlet UITableView *recordingsTableView;

@end

@implementation CSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    static NSString *CellIdentifier = @"Recording Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Get the item
    
    // Set up the cell...
    cell.textLabel.text = @"New Recording";
    cell.detailTextLabel.text = @"3 hours";
    
    return cell;
}

@end
