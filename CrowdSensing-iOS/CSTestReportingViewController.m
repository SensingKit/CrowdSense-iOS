//
//  CSTestReportingViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 04/05/2017.
//  Copyright © 2017 Kleomenis Katevas. All rights reserved.
//

#import "CSTestReportingViewController.h"

@interface CSTestReportingViewController ()

@property (weak, nonatomic) IBOutlet UITextView *reportTextView;

@end

@implementation CSTestReportingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self reportErrors];
}

- (void)reportErrors
{
    self.reportTextView.text = [self.reportTextView.text stringByAppendingString:[self.errors componentsJoinedByString:@"\n\n"]];
}

- (IBAction)finishAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
