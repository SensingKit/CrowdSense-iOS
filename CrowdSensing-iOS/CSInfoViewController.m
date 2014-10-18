//
//  CSInfoViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 18/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSInfoViewController.h"

@interface CSInfoViewController ()

@end

@implementation CSInfoViewController

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

- (IBAction)DoneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
