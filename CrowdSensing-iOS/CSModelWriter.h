//
//  CSModelWriter.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 13/07/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSModelWriter : NSObject

- (instancetype)initWithFilename:(NSString *)filename
                          inPath:(NSURL *)path;

@end
