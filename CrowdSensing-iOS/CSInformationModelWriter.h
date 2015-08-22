//
//  CSInformationModelWriter.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 22/08/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSInformationModelWriter : NSObject

- (instancetype)initWithFilename:(NSString *)filename
                          inPath:(NSURL *)path;

- (void)addInformation:(NSString *)information;

- (void)close;

@end
