//
//  JNFileUtils.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 15/05/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JNFileUtils : NSObject

// show alert if less than 1mb of storage space
+ (void)checkFreeDiskSpace;

+ (BOOL)isFilenameFromLocalDisk:(NSString*)filename;

// TODO: refactor to search for existing file, recurse parent/intermediate folder(s).
+ (void)saveData:(NSData*)data filename:(NSString*)filename;

+ (BOOL)deleteFileAtURL:(NSURL*)fileURL;

+ (NSNumber*)getFileSize:(NSString*)filePath;

+ (NSData*)dataForResource:(NSString*)resourceName ofType:(NSString*)resourceType bundleClass:(Class)className;

+ (NSString*)createFolderInCachesDirectory:(NSString*)folderName;

+ (NSString*)getTempVideosPath;

// deletes folders in tmp/videos that were last modified >= 1 day ago
+ (void)deleteTempVideosAsBackgroundTask;

+ (BOOL)fileExists:(NSString*)filePath;

@end
