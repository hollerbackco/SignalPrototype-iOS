//
//  HBRegisterViewController.h
//  HollerbackApp
//
//  Created by poprot on 10/2/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JNViewController.h"

@protocol HBRegisterViewDelegate

- (void)didRegisterWithPhone:(NSString *)phone;

@end

@interface HBRegisterViewController : JNViewController

//@property (nonatomic, weak) id<HBVerifyPhoneViewDelegate> verifyPhoneViewDelegate;
@property (nonatomic, weak) id<HBRegisterViewDelegate> delegate;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;

- (id)initWithTitle:(NSString*)title email:(NSString*)email password:(NSString*)password delegate:(id<HBRegisterViewDelegate>)delegate;

@end
