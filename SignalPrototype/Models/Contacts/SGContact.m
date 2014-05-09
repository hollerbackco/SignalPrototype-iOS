//
//  SGContact.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 9/07/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "SGContact.h"

#define kNameKey @"Name"
#define kUsernameKey @"Username"
#define kPhoneKey @"Phone"
#define kPhoneHashedKey @"PhoneHashed"
#define kIsAGroupKey @"IsAGroup"
#define kConversationObjectIDURIKey @"ConversationObjectIDURI"
#define kHasSignedUpKey @"HasSignedUp"
#define kPhoneNumbersKey @"PhoneNumbers"
#define kPhoneHashedNumbersKey @"PhoneHashedNumbers"
#define kEmailsKey @"EmailsKey"
#define kPrimaryPhoneNumber @"PrimaryPhoneNumber"
#define kPrimaryEmail @"PrimaryEmail"

@implementation SGContact

- (NSString*)description
{
    NSString *description = [NSString stringWithFormat:@"name:%@\nusername:%@\nphone:%@\nphoneHashed:%@\nisAGroup:%@\nconversationObjectIDURI:%@\nhasSignedUp:%@\nphoneNumbers:%@\nphoneHashedNumbers:%@\nemails:%@\nprimaryPhoneNumber:%@\nprimaryEmail:%@", self.name, self.username, self.phone, self.phoneHashed, @(self.isAGroup), self.conversationObjectIDURI, @(self.hasSignedUp), self.phoneNumbers, self.phoneHashedNumbers, self.emails, self.primaryPhoneNumber, self.primaryEmail];
    return description;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    SGContact *contact = [[[self class] allocWithZone:zone] init];
    if (contact) {
        contact.name = [_name copyWithZone:zone];
        contact.username = [_username copyWithZone:zone];
        contact.phone = [_phone copyWithZone:zone];
        contact.phoneHashed = [_phoneHashed copyWithZone:zone];
        contact.isAGroup = _isAGroup;
        contact.conversationObjectIDURI = [_conversationObjectIDURI copyWithZone:zone];
        contact.hasSignedUp = _hasSignedUp;
        contact.phoneNumbers = [_phoneNumbers copyWithZone:zone];
        contact.phoneHashedNumbers = [_phoneHashedNumbers copyWithZone:zone];
        contact.emails = [_emails copyWithZone:zone];
        contact.primaryPhoneNumber = [_primaryPhoneNumber copyWithZone:zone];
        contact.primaryEmail = [_primaryEmail copyWithZone:zone];
    }
    return contact;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name forKey:kNameKey];
    [aCoder encodeObject:_username forKey:kUsernameKey];
    [aCoder encodeObject:_phone forKey:kPhoneKey];
    [aCoder encodeObject:_phoneHashed forKey:kPhoneHashedKey];
    [aCoder encodeBool:_isAGroup forKey:kIsAGroupKey];
    [aCoder encodeObject:_conversationObjectIDURI forKey:kConversationObjectIDURIKey];
    [aCoder encodeBool:_hasSignedUp forKey:kHasSignedUpKey];
    [aCoder encodeObject:_phoneNumbers forKey:kPhoneNumbersKey];
    [aCoder encodeObject:_phoneHashedNumbers forKey:kPhoneHashedNumbersKey];
    [aCoder encodeObject:_emails forKey:kEmailsKey];
    [aCoder encodeObject:_primaryPhoneNumber forKey:kPrimaryPhoneNumber];
    [aCoder encodeObject:_primaryEmail forKey:kPrimaryEmail];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:kNameKey];
        _username = [aDecoder decodeObjectForKey:kUsernameKey];
        _phone = [aDecoder decodeObjectForKey:kPhoneKey];
        _phoneHashed = [aDecoder decodeObjectForKey:kPhoneHashedKey];
        _isAGroup = [aDecoder decodeBoolForKey:kIsAGroupKey];
        _conversationObjectIDURI = [aDecoder decodeObjectForKey:kConversationObjectIDURIKey];
        _hasSignedUp = [aDecoder decodeBoolForKey:kHasSignedUpKey];
        _phoneNumbers = [aDecoder decodeObjectForKey:kPhoneNumbersKey];
        _phoneHashedNumbers = [aDecoder decodeObjectForKey:kPhoneHashedNumbersKey];
        _emails = [aDecoder decodeObjectForKey:kEmailsKey];
        _primaryPhoneNumber = [aDecoder decodeObjectForKey:kPrimaryPhoneNumber];
        _primaryEmail = [aDecoder decodeObjectForKey:kPrimaryEmail];
    }
    return self;
}

@end
