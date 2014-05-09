//
//  SGVideodata.m
//  HollerbackApp
//
//  Created by Kevin Coulton on 8/27/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <EXTScope.h>

#import "UIColor+JNHelper.h"
#import "JNSimpleDataStore.h"
#import "JNAppManager.h"

#import "SGVideodata.h"
#import "SGDatabase.h"
#import "SGAppDelegate.h"
#import "SGVideo.h"
#import "SGVideo+Service.h"
#import "SGConversation.h"
#import "SGConversation+Service.h"
#import "SGMessage+Service.h"
#import "SGSync.h"
#import "SGMetrics.h"

@interface SGVideodata()

@property (nonatomic, assign) NSInteger attempts;
@property (strong, nonatomic) NSDateFormatter *formatter;

- (NSString*) lastSyncTime;

+ (void)broadcastSyncUpdate;

@end

@implementation SGVideodata

@synthesize dataManager;

@synthesize colorCode;

const int localVideoLimit = 275;

+(SGVideodata*) sharedInstance
{
    static dispatch_once_t p = 0;
    __strong static SGVideodata* _singleton = nil;
    
    dispatch_once(&p, ^{
        _singleton = [[self alloc] init];
    });
    return _singleton;
}

-(id) init
{
	if (self = [super init])
	{
		colorCode = (int)([JNSimpleDataStore getValueForKey:SGLastConversationColorKey]) % 6;
		
		// initialize data manager
		dataManager = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfiguration:@"SGHollerbackBackgroundSession"]];
		
		_syncQueue = [[NSOperationQueue alloc] init];
		[_syncQueue setName:@"syncQueue"];
        [_syncQueue setSuspended:NO];

        _attempts = kSGRetryCount;
		receiverArray = [[NSMutableArray alloc] initWithObjects:nil];
	}
	return self;
}

- (void)addReceiver:(id<SGVideodataReceiver>)receiverToAdd;
{
    JNLog();
	[receiverArray insertObject:receiverToAdd atIndex:0];
}

- (void)removeReceiver:(id<SGVideodataReceiver>)receiverToRemove
{
    JNLog();
    [receiverArray removeObject:receiverToRemove];
}

// Returns an NSString in ISO 8601 UTC Time Zone format => YYYY-MM-DDTHH:mmZ
-	(NSString*)	lastSyncTime;
{
	NSDate *lastUpdatedAt = (NSDate*)[JNSimpleDataStore getValueForKey:kSGConversationsLastUpdatedAt];
    NSString *time = [[NSDate dateFormatter] stringFromDate:lastUpdatedAt];
	return time;
}

// Returns an NSString in ISO 8601 UTC Time Zone format => YYYY-MM-DDTHH:mmZ of the Current Time
-	(NSString*)	serverStyleCurrentTime;
{
	NSDate *now = [NSDate date];
    NSString *time = [[NSDate dateFormatter] stringFromDate:now];
	return time;
}

- (void)setDefaultHTTPHeaders:(NSMutableURLRequest*)mutableURLRequest
{
    // send app ver to server
    [mutableURLRequest setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forHTTPHeaderField:kSGRequestHeaderAppVersion];
    [mutableURLRequest setValue:[[JNAppManager class] modelName] forHTTPHeaderField:kSGRequestHeaderModelName];
    [mutableURLRequest setValue:kSGRequestHeaderAPIVersion forHTTPHeaderField:kSGRequestHeaderAccept];
}

- (void)syncWithCompleteBlock:(void (^)(void))completionBlock
{
    JNLog();
    [[self syncQueue] setSuspended:NO];
    
    [self
     syncWithUpdateTime:[self lastSyncTime]
     completion:completionBlock];
}

- (void)syncWithUpdateTime:(NSString*)lastUpdated
                completion:(void (^)(void))completionBlock;
{
    JNLog();
    
	// TODO setup a dedicated Qusue for DB ops
    NSString *requestUrl = [[NSString alloc] init];
    
//#warning TESTING
//    // lastUpdatedAt for testing
//    lastUpdated = @"2014-03-01T21:47:41Z";
    
    if(lastUpdated) {
        requestUrl = [NSString stringWithFormat:
                      @"%@me/sync?access_token=%@&updated_at=%@",
                      kSGAPIBasePath,
                      [JNSimpleDataStore getValueForKey:kSGAccessTokenKey],
                      lastUpdated];
    } else {
        requestUrl = [NSString stringWithFormat:
                      @"%@me/sync?access_token=%@&count=%@",
                      kSGAPIBasePath,
                      [JNSimpleDataStore getValueForKey:kSGAccessTokenKey],
                      @(kSGSyncPaginationCount)];
    }
    JNLogObject(requestUrl);
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:
                                [NSURL URLWithString:requestUrl]];
	
    [self setDefaultHTTPHeaders:req];
	
	__weak typeof(self) this = self;
    
    // only log sync time when there is no lastUpdatedAt
    __block NSDate *syncRemoteStartTime = nil;
    if (!lastUpdated) {
        syncRemoteStartTime = [NSDate date];
    }
    // perform sync request
	[NSURLConnection
	 sendAsynchronousRequest:req
	 queue:_syncQueue
	 completionHandler:^(NSURLResponse* resp, NSData *data, NSError *err) {
         if(!err) {
             
             [self resetAttempts];
             
             if (((NSHTTPURLResponse*) resp).statusCode == 403) {
                 [JNLogger logExceptionWithName:THIS_METHOD reason:@"403 error" error:nil];
#warning todo
//                 [((SGAppDelegate*) [UIApplication sharedApplication].delegate) handleAuthorizationError];
                 return;
             }
             
             // sync remote time
             if (syncRemoteStartTime) {
                 CGFloat syncRemoteTime = -syncRemoteStartTime.timeIntervalSinceNow;
                 [SGMetrics addMetric:SGKeenSyncRemoteTime withParameters:@{@"timeInSecs": @(syncRemoteTime)}];
             }
             JNLogObject(@(data.length));
             // Begin any process that will use the data
             // ...
             // Deserialize JSON
             NSError* error;
             NSDictionary* json =    [NSJSONSerialization
                                      JSONObjectWithData: data //1
                                      options:            kNilOptions
                                      error:              &error];
             
             // get sync date from server
             NSDictionary* meta = json[@"meta"];
             NSDate *lastUpdated;
             if(meta[@"last_sync_at"]) {
                 NSString *dateString = (NSString*)([meta valueForKey:@"last_sync_at"]);
                 lastUpdated = [[NSDate dateFormatter] dateFromString:dateString];
             } else {
                 lastUpdated = [[NSDate alloc] init];
             }
             [JNSimpleDataStore setValue:lastUpdated forKey:kSGConversationsLastUpdatedAt];
             
             NSArray* syncs = json[@"data"];
             
             if([NSArray isNotEmptyArray:syncs]) {
                 
                 // change to dictionary
                 [SGSync processSyncData:syncs
                            onCompletion:completionBlock];
             } else {
                 JNLog(@"NO SYNC OBJECTS PRESENT");

                 // broadcast sync completion
                 [SGSync broadcastSync:nil];

                 if (completionBlock) completionBlock();
             }
         } else {
             // TODO: cleanup failed attempts
             if(self.attempts >= 0) {
                 self.attempts--;
                 // try again
                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kSGRetrySyncDelay * NSEC_PER_SEC));
                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                     JNLog();
                     [this syncWithCompleteBlock:completionBlock];
                 });
                 
                 JNLog(@"SYNC ERROR: %@",[err description]);
             } else {
                 [self resetAttempts];
             }
         }
	 }];
}

- (void)leaveConversation:(NSNumber*)conversationId
{
}

- (void)resetAttempts
{
    self.attempts = kSGRetryCount;
}


+ (void)broadcastSyncUpdate
{
	for (id receiver in [SGVideodata sharedInstance]->receiverArray)
	{
		[receiver receiveVideodataSync];
		JNLog(@"BROADCAST SYNC");
	}
}

@end
