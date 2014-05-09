//
//  JNFileUtils.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 15/05/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "JNFileUtils.h"
#import "JNAlertView.h"

#define kJNLowDiskSpaceAmount 10

@implementation JNFileUtils

+ (uint64_t)getFreeDiskspace
{
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        JNLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        JNLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %@", error.domain, @(error.code));
    }
    return totalFreeSpace;
}

+ (void)checkFreeDiskSpace
{
    NSUInteger freeDiskSpace = (NSUInteger) [JNFileUtils getFreeDiskspace];
    // low storage space is 10MB
    if (freeDiskSpace <= pow((double)2, 20) * kJNLowDiskSpaceAmount) {
        NSString *message = NSLocalizedString(@"Low disk space", nil);
        if (freeDiskSpace <= 0.0) {
            message = NSLocalizedString(@"Zero disk space", nil);
        }
        [JNAlertView showWithTitle:@"" body:@""];
    }
}

+ (BOOL)isFilenameFromLocalDisk:(NSString*)filename
{
    return ([filename rangeOfString:@"file://"].location != NSNotFound) || ([filename rangeOfString:@"/var"].location != NSNotFound);
}

// TODO: refactor to search for existing file, recurse parent/intermediate folder(s).
+ (void)saveData:(NSData*)data filename:(NSString*)filename
{
    BOOL folderExists = NO;
    NSArray *components = [filename componentsSeparatedByString:@"/"];
    if (components && components.count > 0) {
        NSString *childFolder = [[components subarrayWithRange:NSMakeRange(0, components.count - 1)] componentsJoinedByString:@"/"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:childFolder]) {
            NSError *error;
            if ([[NSFileManager defaultManager] createDirectoryAtPath:childFolder withIntermediateDirectories:NO attributes:0 error:&error]) {
                JNLog(@"created folder: %@", childFolder);
                folderExists = YES;
            } else {
                if (error)
                    JNLog(@"Failed to create folder: %@\nerror: %@", childFolder, error);
                folderExists = NO;
            }
        } else {
            folderExists = YES;
        }
    }
    if (folderExists) {
        NSError *error;
        if (![data writeToFile:filename options:0 error:&error]) {
            JNLogObject(error);
        }
    }
}

+ (BOOL)deleteFileAtURL:(NSURL*)fileURL
{
//    JNLog(@"fileURL: %@", fileURL);
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL.relativePath isDirectory:NO]) {
        NSError *error;
        if (![[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error]) {
            [JNLogger logException:[NSException exceptionWithName:THIS_METHOD reason:@"error removing file" userInfo:@{@"error": error}]];
        } else {
            return YES;
        }
    }
    return NO;
}

+ (NSNumber*)getFileSize:(NSString*)filePath
{
    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager]
                                attributesOfItemAtPath:filePath error:&error];
    if (!error) {
        NSNumber *size = [attributes objectForKey:NSFileSize];
        return size;
    } else {
        [JNLogger logException:[NSException exceptionWithName:THIS_METHOD reason:@"error getting file size" userInfo:@{@"error": error}]];
    }
    return nil;
}

+ (NSData*)dataForResource:(NSString*)resourceName ofType:(NSString*)resourceType bundleClass:(Class)className
{
    NSString *filePath = [[NSBundle bundleForClass:className] pathForResource:resourceName ofType:resourceType];
    return [NSData dataWithContentsOfFile:filePath];
}

+ (NSString*)createFolderInCachesDirectory:(NSString*)folderName
{
    NSArray *cachesPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesPath = cachesPaths.firstObject;
    if ([NSString isNullOrEmptyString:cachesPath]) {
        return nil;
    }
    
    NSString *folderInCachesPath = [NSString stringWithFormat:@"%@/%@", cachesPath, folderName];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderInCachesPath]) {
        if (![[NSFileManager defaultManager]
              createDirectoryAtPath:folderInCachesPath
              withIntermediateDirectories:NO
              attributes:0
              error:&error]) {
            if (error) {
                [JNLogger logExceptionWithName:THIS_METHOD reason:@"Failed to create folder" error:error];
            }
            folderInCachesPath = nil;
        }
    }
    return folderInCachesPath;
}

+ (NSString*)getTempVideosPath
{
//    if (![JNFileUtils createFolderInCachesDirectory:kJNTempFolder]) {
//        return nil;
//    }
//    
//    NSString *tempVideosPath = [JNFileUtils createFolderInCachesDirectory:kJNTempVideosFolder];
//    return tempVideosPath;
    return nil;
}

+ (void)deleteTempVideosAsBackgroundTask
{
    UIBackgroundTaskIdentifier taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void) {
        JNLog(@"Background task is being expired.");
    }];
    
    [self deleteTempVideos];
    
    [[UIApplication sharedApplication] endBackgroundTask:taskId];
}

+ (void)deleteTempVideos
{
//    NSString *tempVideosPath = [self.class getTempVideosPath];
//    NSError* error = nil;
//    NSArray* tempVideosFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:tempVideosPath isDirectory:YES]
//                                                             includingPropertiesForKeys:@[NSURLContentModificationDateKey]
//                                                                                options:NSDirectoryEnumerationSkipsHiddenFiles
//                                                                                  error:nil];
//    if(error) {
//        JNLogObject(error);
//        return;
//    }
//    [tempVideosFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        // delete folders with last modified date >= x days ago
//        NSDate *folderModifedDate;
//        [obj getResourceValue:&folderModifedDate forKey:NSURLContentModificationDateKey error:nil];
//        NSInteger daysPassed = [NSDate daysBetweenFromDate:folderModifedDate toDate:[NSDate date]];
//        if (daysPassed >= kJNDeleteTempVideosLastModifiedDaysAgo) {
//            NSError *removeFileError;
//            if (![[NSFileManager defaultManager] removeItemAtURL:obj error:&removeFileError]) {
//                JNLogObject(error);
//            }
//        }
//    }];
}

+ (BOOL)fileExists:(NSString*)filePath
{
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:NO];
}

@end
