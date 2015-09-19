//
//  CSSelectProperty.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 19/09/2015.
//  Copyright © 2015 Kleomenis Katevas. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSSelectPropertyDelegate <NSObject>

- (void)selectPropertyWithIdentifier:(NSString *)identifier withIndex:(NSUInteger)index withValue:(NSString *)value;

@end

@interface CSSelectProperty : UITableViewController

@property (strong, nonatomic) NSString *identifier;

@property (weak, nonatomic) id <CSSelectPropertyDelegate> delegate;

@property (strong, nonatomic) NSArray<NSString *> *elements;

@property (nonatomic) NSUInteger selectedIndex;

@end
