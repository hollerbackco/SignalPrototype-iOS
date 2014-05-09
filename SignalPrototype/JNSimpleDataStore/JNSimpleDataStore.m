//
//  JNSimpleDataStore.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 11/03/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "JNSimpleDataStore.h"

@implementation JNSimpleDataStore

static BOOL plistIsCreated;
static NSString *kJNSimpleDataStorePlist = @"JNSimpleDataStore.plist";

+ (NSString*)getSimpleDataStorePath
{
    // get paths from root direcory
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    // get documents path
    NSString *documentsPath = [paths objectAtIndex:0];
    // get path
    return [documentsPath stringByAppendingPathComponent:kJNSimpleDataStorePlist];
}

+ (void)createSimpleDataStorePlist
{
    // create empty dictionary
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSString *plistPath = [self getSimpleDataStorePath];
    
    //Create plist file and serialize XML
    NSError *error = nil;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:dict
                                                              format:NSPropertyListBinaryFormat_v1_0
                                                             options:0
                                                               error:&error];
    if (data) {
        [data writeToFile:plistPath atomically:YES];
        plistIsCreated = YES;
    } else {
        /// JNLog(@"An error has occured %@", error.userInfo);
    }
}

+ (void)setValue:(NSObject*)object forKey:(NSString*)key
{
    NSString *plistPath = [self getSimpleDataStorePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        [JNSimpleDataStore createSimpleDataStorePlist];
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    if (!dict) {
        dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:object, key, nil];
    } else {
        [dict setValue:object forKey:key];
    }
    
    if ([dict writeToFile:plistPath atomically:YES]) {
        /// JNLog(@"Write to file successful");
    } else {
        /// JNLog(@"Write to file unsuccessful");
    }
}

+ (NSObject*)getValueForKey:(NSString*)key
{
    NSString *plistPath = [self getSimpleDataStorePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        if (dict)
            return [dict valueForKey:key];
    }
    return nil;
}

+ (NSString*)getCachePath
{
    // get paths from root direcory
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES);
    // get cache path
    return [paths objectAtIndex:0];
}

#pragma mark - Archive/Unarchive

+ (void)archiveObject:(id)object filename:(NSString*)filename
{
    NSString *cachePath = [JNSimpleDataStore getCachePath];
    NSString *filenamePath = [cachePath stringByAppendingPathComponent:filename];
    // archive
    if (![NSKeyedArchiver archiveRootObject:object toFile:filenamePath]) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"could not archive file" error:nil];
    }
}

+ (id)unarchiveObjectWithFilename:(NSString*)filename
{
    NSString *cachePath = [JNSimpleDataStore getCachePath];
    NSString *filenamePath = [cachePath stringByAppendingPathComponent:filename];
    id unarchivedObject = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filenamePath]) {
        unarchivedObject = [NSKeyedUnarchiver unarchiveObjectWithFile:filenamePath];
    }
    return unarchivedObject;
}

+ (void)deleteArchivedObject:(NSString*)filename
{
    NSString *cachePath = [JNSimpleDataStore getCachePath];
    NSString *filenamePath = [cachePath stringByAppendingPathComponent:filename];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filenamePath]) {
        NSError *error;
        if (![[NSFileManager defaultManager] removeItemAtPath:filenamePath error:&error]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:@"could not delete archived object" error:error];
        }
    }
}


@end
