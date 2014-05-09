//
//  JNSimpleDataStore.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 11/03/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <Foundation/Foundation.h>

// A utility class to quickly store simple KVP (key-value-pair) data. Persists for the life of the app.

@interface JNSimpleDataStore : NSObject

+ (NSString*)getCachePath;

// use for standard NSObjects like NSString, NSNumber NSArray, NSDictionary
+ (void)setValue:(NSObject*)object forKey:(NSString*)key;
+ (NSObject*)getValueForKey:(NSString*)key;

// use for custom objects with NSCoding protocol
+ (void)archiveObject:(id)object filename:(NSString*)filename;
+ (id)unarchiveObjectWithFilename:(NSString*)filename;
+ (void)deleteArchivedObject:(NSString*)filename;

@end
