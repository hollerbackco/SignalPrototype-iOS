//
//  SGContact+Service.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 2/10/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <NBPhoneNumberUtil.h>

#import "NSString+MD5.h"

#import "SGContact+Service.h"
#import "JNSimpleDataStore.h"
#import "SGUser+Service.h"

@implementation SGContact (Service)

+ (RHAddressBook*)sharedAddressBookInstance
{
    static RHAddressBook *_sharedAddressBookInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedAddressBookInstance = [RHAddressBook new];
    });
    return _sharedAddressBookInstance;
}

+ (void)fetchSortedContactsFromAddressBookGranted:(void(^)())grantedBlock
                                           denied:(void(^)())deniedBlock
                                        completed:(void(^)(NSArray *addressBookContacts))completedBlock
{
    TICK;
    //query current status, pre iOS6 always returns Authorized
    switch ([RHAddressBook authorizationStatus]) {
        case RHAuthorizationStatusAuthorized: {
            if (grantedBlock) {
                grantedBlock();
            }
            if (completedBlock) {
                completedBlock([[SGContact sharedAddressBookInstance] peopleOrderedByFirstName]);
            }
            TOCK;
            break;
        }
        case RHAuthorizationStatusNotDetermined: {
            //request authorization
            [[SGContact sharedAddressBookInstance] requestAuthorizationWithCompletion:^(bool granted, NSError *error) {
                if (granted) {
                    if (grantedBlock) {
                        grantedBlock();
                    }
                    if (completedBlock) {
                        completedBlock([[SGContact sharedAddressBookInstance] peopleOrderedByFirstName]);
                    }
                } else {
                    if (deniedBlock) {
                        deniedBlock();
                    }
                }
            }];
            TOCK;
            break;
        }
        case RHAuthorizationStatusDenied: {
            if (deniedBlock) {
                deniedBlock();
            }
            TOCK;
            break;
        }
        case RHAuthorizationStatusRestricted: {
            if (deniedBlock) {
                deniedBlock();
            }
            TOCK;
            break;
        }
        default:
            break;
    }
}

+ (SGContact*)convertRHPersonToSGContact:(RHPerson*)rhPerson
{
    SGContact *contact = [SGContact new];
    
    if (![NSString isNotEmptyString:rhPerson.compositeName]) {
        return nil;
    }
    
    // use composite name as display name
    contact.name = rhPerson.compositeName;
    contact.person = rhPerson;
    contact.emails = rhPerson.emails.values;
    NSMutableArray *phoneNumbers = [NSMutableArray arrayWithCapacity:rhPerson.phoneNumbers.count];
    for (NSString *phoneNumber in rhPerson.phoneNumbers.values) {
        NSString *normalizedPhoneNumber = [SGContact normalizePhoneNumber:phoneNumber];
        if (normalizedPhoneNumber) {
            [phoneNumbers addObject:normalizedPhoneNumber];
        } else {
            return nil;
        }
    }
    if ([NSArray isNotEmptyArray:phoneNumbers]) {
        contact.phoneNumbers = phoneNumbers;
    }
    return contact;
}

+ (NSString*)hashedPhoneNumber:(NSString*)phoneNumber
{
    return phoneNumber.MD5String;
}

+ (NSDictionary*)parameterizeContact:(SGContact*)contact
{
    if ([NSArray isNotEmptyArray:contact.phoneHashedNumbers]) {
        // phone numbers have already been hashed, so just create the parameters
        NSDictionary *params = [SGContact parametersFromContactWithHashedPhoneNumbers:contact];
        if ([NSDictionary isNotNullDictionary:params]) {
            return params;
        }
    } else {
        // phone numbers not yet hashed, need to normalize + hash phoneNumbers before parameterizing
        if (contact.person) {
            if ([NSArray isNotEmptyArray:contact.person.phoneNumbers.values]) {
                NSInteger phoneCount = contact.person.phoneNumbers.count;
                NSMutableArray *phoneNumbers = [NSMutableArray arrayWithCapacity:phoneCount];
                NSMutableArray *phoneHashedNumbers = [NSMutableArray arrayWithCapacity:phoneCount];
                for (__strong NSString *phoneNumber in contact.person.phoneNumbers.values) {
                    // hack: fix for iOS 7 and libPhoneNumber compatibility
                    phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:
                                    [[NSCharacterSet characterSetWithCharactersInString:@"+0123456789"]
                                     invertedSet]]
                                   componentsJoinedByString:@""];
//                    // check if phone number is in normalized numbers cache
//                    NSString *normalizedNumber = [normalizedNumbers objectForKey:phoneNumber];
//                    if (!normalizedNumber) {
//                        normalizedNumber = [SGBaseContactsViewController normalizePhoneNumber:phoneNumber
//                                                                                       region:[[SGContactsManager shared] region]
//                                                                                    phoneUtil:[[SGContactsManager shared] phoneUtil]];
//                        [normalizedNumbers setValue:normalizedNumber forKey:phoneNumber];
//                    }
                    
                    NSString *normalizedNumber = [SGContact normalizePhoneNumber:phoneNumber];

                    if ([NSString isNotEmptyString:normalizedNumber]) {
                        [phoneNumbers addObject:normalizedNumber];
                        [phoneHashedNumbers addObject:[SGContact hashedPhoneNumber:normalizedNumber]];
                    }

                }
                contact.phoneNumbers = phoneNumbers;
                contact.phoneHashedNumbers = phoneHashedNumbers;
                contact.person = nil;
                // add to parameters
                NSDictionary *params = [self parametersFromContactWithHashedPhoneNumbers:contact];
                if ([NSDictionary isNotNullDictionary:params]) {
                    return params;
                }
            }
        }
//        // replace address book contacts
//        @synchronized(self.contactsFromAddressBook) {
//            int index = [self.contactsFromAddressBook indexOfObject:contact];
//            if (index != NSNotFound)
//                [self.contactsFromAddressBook replaceObjectAtIndex:index withObject:contact];
//        }
    }
    return nil;
}

+ (NSDictionary*)parametersFromContactWithHashedPhoneNumbers:(SGContact*)contact
{
    if ([NSString isNotEmptyString:contact.name] &&
        [NSArray isNotEmptyArray:contact.phoneHashedNumbers]) {
        return @{@"n": contact.name, @"p": [contact.phoneHashedNumbers componentsJoinedByString:@","]};
    }
    return nil;
}

+ (void)performContactsCheck:(NSArray*)parameterizedContacts
                     success:(void(^)(id data))success
                      failed:(void(^)(NSString *errorMessage))failed
{
    if (!parameterizedContacts || parameterizedContacts.count == 0) {
        failed(@"No contacts found.");
        return;
    }
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithCapacity:2];
    [mutableParameters setValue:parameterizedContacts forKey:@"c"];
    id accessToken = [JNSimpleDataStore getValueForKey:kSGAccessTokenKey];
    if (accessToken) {
        [mutableParameters setValue:accessToken forKey:kSGAccessTokenKey];
    }
    
    [self.class checkContacts:mutableParameters success:^(id object) {
        // success
        if ([object isKindOfClass:[NSDictionary class]]) {
            id data = [object objectForKey:@"data"];
            if ([NSArray isNotEmptyArray:[NSArray class]]) {
                success(data);
            } else {
                success(@[]);
            }
        } else if ([NSArray isNotEmptyArray:object]) {
            success(object);
        } else {
            success(object);
        }

    } fail:^(NSString *errorMessage) {
        
        failed(errorMessage);
    }];
}

+ (SGContact*)parseJSONContact:(NSDictionary*)jsonContact
{
    SGContact *contact = [SGContact new];

    NSString *name = [jsonContact objectForKey:@"name"];
    if ([NSString isNotEmptyString:name])
        contact.name = name;
    NSString *username = [jsonContact objectForKey:@"username"];
    if ([NSString isNotEmptyString:username])
        contact.username = username;
    NSString *phone = [jsonContact objectForKey:@"phone_normalized"];
    if ([NSString isNotEmptyString:phone])
        contact.phone = phone;
    NSString *phoneHashed = [jsonContact objectForKey:@"phone_hashed"];
    if ([NSString isNotEmptyString:phoneHashed])
        contact.phoneHashed = phoneHashed;
    NSNumber *isAGroup = [jsonContact objectForKey:@"is_group"];
    if ([NSNumber isNotNullNumber:isAGroup])
        contact.isAGroup = isAGroup.boolValue;
    contact.hasSignedUp = YES;
    
    return contact;
}

+ (NSArray*)parseJSONContacts:(NSArray*)jsonContacts
{
    NSMutableArray *parsedContacts = [NSMutableArray arrayWithCapacity:jsonContacts.count];
    [jsonContacts enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        @synchronized(parsedContacts) {
            [parsedContacts addObject:[SGContact parseJSONContact:obj]];
        };
    }];

    return parsedContacts;
}

+ (NSArray*)findContactsbyHashedPhoneNumber:(NSString*)hashedPhoneNumber inContactList:(NSArray*)contactList
{
    if ([NSString isNotEmptyString:hashedPhoneNumber]) {
        return [contactList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.phoneHashedNumbers CONTAINS %@", hashedPhoneNumber]];
    }
    return nil;
}

+ (NSArray*)removeContact:(SGContact*)contact inContactList:(NSArray*)contactList
{
    // match by hashed phone
    if ([NSString isNotEmptyString:contact.phoneHashed]) {
        NSMutableArray *filtered = [contactList mutableCopy];
        [filtered filterUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF.phoneHashedNumbers CONTAINS %@", contact.phoneHashed]];
        return filtered;
    }
    // returning nil if nothing was done
    return nil;
}

+ (NSArray*)replaceContact:(SGContact*)contact inContactList:(NSArray*)contactList
{
    // match by hashed phone
    if ([NSString isNotEmptyString:contact.phoneHashed]) {
        NSMutableArray *filtered = [contactList mutableCopy];
        [filtered filterUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF.phoneHashedNumbers CONTAINS %@", contact.phoneHashed]];
        [filtered addObject:contact];
        return filtered;
    }
    // returning nil if nothing was done
    return nil;
}

+ (NSString*)getPhoneNumberForHashedPhoneNumber:(NSString*)hashedPhoneNumber inContact:(SGContact*)contact
{
    if (contact.phone) {
        return contact.phone;
    }
    for (NSString *phoneNumber in contact.phoneNumbers) {
        if ([[SGContact hashedPhoneNumber:phoneNumber] isEqualToString:hashedPhoneNumber]) {
            return phoneNumber;
        }
    }
    return nil;
}

+ (NSArray*)buildUsernamesFromFriends:(NSArray*)friends
{
    if ([NSArray isEmptyArray:friends]) {
        return nil;
    }
    // create array of usernames
    NSMutableArray *usernames = [NSMutableArray array];
    for (id friend in friends) {
        if ([friend isKindOfClass:[SGUser class]]) {
            NSString *username = ((SGUser*) friend).username;
            if ([NSString isNotEmptyString:username]) {
                [usernames addObject:username];
            }
        }
        else {
            if ([friend respondsToSelector:@selector(username)]) {
                id username = [friend performSelector:@selector(username)];
                if (username) {
                    [usernames addObject:username];
                }
            }
        }
    }
    if ([NSArray isNotEmptyArray:usernames]) {
        return [[NSSet setWithArray:usernames] allObjects];
    }
    return nil;
}

+ (NSArray*)buildInvitePhoneNumbersFromFriends:(NSArray*)friends
{
    if ([NSArray isEmptyArray:friends]) {
        return nil;
    }
    // create array of phone #s
    NSMutableArray *invites = [NSMutableArray array];
    for (id friend in friends) {
        if ([friend isKindOfClass:[SGContact class]]) {
            if ([friend respondsToSelector:@selector(hasSignedUp)] &&
                ![friend performSelector:@selector(hasSignedUp)]) {
                if ([NSString isNotEmptyString:((SGContact*) friend).phone]) {
                    [invites addObject:((SGContact*) friend).phone];
                }
                if ([NSString isNotEmptyString:((SGContact*) friend).primaryPhoneNumber]) {
                    [invites addObject:((SGContact*) friend).primaryPhoneNumber];
                } else {
                    NSArray *phoneNumbers = ((SGContact*) friend).phoneNumbers;
                    if ([NSArray isNotEmptyArray:phoneNumbers]) {
                        [invites addObjectsFromArray:phoneNumbers];
                    }
                }
            }
        } else if ([friend isKindOfClass:[RHPerson class]]) {
            RHMultiValue *phoneNumbers = ((RHPerson*) friend).phoneNumbers;
            if (phoneNumbers) {
                if ([NSArray isNotEmptyArray:phoneNumbers.values]) {
                    [invites addObjectsFromArray:phoneNumbers.values];
                }
            }
        }
    }
    if ([NSArray isNotEmptyArray:invites]) {
        return [[NSSet setWithArray:invites] allObjects];
    }
    return nil;
}

+ (NSArray*)buildInviteContactsFromFriends:(NSArray*)friends
{
    if ([NSArray isEmptyArray:friends]) {
        return nil;
    }
    // create array of contacts
    NSMutableArray *invites = [NSMutableArray array];
    for (id friend in friends) {
        if ([friend isKindOfClass:[SGContact class]]) {
            if ([friend respondsToSelector:@selector(hasSignedUp)] &&
                ![friend performSelector:@selector(hasSignedUp)]) {
                [invites addObject:friend];
            }
        } else if ([friend isKindOfClass:[RHPerson class]]) {
            SGContact *contact = [SGContact convertRHPersonToSGContact:friend];
            [invites addObject:contact];
        }
    }
    if ([NSArray isNotEmptyArray:invites]) {
        return [[NSSet setWithArray:invites] allObjects];
    }
    return nil;
}

#pragma mark - API 

#pragma mark Check contacts

+ (void)checkContacts:(NSDictionary*)parameters
              success:(SGAPIClientSuccessBlock)success
                 fail:(SGAPIClientFailBlock)fail
{
    [[SGAPIClient sharedClient] POST:@"contacts/check" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        JNLogObject(responseObject);
        if ([responseObject respondsToSelector:@selector(objectForKey:)]) {
            id data = [responseObject objectForKey:@"data"];
            if ([NSDictionary isNotNullDictionary:data]) {
                success(data);
            } else if ([NSArray isNotEmptyArray:data]) {
                success(data);
            } else {
                success(responseObject);
            }
        } else {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        fail(JNLocalizedString(@"failed.request.check.contacts.alert.body"));
    }];
}

@end

#pragma mark - NSArray (ChunkedArray)

@implementation NSArray (ChunkedArray)

+ (NSArray*)chunkArray:(NSArray*)arrayToChunk chunkAmount:(NSUInteger)chunkAmount
{
    NSMutableArray *chunkedArray = nil;
    @try {
        if (chunkAmount == 0)
            return nil;
        
        NSUInteger numberOfChunks = (int) ceilf((float)arrayToChunk.count/(float)chunkAmount);
        chunkedArray = [NSMutableArray arrayWithCapacity:numberOfChunks];
        NSUInteger itemsRemaining = arrayToChunk.count, i = 0;
        while (i < arrayToChunk.count) {
            NSRange range = NSMakeRange(i, MIN(chunkAmount, itemsRemaining));
            NSArray *subarray = [arrayToChunk subarrayWithRange:range];
            [chunkedArray addObject:subarray];
            
            itemsRemaining -= range.length;
            i += range.length;
        }
    }
    @catch (NSException *exception) {
        JNLogObject(chunkedArray);
        [JNLogger logException:exception];
    }
    return chunkedArray;
}

@end

#pragma mark - Phone number utils (should prob be moved elsewhere)

@implementation SGContact (PhoneNumberUtils)

+ (NSString*)countryCodeForCountryDialingCode:(NSString*)countryDialingCode
{
    NSNumberFormatter *fm = [[NSNumberFormatter alloc] init];
    fm.numberStyle = NSNumberFormatterNoStyle;
    NSNumber *countryDialingCodeNumber = [fm numberFromString:countryDialingCode];
    // get the region
    NSArray *regions = [[NBPhoneNumberUtil sharedInstance] regionCodeFromCountryCode:countryDialingCodeNumber.intValue];
    if ([NSArray isNotEmptyArray:regions]) {
        return (NSString*) regions.firstObject;
    } else {
        return nil;
    }
}

+ (NSString*)normalizePhoneNumber:(NSString*)phoneNumber
{
    phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:
                       [[NSCharacterSet characterSetWithCharactersInString:@"+0123456789"]
                        invertedSet]]
                      componentsJoinedByString:@""];
    // perform parse
    @try {
        // skip if number is invalid
        if (![[NBPhoneNumberUtil sharedInstance] isViablePhoneNumber:phoneNumber])
            return nil;

        NSError *error;
        NBPhoneNumber *parsedPhoneNumber;
        @synchronized([NBPhoneNumberUtil sharedInstance]) {
            parsedPhoneNumber = [[NBPhoneNumberUtil sharedInstance] parse:phoneNumber defaultRegion:[SGContact defaultPhoneRegion] error:&error];
        }
        if (parsedPhoneNumber && !error) {
            // return formatted number
            NSString *formattedPhoneNumber = [[NBPhoneNumberUtil sharedInstance] format:parsedPhoneNumber numberFormat:NBEPhoneNumberFormatE164 error:nil];
            if (formattedPhoneNumber && !error) {
                return formattedPhoneNumber;
            } else {
                return nil;
            }
        } else {
            return nil;
        }
    }
    @catch (NSException *exception) {
        JNLogObject(phoneNumber);
        [JNLogger logException:exception];
        return nil;
    }
}

+ (NSString*)defaultPhoneRegion
{
    static NSString *defaultPhoneRegion = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSNumber *countryCode = (NSNumber*) [JNSimpleDataStore getValueForKey:SGCountryCodeKey];
        // Default the country code to US if none found.
        // TODO: should really get by users location or sign in response.
        if (![NSNumber isNotNullNumber:countryCode]) {
            countryCode = @(SGDefaultCountryCode);
        }
        // get the region
        NSArray *regions = [[NBPhoneNumberUtil sharedInstance] regionCodeFromCountryCode:countryCode.intValue];
        if ([NSArray isNotEmptyArray:regions])
            defaultPhoneRegion = regions.firstObject;
        else
            defaultPhoneRegion = SGDefaultRegion;
    });
    return defaultPhoneRegion;
}

+ (NSString*)formatPhoneNumber:(NSString*)phoneNumber withFormat:(NBEPhoneNumberFormat)format
{
    NSString *formattedPhoneNumber = nil;
    NSError *error;
    NBPhoneNumber *nbPhoneNumber = [[NBPhoneNumberUtil sharedInstance] parse:phoneNumber defaultRegion:[SGContact defaultPhoneRegion] error:&error];
    if (error) {
        JNLogObject(error);
        return nil;
    }
    if (nbPhoneNumber) {
        formattedPhoneNumber = [[NBPhoneNumberUtil sharedInstance] format:nbPhoneNumber numberFormat:format error:&error];
        if (error) {
            JNLogObject(error);
            return nil;
        }
    }
    return formattedPhoneNumber;
}

+ (NSString*)formatPhoneNumberForSending:(NSString*)phoneNumber
{
    return [self.class formatPhoneNumber:phoneNumber withFormat:NBEPhoneNumberFormatE164];
}

+ (NSString*)formatPhoneNumberForNationalDisplay:(NSString*)phoneNumber
{
    return [self.class formatPhoneNumber:phoneNumber withFormat:NBEPhoneNumberFormatNATIONAL];
}

+ (NSString*)formatPhoneNumberForInternationalDisplay:(NSString*)phoneNumber
{
    return [self.class formatPhoneNumber:phoneNumber withFormat:NBEPhoneNumberFormatINTERNATIONAL];
}

@end
