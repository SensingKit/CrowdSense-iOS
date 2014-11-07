//
//  CSRoundButton.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 13/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import <UIKit/UIKit.h>

enum CSRoundButtonType : NSUInteger {
    CSRoundButtonFilledType,
    CSRoundButtonStrokedType
};


@interface CSRoundButton : UIButton

@property (strong, nonatomic) NSString *title;
@property (nonatomic) enum CSRoundButtonType type;

@end
