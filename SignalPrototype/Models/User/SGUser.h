//
//  SGUser.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 29/10/2013.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

#import "SGBaseModel.h"

@interface SGUser : SGBaseModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *phoneNormalized;
@property (nonatomic, copy) NSString *phoneHashed;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, strong) NSNumber *isBlocked;

@end
