//
//  CSMainTableTableViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 19/06/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import "CSMainTableTableViewController.h"
#import "CSRecordViewController.h"
#import "CSRecordingInfoTableViewController.h"
#import "Recording.h"
#import "Recording+Create.h"
#import "CSInformationViewController.h"
#import "CSDemoViewController.h"

@import AFNetworking;

@interface CSMainTableTableViewController () <CSRecordViewControllerDelegate>

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSFileManager *fileManager;

@property (nonnull, strong) NSString *experimentType;
@property (nonnull, strong) NSString *experimentCoupon;

@property (nonatomic, strong) NSDictionary *configuration;

@end

@implementation CSMainTableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setupFetchedResultsController];
    
    self.configuration = [self getConfiguration];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.fileManager = nil;
    self.dateFormatter = nil;
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
        _dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    }
    return _dateFormatter;
}

- (NSFileManager *)fileManager
{
    if (!_fileManager)
    {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}

- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recording"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Recording Cell" forIndexPath:indexPath];
    
    // Get the recording
    Recording *recording = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Configure the cell.
    cell.textLabel.text = recording.title;
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:recording.createDate];
    
    return cell;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Get the recording
        Recording *recording = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        // Delete recording data and folder
        [self deleteRecording:recording];
    }
}

- (void)deleteRecording:(Recording *)recording
{
    // Delete recording data
    [self deleteFolderWithName:recording.storageFolder];
    
    // Delete the recording
    [self.managedObjectContext deleteObject:recording];
}

- (void)deleteFolderWithName:(NSString *)folderName
{
    NSURL *folderPath = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:folderName];
    
    NSError *error;
    [self.fileManager removeItemAtURL:folderPath error:&error];
    
    if (error)
    {
        NSLog(@"Error: %@", error.localizedDescription);
    }
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"New Recording"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        CSRecordViewController *recordViewController = (CSRecordViewController *)navigationController.topViewController;
        
        recordViewController.recording = [Recording recordingWithTitle:@"New Recording"
                                                        withCreateDate:[NSDate date]
                                                inManagedObjectContext:self.managedObjectContext];
        
        recordViewController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"Recording Info"]) {
        
        CSRecordingInfoTableViewController *recordingInfoController = (CSRecordingInfoTableViewController *)segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Recording *recording = [self.fetchedResultsController objectAtIndexPath:indexPath];
        recordingInfoController.recording = recording;
    }
    else if ([segue.identifier isEqualToString:@"Show Experiment"])  {
        
        UINavigationController *navigationController = segue.destinationViewController;
        CSInformationViewController *informationViewController = (CSInformationViewController *)navigationController.topViewController;
        informationViewController.type = self.experimentType;
        informationViewController.coupon = self.experimentCoupon;
    }
    else if ([segue.identifier isEqualToString:@"Show Demo"])  {
        
        UINavigationController *navigationController = segue.destinationViewController;
        CSDemoViewController *demoViewController = (CSDemoViewController *)navigationController.topViewController;
        demoViewController.configuration = self.configuration;
    }
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

- (void)userInput {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Study Participation"
                                          message:@"Please enter the coupon received when registering for the Speed Networking study:"
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
                                   [self checkCoupon:text];
                               }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Please enter the coupon.";
        textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    // Show the alert
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)showExperimentAction:(id)sender
{
    //[self userInput];
    [self performSegueWithIdentifier:@"Show Demo" sender:self];
}

- (void)checkCoupon:(NSString *)coupon
{
    // JSON Body
    NSDictionary* bodyObject = @{@"password": @"b+FRongauiv/bKy1egB8AbB2HIICNbhX5IqlbMWcfn4",
                                 @"coupon": coupon};
    
    [[AFHTTPSessionManager manager] POST:@"https://sensingkit.herokuapp.com/validation"
       parameters:bodyObject progress:^(NSProgress * _Nonnull uploadProgress) {
           // All ok
       } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * _Nullable responseObject) {
           
           [self parseResponse:responseObject forCoupon:coupon];
           
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           [self alertWithTitle:@"Coupon Is Not Valid"
                    withMessage:@"Please e-mail us at k.katevas@qmul.ac.uk if you live in London and you want to participate in our study."];
       }];
}

- (void)parseResponse:(NSDictionary *)response forCoupon:(NSString *)coupon
{
    if ([response[@"isTestCoupon"] isEqual:@(1)]) {
        self.experimentCoupon = coupon;
        self.experimentType = @"Test";
        [self performSegueWithIdentifier:@"Show Experiment" sender:self];
    }
    else if ([response[@"isExpirimentCoupon"] isEqual:@(1)]) {
        self.experimentCoupon = coupon;
        self.experimentType = @"Experiment";
        [self performSegueWithIdentifier:@"Show Experiment" sender:self];
    }
    else {
        [self alertWithTitle:@"Coupon Is Not Valid"
                 withMessage:@"Please e-mail us at k.katevas@qmul.ac.uk if you live in London and you want to participate in our study."];
    }
}

- (void)alertWithTitle:(NSString *)title withMessage:(NSString *)message
           withHandler:(void (^ __nullable)(UIAlertAction *action))handler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:handler];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSDictionary *)getConfiguration
{
    NSURL *url = [NSURL URLWithString:@"https://www.sensingkit.org/MobiSys17-Demo.json"];
    NSData *receivedData = [NSData dataWithContentsOfURL:url];
    
    if (!receivedData)
    {
        [self alertWithTitle:@"Network Error" withMessage:@"Please make sure you have a reliable Internet connection." withHandler:nil];
        return nil;
    }
    
    NSError *error = nil;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:receivedData
                                                                   options:kNilOptions
                                                                     error:&error];
    
    if (error) {
        [self alertWithTitle:@"Error" withMessage:error.localizedDescription withHandler:nil];
        return nil;
    }
    
    NSLog(@"IP: %@", jsonDictionary[@"ip"]);
    return jsonDictionary;
}

@end
