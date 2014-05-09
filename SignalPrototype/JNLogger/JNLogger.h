//
//  JNLogger.h
//  SignalPrototype
//
//  Created by Joe Nguyen on 8/05/2014.
//  Copyright (c) 2014 Signal. All rights reserved.
//

#import <DDLog.h>
#import <DDASLLogger.h>
#import <DDTTYLogger.h>
#import <DDFileLogger.h>

// Log levels for DDLog
//#ifdef DEBUG
# define ddLogLevel LOG_LEVEL_VERBOSE
//#else
//# define ddLogLevel LOG_LEVEL_WARN
//#endif

// Turn off async logging for DDLog
#if defined(LOG_ASYNC_ENABLED)
#undef LOG_ASYNC_ENABLED
#define LOG_ASYNC_ENABLED NO
#endif

/*
 * JNLog - logs to Crashlytics and to file (assuming [[JNLog sharedInstance] configureFileLogger] was called in AppDelegate)
 * DEBUG == 1: logs will always display in console and write to file
 * DEBUG == 0: logs will not display on console but will write to file
 */
#ifdef DEBUG
#define JNLog(__FORMAT__, ...) { \
DDLogCVerbose((@"%s [%d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); \
}
#else
#define JNLog(__FORMAT__, ...) { \
DDLogCVerbose((@"%s [%d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); \
}
#endif

// Convenience macros
#define JNLogIsMainThread   JNLog(@"%@", [NSThread isMainThread] ? @"JNLogIsMainThread == YES" : @"JNLogIsMainThread == NO");
#define JNLogCallStack   JNLog(@"NSThread callStackSymbols:\n%@", [NSThread callStackSymbols]);
#define JNLogPrimitive(var) JNLog(@"%s: %@", #var, @(var))
#define JNLogObject(var) JNLog(@"%s: %@", #var, var)
#define JNLogRect(rect) JNLog(@"%s: %@", #rect, NSStringFromCGRect(rect))
#define JNLogSize(size) JNLog(@"%s: %@", #size, NSStringFromCGSize(size))
#define JNLogPoint(point) JNLog(@"%s: %@", #point, NSStringFromCGPoint(point))
#define TICK    NSDate *startTime = [NSDate date]
#define RETICK  startTime = [NSDate date]
#define TOCK    JNLog(@"Time: %f", -[startTime timeIntervalSinceNow])

//#define HBShortLog(__FORMAT__, ...) \
CLSNSLog((@"" __FORMAT__), ##__VA_ARGS__); \
DDLogCVerbose((@"" __FORMAT__), ##__VA_ARGS__);

#define HBShortLog(__FORMAT__, ...) \
fprintf(stderr, "%s\n", [[NSString stringWithFormat:__FORMAT__, ##__VA_ARGS__] UTF8String]); \
DDLogCVerbose((@"" __FORMAT__), ##__VA_ARGS__);

// NSLog helpers
#define NSLogPrimitive(var)  NSLog(@"%s: %@", #var, @(var))
#define NSLogObject(var)     NSLog(@"%s: %@", #var, var)
#define NSLogRect(rect)      NSLog(@"%s: %@", #rect, NSStringFromCGRect(rect))
#define NSLogSize(size)      NSLog(@"%s: %@", #size, NSStringFromCGSize(size))
#define NSLogPoint(point)    NSLog(@"%s: %@", #point, NSStringFromCGPoint(point))

@interface JNLogger : NSObject

+ (JNLogger*)sharedInstance;

+ (void)logException:(NSException*)exception;
+ (void)logExceptionWithName:(NSString*)name reason:(NSString*)reason error:(NSError*)error;

@end

#pragma mark - Memory usage

#define JNLogMemUsage(__FORMAT__, ...) \
JNLog(__FORMAT__, ##__VA_ARGS__); \
JNLog(@"%@", [MemUsage captureMemUsageGetString]);

@interface MemUsage : NSObject

+ (NSString*)captureMemUsageGetString;

@end
