//
//  CSSensingSession.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 13/07/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SensingKit/SensingKitLib.h>

@interface CSSensingSession : NSObject

@property (nonatomic, strong) SensingKitLib *sensingKitLib;

- (instancetype)initWithFolderName:(NSString *)folderName;

- (void)start;
- (void)stop;
- (void)close;

@end
