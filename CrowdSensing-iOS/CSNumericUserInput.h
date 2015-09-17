//
//  CSNumericUserInput.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSNumericUserInputDelegate <NSObject>

- (void)userInputWithValue:(NSUInteger)value;

@end

@interface CSNumericUserInput : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) id <CSNumericUserInputDelegate> delegate;

@property (strong, nonatomic) NSString *userInputPlaceholder;
@property (strong, nonatomic) NSString *userInputDescription;

@property (nonatomic) NSUInteger defaultValue;
@property (nonatomic) NSUInteger maxDigits;
@property (nonatomic) NSUInteger minValue;
@property (nonatomic) NSUInteger maxValue;

@end
