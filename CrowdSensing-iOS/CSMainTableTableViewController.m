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

@interface CSMainTableTableViewController () <CSRecordViewControllerDelegate>

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSFileManager *fileManager;

@property (nonnull, strong) NSString *experimentType;
@property (nonnull, strong) NSString *experimentCoupon;

@property (nonatomic, strong) NSArray *couponsTest;
@property (nonatomic, strong) NSArray *couponsExperiment;

@end

@implementation CSMainTableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setupFetchedResultsController];
    
    self.couponsTest = @[@"AAA", @"YRN-VQN", @"LMV-JFV", @"GZX-ALQ", @"TIH-TGN", @"HNC-SDD", @"CVZ-DEW", @"POI-WHO", @"KKL-QPA", @"NWY-MES", @"XHQ-KMX", @"CMG-MVJ", @"ZZS-HSV", @"TQD-YEO", @"ZKJ-ZSF", @"WRR-LEH", @"LOW-MFG", @"KGX-YEN", @"ZBN-QCM", @"UPL-WVX", @"DED-TQX", @"EHK-JAR", @"RFH-CZS", @"MBE-OHF", @"WDV-ZWF", @"BBW-DTN", @"TFX-FKO", @"JME-PER", @"WXG-TQZ", @"JKM-JLO", @"MLZ-WFV", @"AIR-PMJ", @"VMF-VUE", @"MPB-KWG", @"YRM-YFK", @"CWY-NCE", @"WWA-WYB", @"NDJ-WLR", @"HXB-ONX", @"ELY-NNJ", @"JLW-PMV", @"XDG-HBA", @"UTQ-BJZ", @"WDV-TOE", @"IXB-OPJ", @"DRA-IWK", @"ZVZ-DJT", @"YHP-SVX", @"TMX-XOP", @"DYH-RKO", @"HYD-QYP", @"BWN-UKT", @"LAV-MHP", @"UET-ZNF", @"ULG-YYF", @"KGY-HQX", @"MUI-QNW", @"YPZ-SEP", @"EEQ-COQ", @"SVE-EXL", @"IAK-XCW", @"VSC-BBA", @"BTL-TDI", @"QTT-OPY", @"VUQ-MET", @"DFI-NOU", @"QFU-LKN", @"III-JTU", @"GLY-QOL", @"ZQI-SES", @"XKQ-BVX", @"GYX-XQP", @"NXK-MKD", @"XXJ-VME", @"UNX-WMQ", @"PQH-PXQ", @"YWF-VGD", @"ILD-CBU", @"YKE-NMO", @"GYU-XEM", @"PAT-NSY", @"KKY-FTF", @"AVJ-LOT", @"KCS-OVW", @"VRJ-RZC", @"BEW-LON", @"HQJ-DWD", @"MVY-WXG", @"VLN-PMQ", @"UOU-NZF", @"ZGZ-GWH", @"IAF-WGV", @"CZU-NAV", @"GNV-EEN", @"RAN-EYN", @"AGV-HLA", @"EMO-GHU", @"SIW-UWE", @"HRC-HRA", @"YBM-FBM", @"RIG-USY"];
    
    self.couponsExperiment = @[@"BBB", @"RUV-IYB", @"PLG-GPS", @"RFO-FDP", @"IHY-DXC", @"DBM-ZOF", @"PMH-TUQ", @"LWP-BPL", @"ITX-DFQ", @"CMC-THZ", @"LKA-XOA", @"HJP-FPD", @"LSQ-XGX", @"HQO-CKD", @"VQL-DJU", @"UFF-MUF", @"RAS-TUT", @"SRH-TWB", @"GWW-FWF", @"IKV-QZH", @"GPX-IMZ", @"BAM-JYP", @"GZN-ROO", @"SFP-YUK", @"LVS-LKI", @"WRC-GOX", @"CJW-XPM", @"KEP-BPE", @"DFR-CCM", @"UEC-HBX", @"YGZ-UUZ", @"BVK-LRK", @"CWS-KVM", @"WOI-EZK", @"ZYE-PVE", @"LTY-ZOF", @"TWU-UXY", @"KUL-THZ", @"YCV-ZEL", @"VTR-KED", @"EDK-SQO", @"JNB-JPK", @"FPG-VDK", @"RWD-WJM", @"JBY-NNM", @"WGX-CAY", @"JUF-MSL", @"RIU-IPH", @"HLP-ZCA", @"UJR-FIO", @"NTE-NDG", @"XUJ-NEF", @"FXG-CZV", @"JNB-ZUV", @"PQN-NGU", @"YZT-YHF", @"NNL-USY", @"PYN-FNW", @"OXL-RTU", @"GZW-KZQ", @"KHR-VLX", @"CIW-XDS", @"ICR-CES", @"XIM-PIR", @"WBH-ZOQ", @"LPX-BIS", @"APX-TSC", @"ISW-HNP", @"QUJ-MVV", @"YOO-HOM", @"GRQ-VRG", @"WNO-PZL", @"FAR-WVZ", @"JRK-AFU", @"RHO-TGJ", @"FXO-NDA", @"CNI-JVB", @"ZCC-SBB", @"QJO-CTZ", @"MJH-DLW", @"AAR-ZWW", @"EYE-HAG", @"UOW-CSP", @"VKW-GAI", @"BSA-BVV", @"YBJ-RIH", @"MMK-SOU", @"IYQ-WGQ", @"ZOW-UGZ", @"HUM-CTL", @"OTN-ZXC", @"WBH-KQA", @"XEL-USJ", @"ECX-CFZ", @"TEW-GUM", @"VMF-GAZ", @"TTK-JTH", @"VHK-QVL", @"FUH-PRT", @"OEA-WPF", @"VZO-ZFT"];
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
                                   
                                   if ([self.couponsTest containsObject:text]) {
                                       self.experimentType = @"Test";
                                       self.experimentCoupon = text;
                                       [self performSegueWithIdentifier:@"Show Experiment" sender:self];
                                   }
                                   else if ([self.couponsExperiment containsObject:text]) {
                                       self.experimentType = @"Experiment";
                                       self.experimentCoupon = text;
                                       [self performSegueWithIdentifier:@"Show Experiment" sender:self];
                                   }
                                   else {
                                        [self alertWithTitle:@"Coupon Is Not Valid"
                                                 withMessage:@"Please e-mail us at k.katevas@qmul.ac.uk if you live in London and you want to participate in our study."];
                                   }
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
    [self userInput];
}

@end
