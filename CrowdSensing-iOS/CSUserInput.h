//
//  CSNumericUserInput.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 14/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CSUserInputMode) {
    CSNUserInputIntegerMode,
    CSNUserInputTextMode,
    CSNUserInputHexMode
};

@protocol CSNUserInputDelegate <NSObject>

- (void)userInputWithIdentifier:(NSString *)identifier withValue:(NSString *)value;

@end

@interface CSUserInput : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) NSString *identifier;

@property (weak, nonatomic) id <CSNUserInputDelegate> delegate;

@property (nonatomic) CSUserInputMode mode;

@property (strong, nonatomic) NSString *userInputDefaultValue;
@property (strong, nonatomic) NSString *userInputPlaceholder;
@property (strong, nonatomic) NSString *userInputDescription;

@property (nonatomic) NSUInteger maxCharacters;

@property (nonatomic) BOOL noneValueAllowed;

// Used in IntegerMode only
@property (nonatomic) NSUInteger minValue;
@property (nonatomic) NSUInteger maxValue;

@end
