//
//  JNLogger.m
//  SignalPrototype
//
//  Created by Joe Nguyen on 8/05/2014.
//  Copyright (c) 2014 Signal. All rights reserved.
//

#import <AmazonS3Client.h>
#import <S3TransferManager.h>

#import "JNLogger.h"

#define kHBDailyLogDateKey @"kHBDailyLogDateKey"

@interface JNLogger ()

@property (nonatomic, strong) DDFileLogger *fileLogger;

@end

@implementation JNLogger

#pragma mark - Singleton

static JNLogger *sharedInstance;

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        sharedInstance = [[JNLogger alloc] init];
    }
}

+ (JNLogger*)sharedInstance
{
    return sharedInstance;
}

#pragma mark - Class methods

+ (void)logException:(NSException*)exception
{
    JNLog(@"!!!!!!!!!!! EXCEPTION !!!!!!!!!!!");
    JNLogObject([NSThread callStackSymbols]);
    JNLogObject(exception);
}

+ (void)logExceptionWithName:(NSString*)name reason:(NSString*)reason error:(NSError*)error
{
    JNLog(@"!!!!!!!!!!! EXCEPTION !!!!!!!!!!!");
    JNLogObject([NSThread callStackSymbols]);
    JNLogObject(name);
    JNLogObject(reason);
    JNLogObject(error);
}

#pragma mark -

- (void)configureFileLogger
{
    self.fileLogger = [[DDFileLogger alloc] init];
    _fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    _fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    self.fileLogger.maximumFileSize =  (5 * 1024 * 1024); // 5MB
    [DDLog addLogger:_fileLogger];
}

- (void)configureAllLoggers
{
    // CocoaLumberjack (Logging)
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [self configureFileLogger];
}

#pragma mark - AmazonServiceRequestDelegate

-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {}

@end

#import "mach/mach.h"

@implementation MemUsage

static long prevMemUsage = 0;
static long curMemUsage = 0;
static long memUsageDiff = 0;
static long curFreeMem = 0;

+ (vm_size_t)freeMemory
{
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    vm_statistics_data_t vm_stat;
    
    host_page_size(host_port, &pagesize);
    (void) host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    return vm_stat.free_count * pagesize;
}

+ (vm_size_t)usedMemory
{
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0; // size in bytes
}

+ (void)captureMemUsage
{
    prevMemUsage = curMemUsage;
    curMemUsage = [MemUsage usedMemory];
    memUsageDiff = curMemUsage - prevMemUsage;
    curFreeMem = [MemUsage freeMemory];
}

+ (NSString*)captureMemUsageGetString
{
    return [MemUsage captureMemUsageGetString: @"Memory used %7.1f (%+5.0f), free %7.1f kb"];
}

+ (NSString*)captureMemUsageGetString:(NSString*) formatstring
{
    [MemUsage captureMemUsage];
    return [NSString stringWithFormat:formatstring,curMemUsage/1000.0f, memUsageDiff/1000.0f, curFreeMem/1000.0f];
    
}

@end
