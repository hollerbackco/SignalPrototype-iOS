//
//  HBWelcomeStartViewController.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 23/03/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "HBBaseWelcomeViewController.h"

@interface HBWelcomeStartViewController : HBBaseWelcomeViewController

@property (weak, nonatomic) IBOutlet UIButton *topLeftButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (nonatomic, copy) void(^loginBlock)();

@end
