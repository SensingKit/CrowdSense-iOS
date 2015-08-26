//
//  Recording.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 26/08/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LogEntry;

@interface Recording : NSManagedObject

@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSString * storageFolder;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * duration;
@property (nonatomic, retain) NSOrderedSet *withLog;
@end

@interface Recording (CoreDataGeneratedAccessors)

- (void)insertObject:(LogEntry *)value inWithLogAtIndex:(NSUInteger)idx;
- (void)removeObjectFromWithLogAtIndex:(NSUInteger)idx;
- (void)insertWithLog:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeWithLogAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInWithLogAtIndex:(NSUInteger)idx withObject:(LogEntry *)value;
- (void)replaceWithLogAtIndexes:(NSIndexSet *)indexes withWithLog:(NSArray *)values;
- (void)addWithLogObject:(LogEntry *)value;
- (void)removeWithLogObject:(LogEntry *)value;
- (void)addWithLog:(NSOrderedSet *)values;
- (void)removeWithLog:(NSOrderedSet *)values;
@end
