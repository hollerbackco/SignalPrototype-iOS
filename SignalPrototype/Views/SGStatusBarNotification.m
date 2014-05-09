//
//  SGStatusBarNotification.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 8/11/2013.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <JDStatusBarNotification.h>

#import "UIColor+JNHelper.h"

#import "SGStatusBarNotification.h"
#import "SGAppDelegate.h"

@implementation SGStatusBarNotification

+ (void)showSyncing
{
    runOnMainQueue(^{
        [JDStatusBarNotification setDefaultStyle:^JDStatusBarStyle *(JDStatusBarStyle *style) {
            style.barColor = JNWhiteColor;
            style.textColor = JNBlackColor;
            return style;
        }];
        [JDStatusBarNotification showWithStatus:NSLocalizedString(@"Syncing", nil)];
        [JDStatusBarNotification showActivityIndicator:YES indicatorStyle:UIActivityIndicatorViewStyleGray];
    });
}

+ (void)dismiss
{
    runOnMainQueue(^{
        [JDStatusBarNotification dismiss];
    });
}

@end
