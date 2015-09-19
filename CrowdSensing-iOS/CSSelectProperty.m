//
//  CSSelectProperty.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 19/09/2015.
//  Copyright © 2015 Kleomenis Katevas. All rights reserved.
//

#import "CSSelectProperty.h"

@interface CSSelectProperty ()

@end

@implementation CSSelectProperty


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.elements.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.elements[indexPath.row];
    
    if (self.selectedIndex == indexPath.row)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self deselectRowWithIndex:self.selectedIndex];
    [self selectRowWithIndex:indexPath.row];
    
    self.selectedIndex = indexPath.row;
    
    [self.delegate selectPropertyWithIdentifier:self.identifier withIndex:indexPath.row withValue:self.elements[indexPath.row]];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectRowWithIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)deselectRowWithIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

@end
