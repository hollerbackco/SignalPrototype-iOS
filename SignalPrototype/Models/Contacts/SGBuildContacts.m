//
//  SGBuildContacts.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 4/10/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <EXTScope.h>
#import <ReactiveCocoa.h>

#import "SGBuildContacts.h"
#import "SGContact.h"
#import "SGContact+Service.h"
#import "JNSimpleDataStore.h"
#import "SGMetrics.h"

dispatch_queue_t buildContactsQueue() {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("buildContactsQueue", 0);
    });
    return queue;
}

void runOnBuildContactsQueue(void (^block)(void))
{
    dispatch_async(buildContactsQueue(), block);
}

@interface SGBuildContacts () {
    BOOL _didAttemptContactAccess;
}

@end

@implementation SGBuildContacts

#pragma mark - Singleton

+ (id)sharedInstance {
    static SGBuildContacts *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - Class methods

+ (NSArray*)collateContacts:(NSArray *)contacts
{
    __block NSArray *sections = nil;
    __block TICK;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
        
        SEL selector = @selector(name);
        NSInteger idx, sectionTitlesCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
        
        NSMutableArray *mutableSections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
        for (idx = 0; idx < sectionTitlesCount; idx++) {
            [mutableSections addObject:[NSMutableArray array]];
        }
        
        for (id object in contacts) {
            NSInteger sectionNumber = [[UILocalizedIndexedCollation currentCollation] sectionForObject:object collationStringSelector:selector];
            [[mutableSections objectAtIndex:sectionNumber] addObject:object];
        }
        
        for (idx = 0; idx < sectionTitlesCount; idx++) {
            NSArray *objectsForSection = [mutableSections objectAtIndex:idx];
            NSArray *sortedArray = [collation sortedArrayFromArray:objectsForSection collationStringSelector:selector];
            [mutableSections replaceObjectAtIndex:idx withObject:sortedArray];
        }
        sections = mutableSections;
        TOCK;
    });
    return sections;
}

#pragma mark - Build methods

static BOOL _isCancelled = NO;

- (void)cancel
{
    _isCancelled = YES;
}

- (void)runForSectionType:(SGBuildContactsSectionType)sectionType
             grantAllowed:(void(^)())grantAllowed
              grantDenied:(void(^)())grantDenied
     cachedSectionsLoaded:(void(^)(NSArray *sections))cachedSectionsLoaded
        addressBookLoaded:(void(^)(NSArray *sections))addressBookLoaded
                completed:(void(^)(NSArray *sections))completed
                   failed:(void(^)(NSString *message))failed
{
    _isCancelled = NO;
    
    __block NSArray *cachedSections = nil;
    if (sectionType & SGBuildContactsSplitSections) {
        cachedSections = (NSArray*) [JNSimpleDataStore unarchiveObjectWithFilename:SGArchiveSplitContacts];
    } else if (sectionType & SGBuildContactsMixedSections) {
        cachedSections = (NSArray*) [JNSimpleDataStore unarchiveObjectWithFilename:SGArchiveMixedContacts];
    }
    
    // run block if sections were cached previously
    if ([NSArray isNotEmptyArray:cachedSections] && cachedSectionsLoaded) {
        cachedSectionsLoaded(cachedSections);
    }
    
    __block TICK;
    __block NSArray *hollerbackContactsFinal = @[];
    __block NSArray *addressBookContactsFinal = @[];
    
    if (_isCancelled)
        return;
    
    [self setDidAttemptContactAccess:YES];
    
    // get Address Book contacts
    [SGContact
     fetchSortedContactsFromAddressBookGranted:^{
         if (grantAllowed) {
             grantAllowed();
         }
     } denied:^{
         TOCK;
         if (grantDenied) {
             grantDenied();
         }
     } completed:^(NSArray *addressBookContacts) {
         if (_isCancelled)
             return;
         
         NSDate *totalBuildTime = [NSDate date];
         
         addressBookContactsFinal = addressBookContacts;
         
         if ([NSArray isEmptyArray:addressBookContactsFinal]) {
             completed(addressBookContactsFinal);
             return;
         }
         
         TOCK;
         JNLogPrimitive(addressBookContactsFinal.count);
         
         // convert each RHPerson to SGContact
         RETICK;
         NSMutableArray *convertedAddressBookContacts = [NSMutableArray arrayWithCapacity:addressBookContacts.count];
         [addressBookContactsFinal enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
             if ([obj isKindOfClass:[RHPerson class]]) {
                 SGContact *convertedContact = [SGContact convertRHPersonToSGContact:obj];
                 // determine if contacts with either phone/email accepted into the build
                 if (sectionType & SGBuildContactsWithEmailOrPhoneAttributes) {
                     if ([NSArray isEmptyArray:convertedContact.emails] &&
                         [NSArray isEmptyArray:convertedContact.phoneNumbers]) {
                         convertedContact = nil;
                     }
                 } else {
                     if ([NSArray isEmptyArray:convertedContact.phoneNumbers]) {
                         convertedContact = nil;
                     }
                 }
                 if (convertedContact) {
                     [convertedAddressBookContacts addObject:convertedContact];
                 }
             }
         }];
         JNLogPrimitive(convertedAddressBookContacts.count);
         addressBookContactsFinal = convertedAddressBookContacts;
         TOCK;
         
         if (_isCancelled)
             return;
         
         if (addressBookLoaded) {
             if (sectionType & SGBuildContactsSplitSections) {
                 NSArray *sections = nil;
                 if ([NSArray isNotEmptyArray:cachedSections]) {
                     NSArray *hollerbackContacts = cachedSections.firstObject;
                     if ([NSArray isEmptyArray:hollerbackContacts]) {
                         hollerbackContacts = @[];
                     }
                     sections = @[hollerbackContacts, addressBookContactsFinal];
                 }
                 if (addressBookLoaded) {
                     addressBookLoaded(sections);
                 }
             } else if (sectionType & SGBuildContactsMixedSections) {
                 if ([NSArray isNotEmptyArray:cachedSections]) {
                     addressBookLoaded(cachedSections);
                 }
             }
         }
         
         // split Address Book contacts into chunks
         NSArray *chunkedAddressBookContacts = [NSArray chunkArray:convertedAddressBookContacts chunkAmount:SGContactsCheckMaxPhoneNumbers];
         if ([NSArray isEmptyArray:chunkedAddressBookContacts]) {
             failed(NSLocalizedString(@"Build contacts failed", nil));
             return;
         }
         
         if (_isCancelled)
             return;
         
         RETICK;
         // array of RACReplaySubjects to know when contacts/check requests are complete
         NSMutableArray *completedContactsCheckSubjects = [NSMutableArray arrayWithCapacity:chunkedAddressBookContacts.count];
         
         // loop through each chunk of address book contacts
         // using NSArray enumerateObjectsWithOptions:NSEnumerationConcurrent cos it's FAST
         JNLogPrimitive(addressBookContactsFinal.count);
         __block BOOL didFail = NO;
         [chunkedAddressBookContacts enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj1, NSUInteger idx, BOOL *stop) {
             if ([obj1 isKindOfClass:[NSArray class]]) {
                 
                 // create parameters from chunked contacts
                 NSMutableArray *parameters = [NSMutableArray arrayWithCapacity:((NSArray*) obj1).count];
                 [obj1 enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj2, NSUInteger idx, BOOL *stop) {
                     if ([obj2 isKindOfClass:[SGContact class]]) {
                         NSDictionary *parameterizedContact = [SGContact parameterizeContact:obj2];
                         if (parameterizedContact) {
                             [parameters addObject:parameterizedContact];
                         } else {
                             // TODO:
                         }
                     }
                 }];
                 
                 // create a replay subject for each contacts/check request
                 RACReplaySubject *subject = [RACReplaySubject subject];
                 [completedContactsCheckSubjects addObject:subject];
                 
                 // perform contacts/check
                 [SGContact performContactsCheck:parameters success:^(id data) {
                     
                     if (_isCancelled)
                         return;
                     
                     NSArray *matchedContacts = [SGContact parseJSONContacts:data];
                     [subject sendNext:matchedContacts];
                     [subject sendCompleted];
                 } failed:^(NSString *errorMessage) {
                     // TODO:
                     if (failed) {
                         failed(errorMessage);
                     }
                     didFail = YES;
                     *stop = YES;
                 }];
             }
         }];
         if (didFail) {
             return;
         }
         
         // execute blocks when contacts/check has completed/failed
         [[RACSignal combineLatest:completedContactsCheckSubjects] subscribeNext:^(RACTuple *x) {
             
             if (_isCancelled)
                 return;
             
             JNLogPrimitive(addressBookContactsFinal.count);
             
             // flatten array
             NSArray *matchedContacts = [x.allObjects valueForKeyPath: @"@unionOfArrays.self"];
             
             JNLogPrimitive(matchedContacts.count);
             
             [[RACSignal combineLatest:[matchedContacts.rac_sequence map:^id(id value) {
                 NSAssert([value isKindOfClass:[SGContact class]], @"value is not a SGContact");
                 __block SGContact *contact = value;
                 return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                     
                     if (_isCancelled)
                         return nil;
                     
                     if (contact && ![contact isKindOfClass:[NSNull class]]) {
                         // filter matched contacts differently depending on sectionType
                         if (sectionType & SGBuildContactsSplitSections) {
                             // search for the SG contact in address book
                             NSArray *matchingAddressBookContacts = [SGContact findContactsbyHashedPhoneNumber:contact.phoneHashed inContactList:addressBookContactsFinal];
                             SGContact *matchingAddressBookContact = nil;
                             if ([NSArray isNotEmptyArray:matchingAddressBookContacts]) {
                                 // set phone & name for any matching contact from address book
                                 matchingAddressBookContact = matchingAddressBookContacts.firstObject;
                                 contact.phone = [SGContact getPhoneNumberForHashedPhoneNumber:contact.phoneHashed inContact:matchingAddressBookContact];
                                 contact.name = matchingAddressBookContact.name;
                             }
                             // remove contact from address book
                             if (matchingAddressBookContact) {
                                 NSMutableArray *mutableAddressBookContactsFinal = [addressBookContactsFinal mutableCopy];
                                 [mutableAddressBookContactsFinal removeObject:matchingAddressBookContact];
                                 addressBookContactsFinal = mutableAddressBookContactsFinal;
                             }
                         } else if (sectionType & SGBuildContactsMixedSections) {
                             // search for the SG contact in address book
                             NSArray *matchingAddressBookContacts = [SGContact findContactsbyHashedPhoneNumber:contact.phoneHashed inContactList:addressBookContactsFinal];
                             SGContact *matchingAddressBookContact = nil;
                             if ([NSArray isNotEmptyArray:matchingAddressBookContacts]) {
                                 // set phone & name for any matching contact from address book
                                 matchingAddressBookContact = matchingAddressBookContacts.firstObject;
                                 contact.phone = [SGContact getPhoneNumberForHashedPhoneNumber:contact.phoneHashed inContact:matchingAddressBookContact];
                                 contact.name = matchingAddressBookContact.name;
                             }
                             // replace contact from address book
                             if (matchingAddressBookContact) {
                                 NSMutableArray *mutableAddressBookContactsFinal = [addressBookContactsFinal mutableCopy];
                                 NSUInteger index = [mutableAddressBookContactsFinal indexOfObject:matchingAddressBookContact];
                                 [mutableAddressBookContactsFinal replaceObjectAtIndex:index withObject:contact];
                                 addressBookContactsFinal = mutableAddressBookContactsFinal;
                             }
                         }
                     }
                     
                     [subscriber sendCompleted];
                     return [RACDisposable disposableWithBlock:nil];
                 }];
             }]] subscribeCompleted:^{
                 //                 JNLog(@"completed");
             }];
             
             JNLog(@"finished matching");
             
             // finalied hollerback contacts
             hollerbackContactsFinal = matchedContacts;
             
         } error:^(NSError *error) {
             JNLogObject(error);
             TOCK;
         } completed:^{
             //             JNLog(@"completed");
             TOCK;
             JNLog(@"Total build time: %f", -[totalBuildTime timeIntervalSinceNow]);
             JNLogPrimitive(hollerbackContactsFinal.count);
             JNLogPrimitive(addressBookContactsFinal.count);
             
             [SGMetrics addMetric:SGKeenBuildContactsTime withObjectsAndKeys:@(-[totalBuildTime timeIntervalSinceNow]), @"timeInSecs", nil];
             
             if (_isCancelled)
                 return;
             
             NSArray *sections = nil;
             if (sectionType & SGBuildContactsSplitSections) {
                 // handle when no Hollberback contacts found
                 if (hollerbackContactsFinal.count == 0) {
                     sections = @[@[], addressBookContactsFinal];
                 } else {
                     // sort hollerback contacts
                     hollerbackContactsFinal = [hollerbackContactsFinal sortedArrayUsingComparator:^NSComparisonResult(SGContact *contact1, SGContact *contact2) {
                         return [contact1.name compare:contact2.name];
                     }];
                     sections = @[hollerbackContactsFinal, addressBookContactsFinal];
                 }
                 // archive sections
                 [JNSimpleDataStore archiveObject:sections filename:SGArchiveSplitContacts];
             } else if (sectionType & SGBuildContactsMixedSections) {
                 // collate to group the contacts by first letter of contact.name
                 sections = [SGBuildContacts collateContacts:addressBookContactsFinal];
                 // archive sections
                 [JNSimpleDataStore archiveObject:sections filename:SGArchiveMixedContacts];
             }
             completed(sections);
         }];
         
         JNLog(@"end");
         
     }];
}

#pragma mark - Management

- (BOOL)didAttemptContactAccess
{
    NSNumber *didAttemptContactAccess = (NSNumber*) [JNSimpleDataStore getValueForKey:kSGDidAttemptContactAccess];
    if (didAttemptContactAccess) {
        return didAttemptContactAccess.boolValue;
    } else {
        [JNSimpleDataStore setValue:@(NO) forKey:kSGDidAttemptContactAccess];
        return NO;
    }
}

- (void)setDidAttemptContactAccess:(BOOL)didAttemptContactAccess
{
    [JNSimpleDataStore setValue:@(didAttemptContactAccess) forKey:kSGDidAttemptContactAccess];
}

- (BOOL)isContactAccessAllowed
{
    if (![self didAttemptContactAccess]) {
        return NO;
    }
    //query current status, pre iOS6 always returns Authorized
    switch ([RHAddressBook authorizationStatus]) {
        case RHAuthorizationStatusAuthorized: {
            return YES;
            break;
        }
        case RHAuthorizationStatusNotDetermined: {
            return NO;
            break;
        }
        case RHAuthorizationStatusDenied: {
            return NO;
            break;
        }
        case RHAuthorizationStatusRestricted: {
            return NO;
            break;
        }
        default:
            return NO;
            break;
    }
}

@end
