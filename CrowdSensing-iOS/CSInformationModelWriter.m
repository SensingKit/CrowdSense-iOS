//
//  CSInformationModelWriter.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 22/08/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import "CSInformationModelWriter.h"

@interface CSInformationModelWriter () <NSStreamDelegate>

@property (nonatomic, strong) NSURL *filePath;
@property (nonatomic, strong) NSOutputStream *outputStream;

@end

@implementation CSInformationModelWriter

- (instancetype)initWithFilename:(NSString *)filename
                          inPath:(NSURL *)path
{
    if (self = [super init])
    {
        NSURL *filePath = [path URLByAppendingPathComponent:filename];
        
        self.filePath = filePath;
        self.outputStream = [[NSOutputStream alloc] initWithURL:filePath append:YES];
        self.outputStream.delegate = self;
        [self.outputStream open];
    }
    return self;
}

- (void)addInformation:(NSString *)information
{
    [self writeString:[NSString stringWithFormat:@"%@\n", information]];
}

- (void)writeString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    [self.outputStream write:data.bytes maxLength:data.length];
}

- (void)close
{
    [self.outputStream close];
}

@end
