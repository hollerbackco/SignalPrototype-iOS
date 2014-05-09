//
//  SGContact.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 9/07/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RHAddressBook/RHPerson.h>

@interface SGContact : NSObject <NSCopying, NSCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *phoneHashed;
@property (nonatomic) BOOL isAGroup;
@property (nonatomic, strong) NSURL *conversationObjectIDURI;
@property (nonatomic) BOOL hasSignedUp;
@property (nonatomic, strong) NSArray *phoneNumbers;
@property (nonatomic, strong) NSArray *phoneHashedNumbers;
@property (nonatomic, strong) NSArray *emails;
@property (nonatomic, strong) RHPerson *person; // no copying or encoding required for this
@property (nonatomic, copy) NSString *primaryPhoneNumber;
@property (nonatomic, copy) NSString *primaryEmail;

@end
