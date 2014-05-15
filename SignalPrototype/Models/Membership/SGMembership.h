//
//  SGMembership.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 17/01/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGBaseModel.h"
#import "SGUser.h"

@interface SGMembership : SGUser

@property (nonatomic, strong) NSNumber *following;

@end
