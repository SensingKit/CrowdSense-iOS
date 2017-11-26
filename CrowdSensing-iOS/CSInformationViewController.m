//
//  CSInformationViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 10/03/2017.
//  Copyright © 2017 Kleomenis Katevas. All rights reserved.
//

#import "CSInformationViewController.h"
#import "CSTestDeviceViewController.h"

@interface CSInformationViewController ()

@end

@implementation CSInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // init information dict
    self.information = [[NSMutableDictionary alloc] initWithCapacity:30];
    self.information[@"Type"] = self.type;
    self.information[@"Coupon"] = self.coupon;
    
    [self checkForUpdate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    CSTestDeviceViewController *controller = (CSTestDeviceViewController *)segue.destinationViewController;
    controller.type = self.type;
    controller.information = self.information;
}

- (IBAction)iAgreeAction:(id)sender
{
    // No need to do anything
}

- (IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)checkForUpdate {

    NSURL *url = [NSURL URLWithString:@"https://sensingkit.org/CrowdSenseData.json"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    if (data) {
        NSError *error = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        if (response) {
            NSString *latestVersion = response[@"latestVersion"];
            NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            
            if (![latestVersion isEqualToString:currentVersion]) {
                [self askToUpdate];
            }
        }
    }
}

- (void)askToUpdate
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Update CrowdSense"
                                          message:@"There is an updated version available in the App Store. Please update to the latest version."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Update"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * _Nonnull action) {
                                       
                                       NSString *iTunesLink = @"https://itunes.apple.com/us/app/crowdsense/id930853606?ls=1&mt=8";
                                       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                                       
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action) {
                                   // Ignore
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    // Show the alert
    [self presentViewController:alertController animated:YES completion:nil];
}



@end
