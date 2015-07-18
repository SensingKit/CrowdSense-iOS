//
//  CSModelWriter.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 13/07/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import "CSModelWriter.h"

@interface CSModelWriter ()

@property (nonatomic, strong) NSURL* filePath;
@property(nonatomic, strong) NSOutputStream* outputStream;

@end

@implementation CSModelWriter

- (instancetype)initWithSensorModuleType:(SKSensorModuleType)moduleType
                            withFilename:(NSString *)filename
                                  inPath:(NSURL *)path
{
    if (self = [super init])
    {
        _moduleType = moduleType;
        NSURL *filePath = [path URLByAppendingPathComponent:filename];
        
        self.filePath = filePath;
        self.outputStream = [[NSOutputStream alloc] initWithURL:filePath append:NO];
        [self.outputStream open];
    }
    return self;
}

- (void)readData:(SKSensorData *)sensorData
{
    NSString *csv = [NSString stringWithFormat:@"%@\n",sensorData.csvString];
    [self writeString:csv];
}

- (void)writeString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    [self.outputStream write:data.bytes maxLength:data.length];
}

@end
