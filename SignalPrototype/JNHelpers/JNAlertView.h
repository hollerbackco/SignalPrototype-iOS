//
//  JNAlertView.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 29/10/2013.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIView+JNHelper.h"

@interface JNAlertView : UIAlertView

+ (JNAlertView*)showWithTitle:(NSString*)title
                         body:(NSString*)body;

+ (JNAlertView*)showWithTitle:(NSString*)title
                         body:(NSString*)body
                     okAction:(void(^)())okAction;

+ (JNAlertView*)showWithTitle:(NSString*)title
                         body:(NSString*)body
                     okAction:(void(^)())okAction
                       okText:(NSString*)okText
                 cancelAction:(void(^)())cancelAction
                   cancelText:(NSString*)cancelText;

+ (JNAlertView*)showWithTitle:(NSString*)title
                         body:(NSString*)body
                  firstAction:(void(^)())firstAction
                    firstText:(NSString*)firstText
                 secondAction:(void(^)())secondAction
                   secondText:(NSString*)secondText
                  thirdAction:(void(^)())thirdAction
                    thirdText:(NSString*)thirdText;

@end
