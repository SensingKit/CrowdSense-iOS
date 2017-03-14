//
//  CSSubmitDataViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 10/03/2017.
//  Copyright © 2017 Kleomenis Katevas. All rights reserved.
//

#import "CSSubmitDataViewController.h"
@import AFNetworking;

@interface CSSubmitDataViewController ()

@property (weak, nonatomic) IBOutlet UIProgressView *dataProgressView;
@property (weak, nonatomic) IBOutlet UILabel *dataProgressLabel;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UITextView *statusTextView;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation CSSubmitDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Configure NSDateFormatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy_MM_dd_HH_mm_ss";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    self.dateFormatter = dateFormatter;
    
    NSLog(@"Testing Date: %@", [self.dateFormatter stringFromDate:[NSDate date]]);

    // Start data uploading
    [self uploadData];
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

- (IBAction)finishAction:(id)sender
{
    // Should be disabled initially
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)uploadData
{
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"https://sensingkit.herokuapp.com" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        // Set password
        [formData appendPartWithFormData:[@"b+FRongauiv/bKy1egB8AbB2HIICNbhX5IqlbMWcfn4" dataUsingEncoding:NSUTF8StringEncoding] name:@"password"];
        
        // Set data
        //NSURL *dataUrl = [NSURL URLWithString:@"..."];
        //[formData appendPartWithFileURL:dataUrl name:@"uploadedFile" fileName:@"filename.zip" mimeType:@"application/zip" error:nil];
        
        // Tmp data for testing reasons
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.information
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        
        NSString *filename = [NSString stringWithFormat:@"u%@__%@.json",
                              self.information[@"Questionnaire"][@"ID"],
                              [self.dateFormatter stringFromDate:[NSDate date]]];
        
        [formData appendPartWithFileData:jsonData name:@"uploadedFile" fileName:filename mimeType:@"application/json"];
        
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      
                      // Dispatch to the main queue for UI updates
                      dispatch_async(dispatch_get_main_queue(), ^{
                          
                          // Update the progress view
                          [self.dataProgressView setProgress:uploadProgress.fractionCompleted];
                          
                          // Update label
                          NSUInteger percent = 100 * uploadProgress.fractionCompleted;
                          self.dataProgressLabel.text = [NSString stringWithFormat:@"%lu%% completed", (unsigned long)percent];
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      
                      if (error)
                      {
                          NSLog(@"Error: %@", error);
                      }
                      else
                      {
                          // Enable finish button and show status view
                          self.statusTextView.hidden = NO;
                          self.finishButton.enabled = YES;
                      }
                  }];
    
    [uploadTask resume];
}

@end
