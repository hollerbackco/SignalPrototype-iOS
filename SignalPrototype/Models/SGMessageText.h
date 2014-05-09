//
//  SGMessageText.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 8/04/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGBaseModel.h"

@interface SGMessageText : SGBaseModel

@property (nonatomic, copy) NSString *guid;
@property (nonatomic, copy) NSString *text;

@end
