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
@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet UILabel *dataProgressLabel;
@property (weak, nonatomic) IBOutlet UILabel *dataProgressTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *retryButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSString *zipPath;

@end

@implementation CSSubmitDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Close session
    [self.sensingSession close];
    
    // Prepare data for uploading
    [self prepareData];
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy_MM_dd_HH_mm_ss";
        _dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
        _dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    }
    return _dateFormatter;
}

- (IBAction)finishAction:(id)sender
{
    [self deleteFileAtPath:self.zipPath];
    
    // Should be disabled initially
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)prepareData
{
    NSURL *dataPath = self.sensingSession.folderPath;
    
    // Serialize json and save into dataPath
    if (self.information) {
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.information
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        if (error) {
            [self alertWithTitle:@"Transmission Failed" withMessage:error.localizedDescription];
            self.retryButton.hidden = NO;
            return;
        }
        
        NSString *jsonPath = [dataPath URLByAppendingPathComponent:@"information.json" isDirectory:NO].path;
        [jsonData writeToFile:jsonPath atomically:YES];
    }
    
    // Save picture into dataPath
    if (self.picture) {
    
        NSString *imagePath = [dataPath URLByAppendingPathComponent:@"picture.jpeg" isDirectory:NO].path;
        [UIImageJPEGRepresentation(self.picture, 0.8) writeToFile:imagePath atomically:YES];
    }
    
    // Save into zip
    NSString *zipPath = [self tempZipPath];
    [SSZipArchive createZipFileAtPath:zipPath withContentsOfDirectory:dataPath.path keepParentDirectory:YES withPassword:nil andProgressHandler:^(NSUInteger entryNumber, NSUInteger total) {
        NSLog(@"Progress: %lu/%lu", (unsigned long)entryNumber, (unsigned long)total);
    }];
    
    // Save the path
    self.zipPath = zipPath;
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
        [formData appendPartWithFormData:[self.information[@"Coupon"] dataUsingEncoding:NSUTF8StringEncoding] name:@"coupon"];
        
        // Set data
        NSString *filename = [NSString stringWithFormat:@"CS__c%@__%@.zip",
                              self.information[@"Coupon"],
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
                self.retryButton.hidden = NO;
            }
        }
        else
        {
            [self alertWithTitle:@"Transmission Failed" withMessage:@"File does not exist."];
            self.retryButton.hidden = NO;
        }

    } error:&error];
    
    if (error) {
        [self alertWithTitle:@"Transmission Failed" withMessage:error.localizedDescription];
        self.retryButton.hidden = NO;
        return;
    }
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLSessionUploadTask *uploadTask = [manager
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
                          self.retryButton.hidden = NO;
                          
                          [self alertWithTitle:@"Transmission Failed" withMessage:error.localizedDescription];
                      }
                      else
                      {
                          // Show status view and hide progress bar
                          self.statusLabel.hidden = NO;
                          self.titleTextView.hidden = YES;
                          self.dataProgressTitleLabel.hidden = YES;
                          self.retryButton.hidden = YES;
                          self.dataProgressView.hidden = YES;
                          self.dataProgressLabel.hidden = YES;
                          
                          // Enable finish
                          self.finishButton.enabled = YES;
                          
                          [self alertWithTitle:@"Submission Succedded" withMessage:@"Thank you for your participation. We will be in touch soon with the results of the draw."];
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

- (void)deleteFileAtPath:(NSString *)filePath
{
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    
    if (error) {
        //[self alertWithTitle:@"Delete Failed" withMessage:error.localizedDescription];
    }
}

- (IBAction)shareDataAction:(id)sender {
    
    [self askPassword:@"1395"];
}

- (IBAction)retrySubmission:(id)sender {
    [self uploadData:self.zipPath];
}

- (void)askPassword:(NSString *)password {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Enter Password"
                                          message:@"Please enter the password given by the instructor in order to continue to the next step."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action) {
                                   
                                   NSString *text = ((UITextField *)[alertController.textFields objectAtIndex:0]).text;
                                   
                                   if ([text isEqualToString:password])
                                   {
                                       [self shareData];
                                   }
                                   else
                                   {
                                       // Ignore
                                   }
                                   
                               }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    // Show the alert
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)shareData
{
    NSURL *attachment = [NSURL fileURLWithPath:self.zipPath];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[attachment] applicationActivities:nil];
    
    // Call this when the activity is completed
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        
        // Nothing?
    }];
    
    NSMutableArray *array = @[UIActivityTypePostToFacebook,
                              UIActivityTypePostToTwitter,
                              UIActivityTypePostToWeibo,
                              UIActivityTypeMessage,
                              UIActivityTypePrint,
                              UIActivityTypeCopyToPasteboard,
                              UIActivityTypeAssignToContact,
                              UIActivityTypeSaveToCameraRoll,
                              UIActivityTypeAddToReadingList,
                              UIActivityTypePostToFlickr,
                              UIActivityTypePostToVimeo,
                              UIActivityTypePostToTencentWeibo].mutableCopy;
    
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 9) {
        [array addObject:UIActivityTypeOpenInIBooks];
    }
    
    // Exclude Activities
    activityViewController.excludedActivityTypes = array;
    
    // To avoid crash on iPad and iOS 8
    if ([activityViewController respondsToSelector:@selector(popoverPresentationController)])
    {
        // iOS8
        activityViewController.popoverPresentationController.barButtonItem = self.shareButton;
    }
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}

@end
