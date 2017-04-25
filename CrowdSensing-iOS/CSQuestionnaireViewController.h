//
//  CSQuestionnaireViewController.h
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 10/03/2017.
//  Copyright © 2017 Kleomenis Katevas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSSensingSession.h"

@interface CSQuestionnaireViewController : UIViewController

@property (nonatomic, weak) CSSensingSession *sensingSession;
@property (nonatomic, weak) NSMutableDictionary *information;

@end
