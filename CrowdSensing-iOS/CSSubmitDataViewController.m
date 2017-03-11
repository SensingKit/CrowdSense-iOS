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

@end

@implementation CSSubmitDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
        [formData appendPartWithFormData:[@"super" dataUsingEncoding:NSUTF8StringEncoding] name:@"password"];
        
        // Set data
        //NSURL *dataUrl = [NSURL URLWithString:@"..."];
        //[formData appendPartWithFileURL:dataUrl name:@"uploadedFile" fileName:@"filename.zip" mimeType:@"application/zip" error:nil];
        
        // Tmp data for testing reasons
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://minoskt.github.io/media/projects/robothespian_thumb.jpg"]];
        [formData appendPartWithFileData:data name:@"uploadedFile" fileName:@"filename.jpg" mimeType:@"image/jpeg"];
        
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
