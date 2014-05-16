//
//  SGSendToViewController.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 27/02/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import <EXTScope.h>

#import "UIImage+JNHelper.h"

#import "SGSendToViewController.h"
#import "SGHollerbackContactsViewController.h"
//#import "SGAddressBookContactsViewController.h"
//#import "SGUserSearchViewController.h"
#import "SGUser+Service.h"
#import "SGContact+Service.h"
#import "SGBuildContacts.h"
#import "JNAlertView.h"
#import "SGSession.h"
#import "JNIcon.h"

@interface SGSendToViewController () <UIActionSheetDelegate>

// header
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *headerSegmentedControl;
// content
@property (weak, nonatomic) IBOutlet UIView *contentView;
// group name
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *cancelGroupNameButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *groupNameViewBottomConstraint;
// footer
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UILabel *selectRecipientsLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *selectedFriendsScrollView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerViewBottomSpacingConstraint;
@property (nonatomic, strong) UILabel *selectedFriendsLabel;
@property (nonatomic, strong) UIButton *darkOverlayButton;
@property (nonatomic, strong) UIActivityIndicatorView *loadingSpinnerInNextButton;
// contacts sections
@property (nonatomic, strong) NSMutableArray *sections;

// selected friends
@property (nonatomic, strong) NSMutableArray *selectedFriends;

// hollerback contacts
@property (nonatomic, strong) SGHollerbackContactsViewController *hollerbackContactsViewController;

//// address book contacts
//@property (nonatomic, strong) SGHollerbackContactsViewController *addressBookContactsViewController;
//
//// username search
//@property (nonatomic, strong) SGHollerbackContactsViewController *userSearchViewController;

@end

@implementation SGSendToViewController

- (void)initialize
{
    JNLog();
    _selectedFriends = [NSMutableArray arrayWithCapacity:1];
    _canCancel = YES;
}

#pragma mark - Views

- (void)viewDidLoad
{
    self.title = NSLocalizedString(@"Send To", nil);
    
    [super viewDidLoad];
    
    [self setupViews];
    
    [self setupChildViewControllers];
    
    [self showHollerbackContacts];
    
    [self hideFooterViewAnimated:NO];
    
    [self buildSplitContacts];
    
    // log metric
    [SGSession didOnboardingActivity:kSGOnboardingContactList];
}

- (void)setupNavigationBar
{
    [super setupNavigationBar];
    
    [self applyBackNavigationButtonWithTarget:self action:@selector(goBackAction:)];
    
    [self hideNewGroupNavigationItem];
}

- (void)showNewGroupNavigationItem
{
    [self
     applyNavigationBarRightButtonWithLongText:NSLocalizedString(@"new.group.button.text", nil)
     target:self
     action:@selector(newGroupAction:)
     edgeInsets:UIEdgeInsetsMake(1.0, 0.0, 0.0, -14.0)];
}

- (void)hideNewGroupNavigationItem
{
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)setupViews
{
    JNLog();

    // segmented control
    [self.headerSegmentedControl setImage:
     [UIImage imageWithImage:[UIImage imageNamed:@"banana-blue-icon.png"]
                scaledToSize:CGSizeMake(20.0, 20.0)] forSegmentAtIndex:0];
    [self.headerSegmentedControl setImage:
     [UIImage imageWithImage:[UIImage imageNamed:@"contact-blue-icon.png"]
                scaledToSize:CGSizeMake(20.0, 20.0)] forSegmentAtIndex:1];
    [self.headerSegmentedControl setImage:
     [UIImage imageWithImage:[UIImage imageNamed:@"search-blue-icon.png"]
                scaledToSize:CGSizeMake(20.0, 20.0)] forSegmentAtIndex:2];
    
    // group name
    [self.groupNameView applyDarkShadowLayer];
    self.groupNameView.backgroundColor = JNLightGrayColor;
    self.groupNameLabel.font = [UIFont primaryFontWithSize:16.0];
    self.groupNameLabel.text = NSLocalizedString(@"group.name.label.text", nil);
    self.groupNameLabel.textColor = JNBlackColor;
    [self.cancelGroupNameButton setAttributedTitle:[JNIcon cancelIconWithSize:24.0 color:JNBlackColor] forState:UIControlStateNormal];
    self.groupNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.groupNameTextField.font = [UIFont primaryFontWithSize:16.0];
    self.groupNameTextField.textColor = JNBlackColor;
    self.groupNameTextField.delegate = self;
    self.groupNameTextField.returnKeyType = UIReturnKeyDone;
    [self hideGroupNameViewAnimated:NO];
    
    // footer
    [self.footerView applyDarkShadowLayer];
    self.footerView.backgroundColor = JNLightGrayColor;
    self.selectRecipientsLabel.backgroundColor = JNClearColor;
    self.selectRecipientsLabel.font = [UIFont primaryFontWithSize:16.0];
    self.selectRecipientsLabel.textColor = JNBlackColor;
    self.selectRecipientsLabel.text = NSLocalizedString(@"select.recipients.label.text", nil);
    self.selectedFriendsScrollView.scrollsToTop = NO;
    self.nextButton.backgroundColor = JNGrayBackgroundColor;
    [self.nextButton setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
    [self.nextButton setTitleColor:JNBlackTextColor forState:UIControlStateNormal];
    [self.nextButton setTitleColor:JNBlackTextColor forState:UIControlStateHighlighted];
    self.nextButton.titleLabel.font = [UIFont primaryFontWithSize:16.0];
}

- (void)setupChildViewControllers
{
    JNLog();
    
    @weakify(self);
    // hollerback contacts
    self.hollerbackContactsViewController = [[SGHollerbackContactsViewController alloc] initWithNib];
    [self addChildViewController:self.hollerbackContactsViewController];
    // did select contact
    self.hollerbackContactsViewController.didSelectContact = ^(SGContact *selectedContact) {
        [self_weak_ didSelectContact:selectedContact];
    };
//    // address book contacts
//    self.addressBookContactsViewController = [[SGAddressBookContactsViewController alloc] initWithNib];
//    [self addChildViewController:self.addressBookContactsViewController];
//    // did select contact
//    self.addressBookContactsViewController.didSelectContact = ^(SGContact *selectedContact) {
//        [self_weak_ didSelectContact:selectedContact];
//    };
//    // username search
//    self.userSearchViewController = [[SGUserSearchViewController alloc] initWithNib];
//    [self addChildViewController:self.userSearchViewController];
//    // did select contact
//    self.userSearchViewController.didSelectContact = ^(SGContact *selectedContact) {
//        [self_weak_ didSelectContact:selectedContact];
//    };
}

- (void)didSelectContact:(SGContact*)selectedContact
{
    if ([self selectFriend:selectedContact]) {
        if ([self contactHasMultiplePhoneNumbers:selectedContact]) {
            [self
             performPrimaryPhoneNumberSelection:selectedContact
             completed:^(SGContact *updatedContact) {
             }];
        }
    }
    [self updateFooterView];
}

- (void)showHollerbackContacts
{
    if (self.hollerbackContactsViewController.view.superview == self.contentView) {
        return;
    }
//    // remove subviews
//    [self.addressBookContactsViewController.view removeFromSuperview];
//    [self.userSearchViewController.view removeFromSuperview];
    // add view
    self.hollerbackContactsViewController.view.frame = self.contentView.bounds;
    self.hollerbackContactsViewController.promptText = NSLocalizedString(@"send to hollerback prompt", nil);
    [self.contentView addSubview:self.hollerbackContactsViewController.view];
    // update segment control
    self.headerSegmentedControl.selectedSegmentIndex = 0;
}

- (void)showAddressBookContacts
{
//    if (self.addressBookContactsViewController.view.superview == self.contentView) {
//        return;
//    }
//    // remove subviews
//    [self.hollerbackContactsViewController.view removeFromSuperview];
//    [self.userSearchViewController.view removeFromSuperview];
//    // add view
//    self.addressBookContactsViewController.view.frame = self.contentView.bounds;
//    self.addressBookContactsViewController.promptText = NSLocalizedString(@"send to address book prompt", nil);
//    [self.contentView addSubview:self.addressBookContactsViewController.view];
//    // update segment control
//    self.headerSegmentedControl.selectedSegmentIndex = 1;
}

- (void)showUsernameSearch
{
//    if (self.userSearchViewController.view.superview == self.contentView) {
//        return;
//    }
//    // remove subviews
//    [self.hollerbackContactsViewController.view removeFromSuperview];
//    [self.addressBookContactsViewController.view removeFromSuperview];
//    // add view
//    self.userSearchViewController.view.frame = self.contentView.bounds;
//    self.userSearchViewController.promptText = NSLocalizedString(@"send to search prompt", nil);
//    [self.contentView addSubview:self.userSearchViewController.view];
//    // update segment control
//    self.headerSegmentedControl.selectedSegmentIndex = 2;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.navigationController.navigationBar.barTintColor = JNWhiteColor;
}

- (void)viewWillLayoutSubviews
{
    JNLog();
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews
{
    JNLog();
    [super viewDidLayoutSubviews];
}

- (void)showLoadingSpinnerInNextButton
{
    // show loading next spinner
    self.loadingSpinnerInNextButton = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.loadingSpinnerInNextButton.center = self.nextButton.center;
    [self.footerView addSubview:self.loadingSpinnerInNextButton];
    [self.loadingSpinnerInNextButton startAnimating];

    [self.nextButton setTitleColor:JNClearColor forState:UIControlStateNormal];
    self.nextButton.enabled = NO;
}

- (void)hideLoadingSpinnerInNextButton
{
    [self.loadingSpinnerInNextButton stopAnimating];
    [self.loadingSpinnerInNextButton removeFromSuperview];
    
    [self.nextButton setTitleColor:JNWhiteColor forState:UIControlStateNormal];
    self.nextButton.enabled = YES;
}

#pragma mark - Actions

- (void)goBackAction:(id)sender
{
    JNLog();
    
    [self.navigationController popViewControllerAnimated:YES];
    if (self.didCancel) {
        self.didCancel(self);
    }
}

- (void)newGroupAction:(id)sender
{
    JNLog();
    [self showFooterViewAnimated:YES];
    [self showGroupNameViewAnimated:YES];
}

- (IBAction)headerSegmentedControlAction:(id)sender
{
    JNLogPrimitive(((UISegmentedControl*) sender).selectedSegmentIndex);
    
//    [self didSelectHollerbackContacts:@[@(1)] selectedContactsToInvite:@[@(1)]];
    
    NSInteger index = ((UISegmentedControl*) sender).selectedSegmentIndex;
    switch (index) {
        case 0:
            [self showHollerbackContacts];
            [self.hollerbackContactsViewController didFinishBuildingContacts];
            break;
        case 1:
            [self showAddressBookContacts];
            [self.hollerbackContactsViewController didFinishBuildingContacts];
            break;
        case 2:
            [self showUsernameSearch];
            [self.hollerbackContactsViewController didFinishBuildingContacts];
        default:
            break;
    }
}

- (IBAction)nextAction:(id)sender
{
    JNLog();
    JNLogObject(self.selectedFriends);
    if ([NSArray isNotEmptyArray:self.selectedFriends]) {
        if (self.didSelectFriends) {
            
            JNAssert(self.createConversationContext);
            
            if (self.createConversationContext) {
                self.createConversationContext.selectedContacts = self.selectedFriends;
            }
            
            self.didSelectFriends(self, self.createConversationContext);
            
            // show loading spinner
            [self showLoadingSpinnerInNextButton];
        }
    } else {
        [JNAlertView showWithTitle:NSLocalizedString(@"no.selected.friends.alert.title", nil)
                              body:NSLocalizedString(@"no.selected.friends.alert.body", nil)];
    }
}

#pragma mark - Build Contacts

-(void)buildSplitContacts
{
    JNLog();
    
    self.hollerbackContactsViewController.isLoading = YES;
//    self.addressBookContactsViewController.isLoading = YES;
    
    @weakify(self);
    // block to call when sections ready
    __block void(^populateSections)(NSArray*) = ^(NSArray *sections){
        if ([NSArray isNotEmptyArray:sections]) {
            // update hollerback contacts
            if ([NSArray isNotEmptyArray:sections[kSGBuildContactsHollerbackSectionKey]]) {
                self_weak_.hollerbackContactsViewController.contacts = sections[kSGBuildContactsHollerbackSectionKey];
            } else {
                self_weak_.hollerbackContactsViewController.contacts = @[];
            }
//            // update address book contacts
//            if (sections.count > 1 &&
//                [NSArray isNotEmptyArray:sections[kSGBuildContactsAddressBookSectionKey]]) {
//                self_weak_.addressBookContactsViewController.contacts = sections[kSGBuildContactsAddressBookSectionKey];
//            } else {
//                self_weak_.addressBookContactsViewController.contacts = @[];
//            }
        }
    };
    // run build split contacts
    runOnBuildContactsQueue(^{
        [[SGBuildContacts sharedInstance]
         runForSectionType:SGBuildContactsSplitSections
         grantAllowed:^{
             ;
         } grantDenied:^{
             JNLog(@"grantDenied");
             [self failedToBuildContacts:NSLocalizedString(@"Address Book denied body", nil)];
         } cachedSectionsLoaded:^(NSArray *sections) {
             JNLog(@"cachedSectionsLoaded: %@", @(sections.count));
             populateSections(sections);
         } addressBookLoaded:^(NSArray *sections) {
             JNLog(@"addressBookLoaded: %@", @(sections.count));
             populateSections(sections);
         } completed:^(NSArray *sections) {
             JNLog(@"completed: %@", @(sections.count));
             populateSections(sections);
             [self_weak_ finishedBuildingContacts:sections];
         } failed:^(NSString *message) {
             JNLog(@"failed: %@", message);
             [self_weak_ failedToBuildContacts:message];
         }];
    });
}

- (void)finishedBuildingContacts:(NSArray*)sections
{
    JNLog();
    self.hollerbackContactsViewController.isLoading = NO;
//    self.addressBookContactsViewController.isLoading = NO;
    
    [self.hollerbackContactsViewController reloadTableView];
//    [self.addressBookContactsViewController reloadTableView];
    
    [self.hollerbackContactsViewController didFinishBuildingContacts];
//    [self.addressBookContactsViewController didFinishBuildingContacts];
}

- (void)failedToBuildContacts:(NSString*)message
{
//    self.deniedAddressBook = YES;
    
//    // send log to server
//    [[JNLogger sharedInstance] sendLogWithSuffix:@"failedToBuildContacts"];
    
    // show alert
    __block NSString *message_block_ = message;
    runOnMainQueue(^{
        if ([NSString isNullOrEmptyString:message]) {
            message_block_ = NSLocalizedString(@"Build contacts failed", nil);
        }
        [JNAlertView
         showWithTitle:NSLocalizedString(@"Address Book denied title", nil)
         body:message];
        
        self.hollerbackContactsViewController.isLoading = NO;
//        self.addressBookContactsViewController.isLoading = NO;
        
        [self.hollerbackContactsViewController reloadTableView];
//        [self.addressBookContactsViewController reloadTableView];
        
        [self.hollerbackContactsViewController didFinishBuildingContacts];
//        [self.addressBookContactsViewController didFinishBuildingContacts];
    });
    
}

#pragma mark - Selected Friends

- (void)didSelectHollerbackContacts:(NSArray*)selectedHollerbackContacts selectedContactsToInvite:(NSArray*)selectedContactsToInvite
{
    JNLogPrimitive(selectedHollerbackContacts.count);
    JNLogPrimitive(selectedContactsToInvite.count);
    // do nothing if no friends and contacts selected
    if ([NSArray isEmptyArray:selectedHollerbackContacts] && [NSArray isEmptyArray:selectedContactsToInvite]) {
//        runOnMainQueue(^{
//            [self.navigationController popViewControllerAnimated:YES];
//        });
//        return;
    }
    if ([NSArray isNotEmptyArray:selectedContactsToInvite]) {
//        NSMutableDictionary *friendsMap = [self.friendsMap mutableCopy];
//        [friendsMap setObject:selectedContactsToInvite forKey:kHBInviteFriendsKey];
//        self.friendsMap = friendsMap;
    }
    runOnMainQueue(^{
        // update selected contacts + view
        [self.selectedFriends addObjectsFromArray:selectedHollerbackContacts];
        [self.selectedFriends addObjectsFromArray:selectedContactsToInvite];
        [self updateFooterView];
        // refresh table
//        [self performFetch];
//        [self.navigationController popViewControllerAnimated:YES];
    });
    
//    [HBSession didSelectFriends];
}

- (BOOL)selectFriend:(id)friend
{
    //    HBLogPrimitive(self.selectedFriends.count);
    BOOL isSelected;
    if ([self selectedFriends:self.selectedFriends containsFriend:friend]) {
        self.selectedFriends = [[self selectedFriends:self.selectedFriends removeFriend:friend] mutableCopy];
        isSelected = NO;
    } else {
        [self.selectedFriends addObject:friend];
        isSelected = YES;
    }
    //    HBLogPrimitive(self.selectedFriends.count);
    return isSelected;
}

- (id)selectedFriends:(NSArray*)selectedFriends matchFriend:(id)friend
{
    __block id matchedFriend = nil;
    [selectedFriends enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        // match HBUser by usernam
        if ([obj isKindOfClass:[SGUser class]] && [friend isKindOfClass:[SGUser class]]) {
            if ([((SGUser*) obj).username isEqualToString:((SGUser*) friend).username]) {
                matchedFriend = obj;
                *stop = YES;
            }
        }
        // match HBContact by object
        else if ([obj isKindOfClass:[SGContact class]] && [friend isKindOfClass:[SGContact class]]) {
            if (((SGContact*) obj) == ((SGContact*) friend)) {
                matchedFriend = obj;
                *stop = YES;
            }
        }
        // match RHPerson by object
        else if ([obj isKindOfClass:[RHPerson class]] && [friend isKindOfClass:[RHPerson class]]) {
            if (((RHPerson*) obj) == ((RHPerson*) friend)) {
                matchedFriend = obj;
                *stop = YES;
            }
        }
    }];
    return matchedFriend;
}

- (BOOL)selectedFriends:(NSArray*)selectedFriends containsFriend:(id)friend
{
    id matchedFriend = [self selectedFriends:selectedFriends matchFriend:friend];
    return matchedFriend != nil;
}

- (NSArray*)selectedFriends:(NSArray*)selectedFriends removeFriend:(id)friend
{
    id matchedFriend = [self selectedFriends:selectedFriends matchFriend:friend];
    if (matchedFriend) {
        NSMutableArray *mutableSelectedFriends = [selectedFriends mutableCopy];
        [mutableSelectedFriends removeObject:matchedFriend];
        return mutableSelectedFriends;
    }
    return nil;
}

- (void)updateFooterView
{
    [self updateSelectedFriendsView];
    // hide/show footer view
    if ([NSArray isEmptyArray:self.selectedFriends]) {
        [self hideFooterViewAnimated:YES];
    } else {
        [self showFooterViewAnimated:YES];
    }
}

- (void)hideFooterViewAnimated:(BOOL)animated
{
    CGFloat duration = animated ? 0.3 : 0.0;
    [UIView animateLayoutConstraintsWithContainerView:self.view childView:self.contentView duration:duration animations:^{
        self.tableViewBottomConstraint.constant = 0.0;
        self.footerViewBottomSpacingConstraint.constant = -self.footerView.frame.size.height;
    } completion:nil];
}

- (void)showFooterViewAnimated:(BOOL)animated
{
    CGFloat duration = animated ? 0.3 : 0.0;
    [UIView animateLayoutConstraintsWithContainerView:self.view childView:self.contentView duration:duration animations:^{
        self.tableViewBottomConstraint.constant = 0.0;
        self.footerViewBottomSpacingConstraint.constant = 0.0;
    } completion:nil];
}

- (void)updateSelectedFriendsView
{
    JNLog();
    NSMutableString *usernames = [@"" mutableCopy];
    [self.selectedFriends enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *usernameToAppend = @" ";
        if ([obj isKindOfClass:[SGUser class]]) {
            usernameToAppend = ((SGUser*) obj).username;
        }
        if ([obj isKindOfClass:[SGContact class]]) {
            SGContact *contact = (SGContact*) obj;
            if ([NSString isNotEmptyString:contact.username]) {
                usernameToAppend = contact.username;
            } else if ([NSString isNotEmptyString:contact.name]) {
                usernameToAppend = contact.name;
            }
        }
        [usernames appendString:usernameToAppend];
        if (idx < self.selectedFriends.count - 1) {
            [usernames appendString:@", "];
        }
    }];
    if (!self.selectedFriendsLabel) {
        self.selectedFriendsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.selectedFriendsLabel.font = [UIFont primaryFontWithSize:16.0];
        self.selectedFriendsLabel.textColor = JNBlackColor;
        [self.selectedFriendsScrollView addSubview:self.selectedFriendsLabel];
    }
    self.selectedFriendsLabel.text = usernames;
    [self.selectedFriendsLabel sizeToFit];
    self.selectedFriendsScrollView.contentSize = self.selectedFriendsLabel.frame.size;
    [self.selectedFriendsScrollView scrollRectToVisible:CGRectMake(self.selectedFriendsScrollView.contentSize.width - 1.0, 0.0, 1.0, 1.0) animated:YES];
    // hide/show select recipients label
    if ([NSArray isEmptyArray:self.selectedFriends]) {
        self.selectRecipientsLabel.alpha = 1.0;
    } else {
        self.selectRecipientsLabel.alpha = 0.0;
    }
}

#pragma mark - Group Name

- (void)showGroupNameViewAnimated:(BOOL)animated
{
    CGFloat duration = animated ? 0.3 : 0.0;
    [UIView animateLayoutConstraintsWithContainerView:self.view childView:self.groupNameView duration:duration animations:^{
        self.groupNameViewBottomConstraint.constant = 0.0;
        self.tableViewBottomConstraint.constant = self.groupNameView.bounds.size.height;
    }];
    // hide new group nav item
    [self hideNewGroupNavigationItem];
}

- (void)hideGroupNameViewAnimated:(BOOL)animated
{
    CGFloat duration = animated ? 0.3 : 0.0;
    [UIView animateLayoutConstraintsWithContainerView:self.view childView:self.groupNameView duration:duration animations:^{
        self.groupNameViewBottomConstraint.constant = -self.groupNameView.bounds.size.height;
        self.tableViewBottomConstraint.constant = 0.0;
    }];
}

- (void)repositionGroupNameViewForKeyboardShownAnimated:(BOOL)animated
{
    CGFloat duration = animated ? 0.3 : 0.0;
    [UIView animateLayoutConstraintsWithContainerView:self.view childView:self.groupNameView duration:duration animations:^{
        if (self.footerViewBottomSpacingConstraint.constant == 0.0) {
            self.groupNameViewBottomConstraint.constant = kSGKeyboardHeight - self.footerView.bounds.size.height;
        } else {
            self.groupNameViewBottomConstraint.constant = kSGKeyboardHeight;
        }
    }];
}

- (void)repositionGroupNameViewForKeyboardHideAnimated:(BOOL)animated
{
    CGFloat duration = animated ? 0.3 : 0.0;
    [UIView animateLayoutConstraintsWithContainerView:self.view childView:self.groupNameView duration:duration animations:^{
        self.groupNameViewBottomConstraint.constant = 0.0;
    }];
}

#pragma mark Group Name Text View Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    JNLog();
    // show dark overlay button
    if (!self.darkOverlayButton) {
        self.darkOverlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.darkOverlayButton.backgroundColor = [JNBlackColor colorWithAlphaComponent:0.5];
        self.darkOverlayButton.frame = self.view.bounds;
        [self.darkOverlayButton addTarget:self action:@selector(didTouchDarkOverlayButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.darkOverlayButton];
        self.darkOverlayButton.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            self.darkOverlayButton.alpha = 1.0;
        }];
    }
    // reposition group name view
    [self repositionGroupNameViewForKeyboardShownAnimated:YES];
    // bring to front
    [self.view bringSubviewToFront:self.groupNameView];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self finishedEditingTextField];
    JNLog();
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self finishedEditingTextField];
    return YES;
}

- (void)finishedEditingTextField
{
    // hide dark overlay button
    if (self.darkOverlayButton) {
        [UIView animateWithDuration:0.3 animations:^{
            self.darkOverlayButton.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.darkOverlayButton removeFromSuperview];
            self.darkOverlayButton = nil;
        }];
    }
    // reposition group name view
    [self repositionGroupNameViewForKeyboardHideAnimated:YES];
    // send footer view to front
    [self.view bringSubviewToFront:self.footerView];

}

- (void)didTouchDarkOverlayButton:(id)sender
{
    JNLog();
    [self.groupNameTextField resignFirstResponder];
}

@end
