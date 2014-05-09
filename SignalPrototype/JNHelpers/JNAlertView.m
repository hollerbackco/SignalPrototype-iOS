//
//  JNAlertView.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 29/10/2013.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <ReactiveCocoa.h>

#import "JNAlertView.h"

@interface JNAlertView ()

@end

@implementation JNAlertView

+ (JNAlertView*)showWithTitle:(NSString*)title
                         body:(NSString*)body
{
    return [self.class showWithTitle:title body:body okAction:nil];
}

+ (JNAlertView*)showWithTitle:(NSString*)title
                         body:(NSString*)body
                     okAction:(void(^)())okAction
{
    return [self.class showWithTitle:title body:body okAction:okAction okText:@"OK" cancelAction:nil cancelText:nil];
}

+ (JNAlertView*)showWithTitle:(NSString*)title
                         body:(NSString*)body
                     okAction:(void(^)())okAction
                       okText:(NSString*)okText
                 cancelAction:(void(^)())cancelAction
                   cancelText:(NSString*)cancelText
{
    NSString *otherTitle = cancelText;
    JNAlertView *alertView =
    (JNAlertView*) [[UIAlertView alloc]
                    initWithTitle:title
                    message:body
                    delegate:nil
                    cancelButtonTitle:okText
                    otherButtonTitles:otherTitle, nil];
    [[alertView rac_buttonClickedSignal] subscribeNext:^(id x) {
        JNLogObject(x);
        JNLog();
        switch (((NSNumber*) x).intValue) {
            case 0:
                if (okAction) {
                    okAction();
                }
                break;
            case 1:
                if (cancelAction) {
                    cancelAction();
                }
            default:
                break;
        }
    }];
    [alertView show];
    return alertView;
}

+ (JNAlertView*)showWithTitle:(NSString*)title
                         body:(NSString*)body
                  firstAction:(void(^)())firstAction
                    firstText:(NSString*)firstText
                 secondAction:(void(^)())secondAction
                   secondText:(NSString*)secondText
                  thirdAction:(void(^)())thirdAction
                    thirdText:(NSString*)thirdText
{
    JNAlertView *alertView =
    (JNAlertView*) [[UIAlertView alloc]
                    initWithTitle:title
                    message:body
                    delegate:nil
                    cancelButtonTitle:thirdText
                    otherButtonTitles:firstText, secondText, nil];
    [[alertView rac_buttonClickedSignal] subscribeNext:^(id x) {
        switch (((NSNumber*) x).intValue) {
            case 0:
                if (thirdAction) {
                    thirdAction();
                }
                break;
            case 1:
                if (firstAction) {
                    firstAction();
                }
                break;
            case 2:
                if (secondAction) {
                    secondAction();
                }
                break;
            default:
                break;
        }
    }];
    [alertView show];
    return alertView;
}

@end
