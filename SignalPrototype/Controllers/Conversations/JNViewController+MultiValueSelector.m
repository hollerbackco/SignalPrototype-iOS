//
//  JNViewController+MultiValueSelector.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 5/05/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "JNViewController+MultiValueSelector.h"

@implementation JNViewController (MultiPhoneSelector)

#pragma mark - Primary Phone Number Selection

- (BOOL)contactHasMultiplePhoneNumbers:(SGContact*)contact
{
    if ([contact isKindOfClass:[SGContact class]]) {
        NSArray *phoneNumbers = ((SGContact*) contact).phoneNumbers;
        if ([NSArray isNotEmptyArray:phoneNumbers]) {
            return phoneNumbers.count > 1;
        } else {
            return NO;
        }
    } else if ([contact isKindOfClass:[RHPerson class]]) {
        RHMultiStringValue *phoneNumbersValue = ((RHPerson*) contact).phoneNumbers;
        if (phoneNumbersValue) {
            NSArray *phoneNumbers = phoneNumbersValue.values;
            if ([NSArray isNotEmptyArray:phoneNumbers]) {
                return phoneNumbers.count > 1;
            } else {
                return NO;
            }
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (NSArray*)phoneNumbersForContact:(SGContact*)contact
{
    NSArray *phoneNumbers;
    if ([contact isKindOfClass:[SGContact class]]) {
        phoneNumbers = contact.phoneNumbers;
    }
    return phoneNumbers;
}

- (void)performPrimaryPhoneNumberSelection:(SGContact*)contact completed:(void(^)(SGContact *updatedContact))completed
{
    NSArray *phoneNumbers = [self phoneNumbersForContact:contact];
    if ([NSArray isNotEmptyArray:phoneNumbers]) {
        
        UIActionSheet *actionSheet =
        [[UIActionSheet alloc]
         initWithTitle:JNLocalizedString(@"send.to.multi.phone.action.sheet.title")
         delegate:self
         cancelButtonTitle:nil
         destructiveButtonTitle:nil
         otherButtonTitles:nil];
        
        [phoneNumbers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSString *formattedPhoneNumber = [SGContact formatPhoneNumberForInternationalDisplay:obj];
            if ([NSString isNotEmptyString:formattedPhoneNumber]) {
                [actionSheet addButtonWithTitle:formattedPhoneNumber];
            }
        }];
        
        [actionSheet showInView:self.view];
        
        [[actionSheet rac_buttonClickedSignal] subscribeNext:^(id x) {
            NSString *primaryPhoneNumber = [phoneNumbers objectAtIndex:((NSNumber*) x).integerValue];
            SGContact *updatedContact = contact;
            updatedContact.primaryPhoneNumber = primaryPhoneNumber;
            
            if (completed) {
                completed(updatedContact);
            }
        }];
    } else {
        if (completed) {
            completed(contact);
        }
    }
}

#pragma mark - UIActionSheetDelegate

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    [actionSheet.subviews enumerateObjectsUsingBlock:^(id _currentView, NSUInteger idx, BOOL *stop) {
        if ([_currentView isKindOfClass:[UIButton class]]) {
            ((UIButton *)_currentView).titleLabel.font = [UIFont primaryFont];
        }
    }];
}

@end





@implementation JNViewController (MultiEmailSelector)

#pragma mark - Primary Email Selection

- (BOOL)contactHasMultipleEmails:(SGContact*)contact
{
    if ([contact isKindOfClass:[SGContact class]]) {
        NSArray *emails = ((SGContact*) contact).emails;
        if ([NSArray isNotEmptyArray:emails]) {
            return emails.count > 1;
        } else {
            return NO;
        }
    } else if ([contact isKindOfClass:[RHPerson class]]) {
        RHMultiStringValue *emailsValue = ((RHPerson*) contact).emails;
        if (emailsValue) {
            NSArray *emails = emailsValue.values;
            if ([NSArray isNotEmptyArray:emails]) {
                return emails.count > 1;
            } else {
                return NO;
            }
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}


- (NSArray*)emailsForContact:(SGContact*)contact
{
    NSArray *emails;
    if ([contact isKindOfClass:[SGContact class]]) {
        emails = contact.emails;
    }
    return emails;
}

- (void)performPrimaryEmailSelection:(SGContact*)contact completed:(void(^)(SGContact *updatedContact))completed
{
    NSArray *emails = [self emailsForContact:contact];
    if ([NSArray isNotEmptyArray:emails]) {
        
        UIActionSheet *actionSheet =
        [[UIActionSheet alloc]
         initWithTitle:JNLocalizedString(@"send.to.multi.email.action.sheet.title")
         delegate:self
         cancelButtonTitle:nil
         destructiveButtonTitle:nil
         otherButtonTitles:nil];
        
        [emails enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            [actionSheet addButtonWithTitle:obj];
        }];
        
        [actionSheet showInView:self.view];
        
        [[actionSheet rac_buttonClickedSignal] subscribeNext:^(id x) {
            NSString *primaryEmail = [emails objectAtIndex:((NSNumber*) x).integerValue];
            SGContact *updatedContact = contact;
            updatedContact.primaryEmail = primaryEmail;
            
            if (completed) {
                completed(updatedContact);
            }
        }];
    } else {
        if (completed) {
            completed(contact);
        }
    }
}

#pragma mark - UIActionSheetDelegate

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    [actionSheet.subviews enumerateObjectsUsingBlock:^(id _currentView, NSUInteger idx, BOOL *stop) {
        if ([_currentView isKindOfClass:[UIButton class]]) {
            ((UIButton *)_currentView).titleLabel.font = [UIFont primaryFont];
        }
    }];
}

@end
