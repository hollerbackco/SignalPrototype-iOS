//
//  SGBuildContacts.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 4/10/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SGBuildContactsSplitSections = 1 << 0,
    SGBuildContactsMixedSections = 1 << 1,
    SGBuildContactsWithEmailOrPhoneAttributes = 1 << 2
} SGBuildContactsSectionType;

typedef enum {
    kSGBuildContactsHollerbackSectionKey,
    kSGBuildContactsAddressBookSectionKey
} kSGBuildContactsSectionKey;

void runOnBuildContactsQueue(void (^block)(void));

@interface SGBuildContacts : NSObject

#pragma mark - Singleton

+ (id)sharedInstance;

#pragma mark - Class methods

// returns contacts grouped by first letter of contact.name
+ (NSArray*)collateContacts:(NSArray *)contacts;

#pragma mark - Build methods

- (void)cancel;

- (void)runForSectionType:(SGBuildContactsSectionType)sectionType
             grantAllowed:(void(^)())grantAllowed
              grantDenied:(void(^)())grantDenied
     cachedSectionsLoaded:(void(^)(NSArray *sections))cachedSectionsLoaded
        addressBookLoaded:(void(^)(NSArray *sections))addressBookLoaded
                completed:(void(^)(NSArray *sections))completed
                   failed:(void(^)(NSString *message))failed;

#pragma mark - Management

- (BOOL)didAttemptContactAccess;

- (void)setDidAttemptContactAccess:(BOOL)didAttemptContactAccess;

- (BOOL)isContactAccessAllowed;

@end
