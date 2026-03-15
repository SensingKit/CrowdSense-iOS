#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSString+SensorType.h"
#import "SensingKit.h"
#import "SensingKitLib.h"
#import "SKAbstractSensor.h"
#import "SKAccelerometer.h"
#import "SKAccelerometerConfiguration.h"
#import "SKAccelerometerData.h"
#import "SKAltimeter.h"
#import "SKAltimeterConfiguration.h"
#import "SKAltimeterData.h"
#import "SKBattery.h"
#import "SKBatteryConfiguration.h"
#import "SKBatteryData.h"
#import "SKConfiguration.h"
#import "SKDeviceMotion.h"
#import "SKDeviceMotionConfiguration.h"
#import "SKDeviceMotionData.h"
#import "SKEddystoneProximity.h"
#import "SKEddystoneProximityConfiguration.h"
#import "SKEddystoneProximityData.h"
#import "SKErrors.h"
#import "SKGyroscope.h"
#import "SKGyroscopeConfiguration.h"
#import "SKGyroscopeData.h"
#import "SKHeading.h"
#import "SKHeadingConfiguration.h"
#import "SKHeadingData.h"
#import "SKiBeaconDeviceData.h"
#import "SKiBeaconProximity.h"
#import "SKiBeaconProximityConfiguration.h"
#import "SKLocation.h"
#import "SKLocationConfiguration.h"
#import "SKLocationData.h"
#import "SKMagnetometer.h"
#import "SKMagnetometerConfiguration.h"
#import "SKMagnetometerData.h"
#import "SKMicrophone.h"
#import "SKMicrophoneConfiguration.h"
#import "SKMicrophoneData.h"
#import "SKMotionActivity.h"
#import "SKMotionActivityConfiguration.h"
#import "SKMotionActivityData.h"
#import "SKMotionManager.h"
#import "SKPedometer.h"
#import "SKPedometerConfiguration.h"
#import "SKPedometerData.h"
#import "SKProximityData.h"
#import "SKSampleRateConfiguration.h"
#import "SKSensorData.h"
#import "SKSensorDataHandler.h"
#import "SKSensorManager.h"
#import "SKSensorTimestamp.h"
#import "SKSensorType.h"
#import "ESSBeaconScanner.h"
#import "ESSEddystone.h"
#import "ESSTimer.h"

FOUNDATION_EXPORT double SensingKitVersionNumber;
FOUNDATION_EXPORT const unsigned char SensingKitVersionString[];

