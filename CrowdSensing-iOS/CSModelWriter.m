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

@end

@implementation CSModelWriter

- (instancetype)initWithFilename:(NSString *)filename
                          inPath:(NSURL *)path
{
    if (self = [super init])
    {
        self.filePath = [self createFileWithName:filename
                                          inPath:path];
    }
    return self;
}

- (NSURL *)createFileWithName:(NSString *)filename
                       inPath:(NSURL *)path
{
    NSURL *filePath = [path URLByAppendingPathComponent:filename];
    
    // Create the file
    
    
    return filePath;
}

@end
