//
//  CSRoundButton.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 13/10/2014.
//  Copyright (c) 2014 Kleomenis Katevas. All rights reserved.
//

#import "CSRoundButton.h"
#import "SKStyles.h"

@implementation CSRoundButton

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (self.type == CSRoundButtonFilledType) {
        [SKStyles drawRoundButtonFilledWithTitle:self.title];
    }
    else if (self.type == CSRoundButtonStrokedType) {
        [SKStyles drawRoundButtonStrokedWithTitle:self.title];
    }
    else if (self.type == CSRoundButtonDeactivatedType) {
        [SKStyles drawRoundButtonStrokedDeactivatedWithTitle:self.title];
    }
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self setNeedsDisplay];
}

@end
