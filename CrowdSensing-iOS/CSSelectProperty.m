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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.selectedValue
}


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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row;
    
    [self.delegate selectPropertyWithIdentifier:self.identifier withIndex:indexPath.row withValue:self.elements[indexPath.row]];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
