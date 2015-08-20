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
    NSString *sensorDescription = [self sensorDescriptionForSensorWithType:moduleType];
    
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
        simpleSensorSetup.sensorDescription = sensorDescription;
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
    else if ([sensorName isEqualToString:@"iBeacon Proximity"])
    {
        return CSSensorSetupBeaconType;
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
    else if ([sensorName isEqualToString:@"iBeacon Proximity"])
    {
        return Proximity;
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

- (NSString *)sensorDescriptionForSensorWithType:(SKSensorModuleType)moduleType {
    
    switch (moduleType) {
            
        case Accelerometer:
            return @"Accelerometer is a sensor that measures the device acceleration changes in three-dimensional space. You can use this data to detect both the current orientation of the device (relative to the ground) and any instantaneous changes to that orientation.";
            
        case Gyroscope:
            return @"Gyroscope is a sensor that measures the device’s rate of rotation around each of the three spatial axes.";
            
        case Magnetometer:
            return @"Magnetometer (also known as Compass or Magnetic Field Sensor) is a sensor that measures the actual orientation of the device relatively to the Magnetic North.";
            
        case DeviceMotion:
            return @"Device Motion sensor uses sensor fusion techniques to provide more advanced and accurate motion measurements. It provides measurements of the Attitude, Rotation Rate, Calibrated Magnetic Field, as well as a separation of User Acceleration and Gravity from the device’s acceleration.";
            
        case Activity:
            return @"Activity sensor uses an embedded motion co-processor that senses the user’s activity classified as Stationary, Walking, Running, Automotive or Cycling.";
            
        case Battery:
            return @"Battery sensor listens for changes in the battery charge state (Charging, Full, Unplugged) as well as in the battery charge level (with 1% precision).";
            
        case Location:
            return @"Location sensor senses the current location of the device using a combination of Cellular, Wi-Fi, Bluetooth and GPS sensors. It provides 2D geographical coordinate information (latitude, longitude) as well as the altitude of the device.";
            
        case Proximity:
            return @"iBeacon Proximity sensor uses Apple's iBeacon technology to estimate the proximity of the current device with other devices actively running CrowdSense application.";
            
        default:
            return [NSString stringWithFormat:@"Unknown SensorModule: %li", (long)moduleType];
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
            
        case CSSensorSetupBeaconType:
            sensorModule = Proximity;
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
    [self updateTableViewCell:self.activitySensorCell      withSensorEnabled:[self.sensingSession isSensorEnabled:Activity]];
    [self updateTableViewCell:self.locationSensorCell      withSensorEnabled:[self.sensingSession isSensorEnabled:Location]];
    [self updateTableViewCell:self.beaconSensorCell        withSensorEnabled:[self.sensingSession isSensorEnabled:Proximity]];
    [self updateTableViewCell:self.batterySensorCell       withSensorEnabled:[self.sensingSession isSensorEnabled:Battery]];
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
