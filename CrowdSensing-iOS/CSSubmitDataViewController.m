//
//  CSSubmitDataViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 10/03/2017.
//  Copyright © 2017 Kleomenis Katevas. All rights reserved.
//

#import "CSSubmitDataViewController.h"
@import AFNetworking;
@import SSZipArchive;

@interface CSSubmitDataViewController () <SSZipArchiveDelegate>

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

    // Prepare data for uploading
    [self prepareData];
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

- (void)prepareData
{
    // Create zip
    NSString *zipPath = [self tempZipPath];
    SSZipArchive *zipArchive = [[SSZipArchive alloc] initWithPath:zipPath];
    
    // Serialize json
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.information
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (error) {
        [self alertWithTitle:@"Transmission Failed" withMessage:error.localizedDescription];
        return;
    }
    
    // Add data
    [zipArchive open];
    [zipArchive writeData:jsonData filename:@"information.json" withPassword:nil];
    [zipArchive writeData:UIImagePNGRepresentation(self.picture) filename:@"picture.png" withPassword:nil];
    [zipArchive close];
    
    // finally
    [self uploadData:zipPath];
}

- (NSString *)tempZipPath
{
    NSString *path = [NSString stringWithFormat:@"%@/\%@.zip",
                      NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0],
                      [NSUUID UUID].UUIDString];
    return path;
}

- (void)uploadData:(NSString *)path
{
    NSError *error;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"https://sensingkit.herokuapp.com" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        // Set password
        [formData appendPartWithFormData:[@"b+FRongauiv/bKy1egB8AbB2HIICNbhX5IqlbMWcfn4" dataUsingEncoding:NSUTF8StringEncoding] name:@"password"];
        
        // Set data
        NSString *filename = [NSString stringWithFormat:@"u%@__%@.zip",
                              self.information[@"Questionnaire"][@"ID"],
                              [self.dateFormatter stringFromDate:[NSDate date]]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            
            NSError *error;
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:path]
                                       name:@"uploadedFile"
                                   fileName:filename
                                   mimeType:@"application/zip"
                                      error:&error];
            
            if (error) {
                [self alertWithTitle:@"Transmission Failed" withMessage:error.localizedDescription];
            }
        }
        else
        {
            [self alertWithTitle:@"Transmission Failed" withMessage:@"File does not exist."];
        }

    } error:&error];
    
    if (error) {
        [self alertWithTitle:@"Transmission Failed" withMessage:error.localizedDescription];
        return;
    }
    
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
                          [self.dataProgressView setProgress:0];
                          self.dataProgressLabel.text = @"0% completed";
                          
                          [self alertWithTitle:@"Transmission Failed" withMessage:error.localizedDescription];
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

- (void)alertWithTitle:(NSString *)title withMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    
    [alert show];
}

@end
