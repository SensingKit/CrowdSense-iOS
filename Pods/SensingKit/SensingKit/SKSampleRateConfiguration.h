//
//  SKSampleRateConfiguration.h
//  SensingKit
//
//  Copyright (c) 2014. Kleomenis Katevas
//  Kleomenis Katevas, minos.kat@gmail.com
//
//  This file is part of SensingKit-iOS library.
//  For more information, please visit https://www.sensingkit.org
//
//  SensingKit-iOS is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  SensingKit-iOS is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with SensingKit-iOS.  If not, see <http://www.gnu.org/licenses/>.
//

#import <Foundation/Foundation.h>

#import <SensingKit/SKConfiguration.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  This is the base class for all motion sensors that require a sample rate configuration (e.g., Accelerometer, Gyroscope, Magnetometer, Device Motion, etc.).
 */
@interface SKSampleRateConfiguration : SKConfiguration <NSCopying>

/**
 *  The Sample Rate of the sensor in Hz.
 */
@property (nonatomic) NSUInteger sampleRate;

@end

NS_ASSUME_NONNULL_END
