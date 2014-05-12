//
//  JNViewController+MultiValueSelector.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 5/05/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "JNViewController.h"
#import "SGContact+Service.h"

@interface JNViewController (MultiPhoneSelector) <UIActionSheetDelegate>

#pragma mark - Primary Phone Number Selection

- (BOOL)contactHasMultiplePhoneNumbers:(SGContact*)contact;

- (NSArray*)phoneNumbersForContact:(SGContact*)contact;

- (void)performPrimaryPhoneNumberSelection:(SGContact*)contact completed:(void(^)(SGContact *updatedContact))completed;

@end


@interface JNViewController (MultiEmailSelector) <UIActionSheetDelegate>

#pragma mark - Primary Email Selection

- (BOOL)contactHasMultipleEmails:(SGContact*)contact;

- (NSArray*)emailsForContact:(SGContact*)contact;

- (void)performPrimaryEmailSelection:(SGContact*)contact completed:(void(^)(SGContact *updatedContact))completed;

@end
