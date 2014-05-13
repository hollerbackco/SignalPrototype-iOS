//
//  SGConversationsViewController.m
//  SignalPrototype
//
//  Created by Joe Nguyen on 8/05/2014.
//  Copyright (c) 2014 Signal. All rights reserved.
//

#import <EXTScope.h>
#import <MHPrettyDate.h>

#import "JNIcon.h"

#import "SGConversationsViewController.h"
#import "SGThreadViewController.h"
#import "SGConversationsTableViewCell.h"
#import "SGConversation+Service.h"
#import "SGSession.h"

dispatch_queue_t conversationListQueue() {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("conversationListQueue", 0);
    });
    return queue;
}

void runOnConversationListQueue(void (^block)(void))
{
    dispatch_async(conversationListQueue(), block);
}

@interface SGConversationsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *conversations;

// Sync
@property (nonatomic, strong) RACDisposable *syncNotificationDisposable;

@end

@implementation SGConversationsViewController

#pragma mark - Views

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupTableView];
    
    [self performFetch];
}

- (void)setupNavigationBar
{
    [super setupNavigationBar];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    [self applyCreateConversationNavigationItem:self action:@selector(createConversationAction:)];
}

- (void)applyCreateConversationNavigationItem:(id)target action:(SEL)action
{
    UIImage *image = [JNIcon composeImageIconWithSize:30.0 color:JNGrayColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0.0, -10.0, 0.0, 0.0);
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (void)setupTableView
{
    JNLog();
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"SGConversationsTableViewCell" bundle:nil] forCellReuseIdentifier:@"SGConversationsTableViewCell"];
    self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    JNLog();
//    [self setupNavigationBar];
    
    [self setupApplicationObservers];
    
    [self observeSyncNotification];
    
    [self startSyncing];
}

- (void)setupApplicationObservers
{
    JNLog();
    // application observers
    [self observeApplicationNotifications];
    
    self.applicationDidBecomeActiveBlock = ^(NSNotification *note) {
        [[SGSession sharedInstance] syncWithRemoteCompleted:^{
            JNLog(@"sync complete");
        }];
    };
}

#pragma mark - Actions

- (void)createConversationAction:(id)sender
{
    JNLog();
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Sync

- (void)observeSyncNotification
{
    JNLog();
    if (self.syncNotificationDisposable) {
        [self.syncNotificationDisposable dispose];
    }
    @weakify(self);
    self.syncNotificationDisposable =
    [[[NSNotificationCenter defaultCenter]
      rac_addObserverForName:kSGSyncPostNotificationName object:nil]
     subscribeNext:^(id x) {
         JNLogObject(kSGSyncPostNotificationName);
         
         if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
             [self_weak_ performFetch];
         }
     }];
}

- (void)removeSyncNotificationObserver
{
    JNLog();
    if (self.syncNotificationDisposable) {
        [self.syncNotificationDisposable dispose];
    }
}

- (void)startSyncing
{
    JNLogPrimitive([SGSession sharedInstance].isSyncing.boolValue);
    [[SGSession sharedInstance] restart];
}

#pragma mark - Data Source

- (void)performFetch
{
    JNLog();
//    [self hidePaginationView:NO];
    
    runOnConversationListQueue(^{
        [SGConversation fetchAllConversations:^(NSArray *conversations) {
            runOnMainQueue(^{
                self.conversations = [conversations mutableCopy];
                
                //            // show/hide zero conversation label
                //            if (self.didReceiveFirstDataSync &&
                //                [NSArray isEmptyArray:self.conversations]) {
                //                [self showZeroConversationsView];
                //            } else {
                //                [self hideZeroConversationsView];
                //            }
                // store the last conversation message date for pagination
                
                runOnMainQueue(^{
//                    // save the last convo message date
//                    [self storeLastConversationMessageDate];
//                    // show/hide pagination footer
//                    [self setPaginationVisibilityWithConversationCount:conversations.count];
                    // reload data
                    [self.tableView reloadData];
                });
            });
        }];
    });
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger numberOfRows = self.conversations.count;
    //    numberOfRows += self.newConversationRow;
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    // return height of cells
# pragma mark TODO parameterize all height and width numbers
    return kSGConversationsTableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"SGConversationsTableViewCell";
    SGConversationsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    SGConversation *conversation = [self.conversations objectAtIndex:indexPath.row];
    
    cell.senderName = @"test";
    cell.sentAt = [MHPrettyDate prettyDateFromDate:conversation.lastMessageAt withFormat:MHPrettyDateFormatTodayTimeOnly];
    cell.messageText = conversation.name;
    
//
//    [cell setThumbURL:[NSURL URLWithString:conversation.mostRecentThumbURL]];
//    NSDate *lastMessageAt = conversation.lastMessageAt;
//    if ([NSDate isNotNullDate:conversation.lastMessageAt]) {
//        NSString *subtitle = [MHPrettyDate prettyDateFromDate:lastMessageAt withFormat:MHPrettyDateFormatWithTime];
//        if ([NSString isNotEmptyString:conversation.mostRecentSubtitle]) {
//            subtitle = [NSString stringWithFormat:@"%@ - %@", subtitle, conversation.mostRecentSubtitle];
//        }
//        [cell setSubtitle:subtitle];
//    }
//    [cell setName:conversation.name];
//    [cell setUnwatchedCount:conversation.unreadCount];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SGConversation *conversation = self.conversations[indexPath.row];
    
    SGThreadViewController *threadViewController = [self setupThreadViewControllerWithConversation:conversation];
    
    [self.navigationController pushViewController:threadViewController animated:YES];
}

- (SGThreadViewController*)setupThreadViewControllerWithConversation:(SGConversation*)conversation
{
    SGThreadViewController *threadViewController = [[SGThreadViewController alloc] initWithNib];
    threadViewController.conversation = conversation;
    return threadViewController;
}


@end
