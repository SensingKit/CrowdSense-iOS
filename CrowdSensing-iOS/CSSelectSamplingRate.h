//
//  CSSelectSamplingRate.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSSelectSamplingRateDelegate <NSObject>

- (void)setSamplingRate:(NSUInteger)samplingRate;

@end

@interface CSSelectSamplingRate : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) id <CSSelectSamplingRateDelegate> delegate;

@end
