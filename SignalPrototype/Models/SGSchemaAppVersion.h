//
//  SGSchemaAppVersion.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 6/03/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import <SWFSemanticVersion.h>

#import "SGBaseModel.h"

@interface SGSchemaAppVersion : SGBaseModel

@property (nonatomic, copy) NSString *appVersion;

@end
