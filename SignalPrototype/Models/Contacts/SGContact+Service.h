//
//  SGContact+Service.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 2/10/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <RHAddressBook.h>

#import "SGContact.h"
#import "SGAPIClient.h"

@interface SGContact (Service)

+ (RHAddressBook*)sharedAddressBookInstance;

+ (void)fetchSortedContactsFromAddressBookGranted:(void(^)())grantedBlock
                                           denied:(void(^)())deniedBlock
                                        completed:(void(^)(NSArray *addressBookContacts))completedBlock;

+ (SGContact*)convertRHPersonToSGContact:(RHPerson*)rhPerson;

+ (NSString*)hashedPhoneNumber:(NSString*)phoneNumber;

+ (NSDictionary*)parameterizeContact:(SGContact*)contact;

+ (NSDictionary*)parametersFromContactWithHashedPhoneNumbers:(SGContact*)contact;

+ (void)performContactsCheck:(NSArray*)parameterizedContacts
                     success:(void(^)(id data))success
                      failed:(void(^)(NSString *errorMessage))failed;

+ (SGContact*)parseJSONContact:(NSDictionary*)jsonContact;

+ (NSArray*)parseJSONContacts:(NSArray*)jsonContacts;

+ (NSArray*)findContactsbyHashedPhoneNumber:(NSString*)hashedPhoneNumber inContactList:(NSArray*)contactList;

// removes contact from contactList using contact.phoneHased to match
+ (NSArray*)removeContact:(SGContact*)contact inContactList:(NSArray*)contactList;

+ (NSArray*)replaceContact:(SGContact*)contact inContactList:(NSArray*)contactList;

+ (NSString*)getPhoneNumberForHashedPhoneNumber:(NSString*)hashedPhoneNumber inContact:(SGContact*)contact;

+ (NSArray*)buildUsernamesFromFriends:(NSArray*)friends;

+ (NSArray*)buildInvitePhoneNumbersFromFriends:(NSArray*)friends;

+ (NSArray*)buildInviteContactsFromFriends:(NSArray*)friends;

#pragma mark - Check contacts

// NOTE: check/contacts can be called with access_token and will return different results. It is up to the caller to provide the access_token
+ (void)checkContacts:(NSDictionary*)parameters
              success:(SGAPIClientSuccessBlock)success
                 fail:(SGAPIClientFailBlock)fail;

@end

@interface NSArray (ChunkedArray)

+ (NSArray*)chunkArray:(NSArray*)arrayToChunk chunkAmount:(NSUInteger)chunkAmount;

@end

@interface SGContact (PhoneNumberUtils)

#pragma mark - Phone number utils (should prob be moved elsewhere)

+ (NSString*)countryCodeForCountryDialingCode:(NSString*)countryDialingCode;
+ (NSString*)defaultPhoneRegion;
+ (NSString*)normalizePhoneNumber:(NSString*)phoneNumber;
+ (NSString*)formatPhoneNumberForSending:(NSString*)phoneNumber;
+ (NSString*)formatPhoneNumberForNationalDisplay:(NSString*)phoneNumber;
+ (NSString*)formatPhoneNumberForInternationalDisplay:(NSString*)phoneNumber;

@end
