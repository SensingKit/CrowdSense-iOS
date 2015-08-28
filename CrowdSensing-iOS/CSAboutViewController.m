//
//  CSAboutViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 18/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSAboutViewController.h"

@interface CSAboutViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation CSAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.textView setContentOffset:CGPointZero animated:NO];
}

- (IBAction)DoneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
