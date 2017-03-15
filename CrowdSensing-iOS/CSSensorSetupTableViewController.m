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
#import "CSiBeaconProximitySensorSetup.h"
#import "CSEddystoneProximitySensorSetup.h"
#import "CSMicrophoneSensorSetup.h"

@interface CSSensorSetupTableViewController () <CSSensorSetupDelegate>

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
    
    NSString *segueIdentifier = [self segueIdentifierFromSensorName:sensorName];
    
    [self performSegueWithIdentifier:segueIdentifier sender:sensorName];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *sensorName = sender;
    SKSensorType sensorType = [self sensorTypeFromSensorName:sensorName];
    NSString *sensorDescription = [self sensorDescriptionForSensorWithType:sensorType];
    
    CSSensorStatus sensorStatus;
    if (![self.sensingSession isSensorAvailable:sensorType])
    {
        sensorStatus = CSSensorStatusNotAvailable;
    }
    else if ([self.sensingSession isSensorEnabled:sensorType])
    {
        sensorStatus = CSSensorStatusEnabled;
    }
    else
    {
        sensorStatus = CSSensorStatusDisabled;
    }
    
    if ([[segue.destinationViewController class] isSubclassOfClass:CSGenericSensorSetup.class])
    {
        CSGenericSensorSetup *genericSensorSetup = (CSGenericSensorSetup *)segue.destinationViewController;
        
        genericSensorSetup.delegate = self;
        genericSensorSetup.sensorType = sensorType;
        genericSensorSetup.sensorStatus = sensorStatus;
        genericSensorSetup.configuration = [self.sensingSession getConfigurationFromSensor:sensorType];
        genericSensorSetup.sensorDescription = sensorDescription;
    }
}

- (SKSensorType)sensorTypeFromSensorName:(NSString *)sensorName {
    
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
    else if ([sensorName isEqualToString:@"Motion Activity"])
    {
        return MotionActivity;
    }
    else if ([sensorName isEqualToString:@"Pedometer"])
    {
        return Pedometer;
    }
    else if ([sensorName isEqualToString:@"Altimeter"])
    {
        return Altimeter;
    }
    else if ([sensorName isEqualToString:@"Location"])
    {
        return Location;
    }
    else if ([sensorName isEqualToString:@"iBeacon™ Proximity"])
    {
        return iBeaconProximity;
    }
    else if ([sensorName isEqualToString:@"Eddystone™ Proximity"])
    {
        return EddystoneProximity;
    }
    else if ([sensorName isEqualToString:@"Battery"])
    {
        return Battery;
    }
    else if ([sensorName isEqualToString:@"Microphone"])
    {
        return Microphone;
    }
    else
    {
        NSLog(@"Unknown Sensor name: %@", sensorName);
        abort();
    }
}

- (NSString *)segueIdentifierFromSensorName:(NSString *)sensorName {
    
    if ([sensorName isEqualToString:@"Accelerometer"])
    {
        return @"Sample Rate Sensor Setup";
    }
    else if ([sensorName isEqualToString:@"Gyroscope"])
    {
        return @"Sample Rate Sensor Setup";
    }
    else if ([sensorName isEqualToString:@"Magnetometer"])
    {
        return @"Sample Rate Sensor Setup";
    }
    else if ([sensorName isEqualToString:@"Device Motion"])
    {
        return @"Sample Rate Sensor Setup";
    }
    else if ([sensorName isEqualToString:@"Motion Activity"])
    {
        return @"Simple Sensor Setup";
    }
    else if ([sensorName isEqualToString:@"Pedometer"])
    {
        return @"Simple Sensor Setup";
    }
    else if ([sensorName isEqualToString:@"Altimeter"])
    {
        return @"Simple Sensor Setup";
    }
    else if ([sensorName isEqualToString:@"Location"])
    {
        return @"Location Sensor Setup";
    }
    else if ([sensorName isEqualToString:@"iBeacon™ Proximity"])
    {
        return @"iBeacon Proximity Sensor Setup";
    }
    else if ([sensorName isEqualToString:@"Eddystone™ Proximity"])
    {
        return @"Eddystone Proximity Sensor Setup";
    }
    else if ([sensorName isEqualToString:@"Battery"])
    {
        return @"Simple Sensor Setup";
    }
    else if ([sensorName isEqualToString:@"Microphone"])
    {
        return @"Microphone Sensor Setup";
    }
    else
    {
        NSLog(@"Unknown Sensor name: %@", sensorName);
        abort();
    }
}

- (NSString *)sensorDescriptionForSensorWithType:(SKSensorType)sensorType {
    
    switch (sensorType) {
            
        case Accelerometer:
            return @"Accelerometer is a sensor that measures the device acceleration changes in three‑dimensional space. You can use this data to detect both the current orientation of the device (relative to the ground) and any instantaneous changes to that orientation.";
            
        case Gyroscope:
            return @"Gyroscope is a sensor that measures the device’s rate of rotation around each of the three spatial axes.";
            
        case Magnetometer:
            return @"Magnetometer (also known as Compass or Magnetic Field Sensor) is a sensor that measures the actual orientation of the device in relation to the Magnetic North.";
            
        case DeviceMotion:
            return @"Device Motion sensor uses sensor fusion techniques to provide more advanced and accurate motion measurements. It measures the Attitude, Rotation Rate, Calibrated Magnetic Field, as well as a separation of User Acceleration and Gravity from the device’s acceleration.";
            
        case MotionActivity:
            return @"Motion Activity sensor uses an embedded motion co‑processor that senses the user’s activity classified as Stationary, Walking, Running, Automotive or Cycling.";
            
        case Pedometer:
            return @"Pedometer sensor uses an embedded motion co‑processor that captures pedestrian‑related data such as step counts, distance traveled and number of floors ascended or descended.";
            
        case Altimeter:
            return @"Altimeter sensor uses an embedded barometer sensor to capture changes to the relative altitude (not the actual). It also provides the recorded atmospheric pressure in kPa.";
            
        case Battery:
            return @"Battery sensor listens to changes in the battery charge state (Charging, Full, Unplugged) as well as in the battery charge level (with 1% precision).";
            
        case Location:
            return @"Location sensor determines the current location of the device using a combination of Cellular, Wi‑Fi, Bluetooth and GPS sensors. It provides 2D geographical coordinate information (latitude, longitude), as well as the altitude of the device.";
            
        case iBeaconProximity:
            return @"iBeacon™ Proximity sensor uses Apple's iBeacon™ technology to estimate the proximity of the current device with other devices actively running CrowdSense application.";
            
        case EddystoneProximity:
            return @"Eddystone™ Proximity sensor estimates the proximity of the current device with other Eddystone™ beacons in range.";
            
        case Microphone:
            return @"Microphone sensor can be used to record audio from the environment by converting sound into electrical signal. The maximum duration of an audio recording is 4 hours.";
            
        default:
            return [NSString stringWithFormat:@"Unknown SensorModule: %li", (long)sensorType];
    }
}

- (void)changeStatus:(CSSensorStatus)sensorStatus ofSensor:(SKSensorType)sensorType withConfiguration:(SKConfiguration *)configuration
{
    // Set the action based on the sensorStatus enum
    switch (sensorStatus) {
        case CSSensorStatusEnabled:
            [self.sensingSession enableSensor:sensorType withConfiguration:configuration withError:nil];
            break;
            
        case CSSensorStatusDisabled:
            [self.sensingSession disableSensor:sensorType withError:nil];
            break;
            
        default:
            NSLog(@"Unknown CSSensorStatus: %lu", (unsigned long)sensorStatus);
            abort();
    }
    
    // Update the UI
    [self updateSensorStatus];
}

- (void)updateConfiguration:(SKConfiguration *)configuration forSensor:(SKSensorType)sensorType
{
    [self.sensingSession setConfiguration:configuration toSensor:sensorType withError:nil];
}

- (void)updateSensorStatus
{
    [self updateTableViewCell:self.accelerometerSensorCell withSensorEnabled:[self.sensingSession isSensorEnabled:Accelerometer]];
    [self updateTableViewCell:self.gyroscopeSensorCell     withSensorEnabled:[self.sensingSession isSensorEnabled:Gyroscope]];
    [self updateTableViewCell:self.magnetometerSensorCell  withSensorEnabled:[self.sensingSession isSensorEnabled:Magnetometer]];
    [self updateTableViewCell:self.deviceMotionSensorCell  withSensorEnabled:[self.sensingSession isSensorEnabled:DeviceMotion]];
    [self updateTableViewCell:self.activitySensorCell      withSensorEnabled:[self.sensingSession isSensorEnabled:MotionActivity]];
    [self updateTableViewCell:self.pedometerSensorCell     withSensorEnabled:[self.sensingSession isSensorEnabled:Pedometer]];
    [self updateTableViewCell:self.altimeterSensorCell     withSensorEnabled:[self.sensingSession isSensorEnabled:Altimeter]];
    [self updateTableViewCell:self.locationSensorCell      withSensorEnabled:[self.sensingSession isSensorEnabled:Location]];
    [self updateTableViewCell:self.beaconSensorCell        withSensorEnabled:[self.sensingSession isSensorEnabled:iBeaconProximity]];
    [self updateTableViewCell:self.eddystoneSensorCell     withSensorEnabled:[self.sensingSession isSensorEnabled:EddystoneProximity]];
    [self updateTableViewCell:self.batterySensorCell       withSensorEnabled:[self.sensingSession isSensorEnabled:Battery]];
    [self updateTableViewCell:self.microphoneSensorCell    withSensorEnabled:[self.sensingSession isSensorEnabled:Microphone]];
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
