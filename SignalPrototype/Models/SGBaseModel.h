//
//  SGBaseModel.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 16/09/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <MTLValueTransformer.h>
#import <MTLJSONAdapter.h>

#import "MTLModel.h"
#import "SGDatabase.h"
#import "SGBaseModel.h"

@interface SGBaseModel : MTLModel

@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSDate *deletedAt;

+ (NSDictionary *)JSONKeyPathsByPropertyKey;
+ (NSValueTransformer*)JSONDateTransformer;

+ (SGBaseModel*)initFromJSONDictionary:(NSDictionary*)jsonDictionary;
+ (NSString *)generateGUID;

@end
