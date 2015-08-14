//
//  CSSensorSetupTableViewController.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSSensorSetupTableViewController.h"

#import "CSSimpleSensorSetup.h"
#import "CSSamplingRateSensorSetup.h"
#import "CSLocationSensorSetup.h"
#import "CSProximitySensorSetup.h"

@interface CSSensorSetupTableViewController () <CSSimpleSensorSetupDelegate>

@end

@implementation CSSensorSetupTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateSensorStatus];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    NSString *sensorName = cell.textLabel.text;
    
    if (YES) // ([sensorName isEqualToString:@"Accelerometer"])
    {
        [self performSegueWithIdentifier:@"Simple Sensor Setup" sender:sensorName];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *sensorName = sender;
    CSSensorSetupType type = [self typeFromSensorName:sensorName];
    SKSensorModuleType moduleType = [self moduleTypeFromSensorName:sensorName];
    
    CSSensorStatus sensorStatus;
    if ([self.sensingSession isSensorEnabled:moduleType])
    {
        sensorStatus = CSSensorStatusEnabled;
    }
    else
    {
        sensorStatus = CSSensorStatusDisabled;
    }
    
    if ([segue.identifier isEqualToString:@"Simple Sensor Setup"]) {
        
        CSSimpleSensorSetup *simpleSensorSetup = (CSSimpleSensorSetup *)segue.destinationViewController;
        
        simpleSensorSetup.delegate = self;
        simpleSensorSetup.sensorSetupType = type;
        simpleSensorSetup.sensorStatus = sensorStatus;
    }
}

- (CSSensorSetupType)typeFromSensorName:(NSString *)sensorName {
    
    if ([sensorName isEqualToString:@"Accelerometer"])
    {
        return CSSensorSetupAccelerometerType;
    }
    else if ([sensorName isEqualToString:@"Gyroscope"])
    {
        return CSSensorSetupGyroscopeType;
    }
    else if ([sensorName isEqualToString:@"Magnetometer"])
    {
        return CSSensorSetupMagnetometerType;
    }
    else if ([sensorName isEqualToString:@"Device Motion"])
    {
        return CSSensorSetupDeviceMotionType;
    }
    else if ([sensorName isEqualToString:@"Activity"])
    {
        return CSSensorSetupActivityType;
    }
    else if ([sensorName isEqualToString:@"Location"])
    {
        return CSSensorSetupLocationType;
    }
    else if ([sensorName isEqualToString:@"Battery"])
    {
        return CSSensorSetupBatteryType;
    }
    else
    {
        NSLog(@"Unknown Sensor name: %@", sensorName);
        abort();
    }
}

- (SKSensorModuleType)moduleTypeFromSensorName:(NSString *)sensorName {
    
    if ([sensorName isEqualToString:@"Accelerometer"])
    {
        return Accelerometer;
    }
    else if ([sensorName isEqualToString:@"Gyroscope"])
    {
        return Gyroscope;
    }
    else if ([sensorName isEqualToString:@"Magnetometer"])
    {
        return Magnetometer;
    }
    else if ([sensorName isEqualToString:@"Device Motion"])
    {
        return DeviceMotion;
    }
    else if ([sensorName isEqualToString:@"Activity"])
    {
        return Activity;
    }
    else if ([sensorName isEqualToString:@"Location"])
    {
        return Location;
    }
    else if ([sensorName isEqualToString:@"Battery"])
    {
        return Battery;
    }
    else
    {
        NSLog(@"Unknown Sensor name: %@", sensorName);
        abort();
    }
}

- (void)changeStatus:(CSSensorStatus)sensorStatus ofSensorWithType:(CSSensorSetupType)sensorType
{
    // Get the actual sensorModuleType
    SKSensorModuleType sensorModule;
    
    switch (sensorType) {
        case CSSensorSetupAccelerometerType:
            sensorModule = Accelerometer;
            break;
            
        case CSSensorSetupGyroscopeType:
            sensorModule = Gyroscope;
            break;
            
        case CSSensorSetupMagnetometerType:
            sensorModule = Magnetometer;
            break;
            
        case CSSensorSetupDeviceMotionType:
            sensorModule = DeviceMotion;
            break;
            
        case CSSensorSetupActivityType:
            sensorModule = Activity;
            break;
            
        case CSSensorSetupLocationType:
            sensorModule = Location;
            break;
            
        case CSSensorSetupBatteryType:
            sensorModule = Battery;
            break;
            
        default:
            NSLog(@"Unknown CSSensorSetupType: %lu", (unsigned long)sensorType);
            abort();
    }
    
    // Set the action based on the sensorStatus enum
    switch (sensorStatus) {
        case CSSensorStatusEnabled:
            [self.sensingSession enableSensorWithType:sensorModule];
            break;
            
        case CSSensorStatusDisabled:
            [self.sensingSession disableSensorWithType:sensorModule];
            break;
            
        default:
            NSLog(@"Unknown CSSensorStatus: %lu", (unsigned long)sensorStatus);
            abort();
    }
    
    // Update the UI
    [self updateSensorStatus];
}


- (void)updateSensorStatus
{
    [self updateTableViewCell:self.accelerometerSensorCell withSensorEnabled:[self.sensingSession isSensorEnabled:Accelerometer]];
    [self updateTableViewCell:self.gyroscopeSensorCell     withSensorEnabled:[self.sensingSession isSensorEnabled:Gyroscope]];
    [self updateTableViewCell:self.magnetometerSensorCell  withSensorEnabled:[self.sensingSession isSensorEnabled:Magnetometer]];
    [self updateTableViewCell:self.deviceMotionSensorCell  withSensorEnabled:[self.sensingSession isSensorEnabled:DeviceMotion]];
    [self updateTableViewCell:self.ActivitySensorCell      withSensorEnabled:[self.sensingSession isSensorEnabled:Activity]];
    [self updateTableViewCell:self.LocationSensorCell      withSensorEnabled:[self.sensingSession isSensorEnabled:Location]];
    [self updateTableViewCell:self.BatterySensorCell       withSensorEnabled:[self.sensingSession isSensorEnabled:Battery]];
}

- (void)updateTableViewCell:(UITableViewCell *)tableViewCell withSensorEnabled:(BOOL)sensorEnabled
{
    if (sensorEnabled) {
        tableViewCell.detailTextLabel.textColor = self.view.tintColor;
        tableViewCell.detailTextLabel.text = @"On";
    }
    else
    {
        tableViewCell.detailTextLabel.textColor = [UIColor grayColor];
        tableViewCell.detailTextLabel.text = @"Off";
    }
}

@end
